/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet



public class DropletBuilder {

    public var defaultRequestOptionsFactory: DefaultRequestOptionsFactory = DefaultRequestOptionsFactory()

    public var requestManagerFactory: Option<RequestManagerFactory> = Option<RequestManagerFactory>.None;

    public var memorySizeCalculator: Option<MemorySizeCalculator> = Option<MemorySizeCalculator>.None;

    public var memoryCache: Option<MemoryCache> = None;
    public var activeResources: Option<ActiveResources> = None;
    public var engine: Option<Engine> = None;

    public var diskCacheFactory: Option<InternalCacheDiskCacheFactory> = None;

    public var arrayPool: Option<LruArrayPool> = None;

    public func setRequestManagerFactory(factory: RequestManagerFactory) {
        this.requestManagerFactory = Option<RequestManagerFactory>.Some(factory);
    }

    public func setMemorySizeCalculator(calculator: MemorySizeCalculator): DropletBuilder {
        this.memorySizeCalculator = Option<MemorySizeCalculator>.Some(calculator);
        return this;
    }

    public func build(context: StageContext) {

        if(arrayPool.isNone()){
             arrayPool = LruArrayPool(4 * 1024 * 1024)
        }

        if(memoryCache.isNone()){
             memoryCache = LruResourceCache(8192*1000*1000)
        }

        if(activeResources.isNone()){
            activeResources = ActiveResources(8192*1000*1000)
        }

        if(diskCacheFactory.isNone()){
            diskCacheFactory = InternalCacheDiskCacheFactory()
        }

        if(engine.isNone()){
            engine = Engine(memoryCache.getOrThrow(),activeResources.getOrThrow(),diskCacheFactory.getOrThrow())
        }

        return Droplet(RequestManagerRetriever(), defaultRequestOptionsFactory, memoryCache.getOrThrow(), activeResources.getOrThrow(), context, engine.getOrThrow(), arrayPool.getOrThrow())
    }
}

public class Droplet <: ActiveResourceRemovedListener {

    public static var globalcontext:Option<StageContext> = Option<StageContext>.None

    public static let LIFECYCLE_KEY_GLOBAL: String = "global"

    private let requestManagerRetriever: RequestManagerRetriever
    private let dropletContext: DropletContext;

    private static let mtx = ReentrantMutex()

    public static var droplet: Option<Droplet> = Option<Droplet>.None;
    public static var isInitializing: Bool = false;

    private let managers: HashSet<RequestManager> = HashSet<RequestManager>();
    private static let mtxManagers = ReentrantMutex()

    public var memoryCache: MemoryCache;
    public var activeResources: ActiveResources;

    public var engine: Engine;

    public var arrayPool: ArrayPool

    init(requestManagerRetriever: RequestManagerRetriever, defaultRequestOptionsFactory: RequestOptionsFactory, memoryCache: MemoryCache, activeResources: ActiveResources, context: StageContext, engine: Engine, arrayPool: ArrayPool) {
        this.requestManagerRetriever = requestManagerRetriever
        this.dropletContext = DropletContext(defaultRequestOptionsFactory, context, arrayPool)
        this.memoryCache = memoryCache
        this.activeResources = activeResources
        this.engine = engine
        this.arrayPool = arrayPool
        this.activeResources.setActiveResourceRemovedListener(this)
        globalcontext = context
    }

    func getEngine(): Engine {
        return engine;
    }

    func getDropletContext(): DropletContext {
        return this.dropletContext
    }

    func getArrayPool(): ArrayPool {
        return arrayPool;
    }

    func setStringModelLoader(modelLoader: ModelLoader): Unit {
        this.dropletContext.getManager().setStringModelLoader(modelLoader)
    }

    func setFileModelLoaders(modelLoader: ModelLoader): Unit {
        this.dropletContext.getManager().setFileModelLoader(modelLoader)
    }

    public static func get(context: StageContext): Droplet {
        if(droplet.isNone()){
            synchronized (mtx) {
                if(droplet.isNone()){
                     checkAndInitializeDroplet(context)
                }
            }
        }
        return droplet.getOrThrow()
    }

    static func checkAndInitializeDroplet(context: StageContext) {
        if(isInitializing) {
            throw IllegalStateException("You cannot call Droplet.get() in registerComponents(), use the provided Droplet instance instead")
        }

        isInitializing = true;
        initializeDroplet(context, DropletBuilder());
        isInitializing = false;
    }

    private static func initializeDroplet(context: StageContext, builder: DropletBuilder) {
        let dropletLocal: Droplet = builder.build(context)

        Droplet.droplet = Some(dropletLocal)
    }

    public func setMemoryCache(memoryCache: MemoryCache): Unit {
        this.memoryCache = memoryCache
    }

    func getRequestManagerRetriever() {
        return this.requestManagerRetriever
    }

    static func getRetriever(context: StageContext): RequestManagerRetriever {
        return Droplet.get(context).getRequestManagerRetriever()
    }

    public static func withContext(context: StageContext): RequestManager {
        return getRetriever(context).get(context, LIFECYCLE_KEY_GLOBAL)
    }

    public static func withContext(context: StageContext, label: String): RequestManager {
        if (label.isEmpty()) {
            return getRetriever(context).get(context, LIFECYCLE_KEY_GLOBAL)
        }
        return getRetriever(context).get(context, label)
    }

    func removeFromManagers(target: AnyTarget): Bool {
        synchronized (mtxManagers) {
            for (requestManager in managers) {
                if (requestManager.untrack(target)) {
                    return true;
                }
            }
        }

        return false;
    }

    public func clearMemory(): Unit {
        memoryCache.clearMemory();
    }

    func trimMemory(level: Int64): Unit {
        // Name	                Value	Description
        // MEMORY_LEVEL_MODERATE	0	Moderate memory usage.
        // MEMORY_LEVEL_LOW	        1	Low memory usage.
        // MEMORY_LEVEL_CRITICAL	2	High memory usage.
        synchronized (mtxManagers) {
            for (manager in managers) {
                manager.onTrimMemory(level);
            }
        }
        // memory cache needs to be trimmed before bitmap pool to trim re-pooled Bitmaps too. See #687.
        memoryCache.trimMemory(level);
    }

    public func onActiveResourceRemoved(key: AnyKey, r: AnyDropletResource): Unit {
        memoryCache.put(key, r)
    }

    public func onAppear(): Unit {
        getRetriever(dropletContext.ctx).getDeviceLifecycle(LIFECYCLE_KEY_GLOBAL).onAppear()
    }

    public func onAppear(key: String): Unit {
        if (key.isEmpty()) {
            getRetriever(dropletContext.ctx).getDeviceLifecycle(LIFECYCLE_KEY_GLOBAL).onAppear()
        } else {
            getRetriever(dropletContext.ctx).getDeviceLifecycle(key).onAppear()
        }
    }

    public func onDisAppear(): Unit {
        getRetriever(dropletContext.ctx).getDeviceLifecycle(LIFECYCLE_KEY_GLOBAL).onDisAppear()
    }

    public func onDisAppear(key: String): Unit {
        if (key.isEmpty()) {
            getRetriever(dropletContext.ctx).getDeviceLifecycle(LIFECYCLE_KEY_GLOBAL).onDisAppear()
        } else {
            getRetriever(dropletContext.ctx).getDeviceLifecycle(key).onDisAppear()
        }
    }


    func registerRequestManager(requestManager: RequestManager): Unit {
        synchronized (mtxManagers) {
            if (!managers.contains(requestManager)) {
                managers.add(requestManager);
            }
        }
    }

    func unregisterRequestManager(requestManager: RequestManager): Unit {
        synchronized (mtxManagers) {
            if (!managers.contains(requestManager)) {
                throw IllegalStateException("Cannot unregister not yet registered manager");
            }
            managers.remove(requestManager);
        }
    }


    //取消网络请求
    public func cancelHttpRequest(url:String):Unit{
        if(url.size == 0){
            return
        }
        Emitter.emit(url)
    }



}