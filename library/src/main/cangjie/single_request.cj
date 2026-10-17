/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet


enum Status {
    /** Created but not yet running. */
    PENDING
    |
        /** In the process of fetching media. */
        RUNNING
    |
        /** Waiting for a callback given to the Target to be called to determine target dimensions. */
        WAITING_FOR_SIZE
    |
        /** Finished loading media successfully. */
        COMPLETE
    |
        /** Failed to load media, may be restarted. */
        FAILED
    |
        /** Cleared by the user with a placeholder set, may be restarted. */
        CLEARED


    operator func ==(that: Status): Bool {
        match ((this, that)) {
            case (PENDING, PENDING) => true
            case (RUNNING, RUNNING) => true
            case (WAITING_FOR_SIZE, WAITING_FOR_SIZE) => true
            case (COMPLETE, COMPLETE) => true
            case (FAILED, FAILED) => true
            case (CLEARED, CLEARED) => true
            case _ => false
        }
    }


    operator func !=(that: Status): Bool {
        !(this == that)
    }


}

public interface AnySingleRequest {
    func getRequestListenersSize(): Int64
    func getRequestLock(): ReentrantMutex
    func getOverrideWidth(): Int64
    func getOverrideHeight(): Int64
    func getModel(): Model
    func getPriority(): Priority
    func getRequestOptions(): AnyRequestOptions
    func getUniqueCode(): Int64
}

/**
 * A {@link Request} that loads a {@link com.bumptech.droplet.load.engine.Resource} into a given
 * {@link Target}.
 *
 * @param <R> The type of the resource that will be transcoded from the loaded resource.
 */
public class SingleRequest<R> <: AnySingleRequest & LoadRequest & SizeReadyCallback & ResourceCallback {
    /** Tag for logging internal events, not generally suitable for public use. */
    private static let TAG: String = "DropletRequest";
    /** Tag for logging externally useful events (request completion, timing etc). */
    private static let DROPLET_TAG: String = "Droplet";

    private static let TARGET_SIZE_ORIGINAL: Int64 = -0x7fffffffffffffff;

    private static var STATIC_UNIQUE_CODE: Int64 = 0;
    private var UNIQUE_CODE: Int64 = 0

    private let stateVerifier: StateVerifier = StateVerifier.newInstance();

    /* Variables mutated only when a request is initialized or returned to the object pool. */
    private let requestLock: ReentrantMutex

    private let targetListener: RequestListener<R>

    private let requestCoordinator: Option<RequestCoordinator>

    private let context: StageContext

    private let dropletContext: DropletContext

    private let model: Model

    private let transcodeTypeClass: TransformationKey

    private let requestOptions: AnyRequestOptions

    private let overrideWidth: Int64

    private let overrideHeight: Int64

    private let priority: Priority

    private let target: Target<R>

    private let requestListeners: ArrayList<RequestListener<R>>

    private var resource: Option<DropletResource<R>> = None;

    private var loadStatus: Option<LoadStatus> = None;

    // Volatile because it's accessed outside of a lock and nullable, even though in practice it will
    // always be non-null unless the request is in the object pool.

    private var engine: Engine

    /* Variables mutated during a request. */
    private var status: Status
    private var errorDrawable: Option<CJResourceDrawable> = None;
    private var placeholderDrawable: Option<CJResourceDrawable> = None;
    private var fallbackDrawable: Option<CJResourceDrawable> = None;
    private var width: Int64 = 0;
    private var height: Int64 = 0;
    private var isCallingCallbacks: Bool = false;

    func isEquivalentTo(o: SingleRequest<R>): Bool {
        if (!(o is AnySingleRequest)) {
            return false;
        }

        var localOverrideWidth: Int64 = 0;
        var localOverrideHeight: Int64 = 0;
        var localModel: Model

        // TODO TranscodeTypeClass
        var localRequestOptions: AnyRequestOptions
        var localPriority: Priority
        var localListenerCount: Int64 = 0;
        synchronized(requestLock) {
            localOverrideWidth = overrideWidth
            localOverrideHeight = overrideHeight
            localModel = model
            localRequestOptions = requestOptions
            localPriority = priority
            localListenerCount = requestListeners.size
        }

        var other: AnySingleRequest = (o as AnySingleRequest).getOrThrow();
        var otherLocalOverrideWidth: Int64 = 0;
        var otherLocalOverrideHeight: Int64 = 0;
        var otherLocalModel: Model
        // TODO TranscodeTypeClass
        var otherLocalRequestOptions: AnyRequestOptions
        var otherLocalPriority: Priority
        var otherLocalListenerCount: Int64 = 0;
        synchronized(other.getRequestLock()) {
            otherLocalOverrideWidth = other.getOverrideWidth()
            otherLocalOverrideHeight = other.getOverrideHeight()
            otherLocalModel = other.getModel()
            otherLocalRequestOptions = other.getRequestOptions()
            otherLocalPriority = other.getPriority()
            otherLocalListenerCount = other.getRequestListenersSize()
        }

        // If there's ever a case where synchronization matters for these values, something else has
        // gone wrong. It indicates that we'er comparing at least one recycled object, which has to be
        // protected against via other means. None of these values changes aside from object re-use.
        return localOverrideWidth == otherLocalOverrideWidth
            && localOverrideHeight == otherLocalOverrideHeight
            && localModel == otherLocalModel
            // TODO TranscodeTypeClass
            && localRequestOptions.equals(otherLocalRequestOptions)
            && localPriority == otherLocalPriority
            && localListenerCount == otherLocalListenerCount;
    }

    public operator func ==(that: ResourceCallback): Bool {
        if (that is SingleRequest<R>) {
            let other = (that as SingleRequest<R>).getOrThrow()
            return equals(other)
        }
        return false
    }

    public operator func !=(that: ResourceCallback): Bool {
        if (that is SingleRequest<R>) {
            let other = (that as SingleRequest<R>).getOrThrow()
            return !equals(other)
        }
        return true
    }


    public static func obtain<R2>(
        context: StageContext,
        dropletContext: DropletContext,
        requestLock: ReentrantMutex,
        model: Model,
        transcodeTypeClass: TransformationKey,
        requestOptions: AnyRequestOptions,
        overrideWidth: Int64,
        overrideHeight: Int64,
        priority: Priority,
        target: Target<R2>,
        targetListener: RequestListener<R2>,
        requestListeners: ArrayList<RequestListener<R2>>,
        requestCoordinator: Option<RequestCoordinator>,
        engine: Engine
    ): SingleRequest<R2> {
        return SingleRequest<R2>(
            context,
            dropletContext,
            requestLock,
            model,
            transcodeTypeClass,
            requestOptions,
            overrideWidth,
            overrideHeight,
            priority,
            target,
            targetListener,
            requestListeners,
            requestCoordinator,
            engine
        );
    }

    // We are in fact locking on the same lock that will be used for all subsequent method calls.
    public init(
        context: StageContext,
        dropletContext: DropletContext,
        requestLock: ReentrantMutex,
        model: Model,
        transcodeTypeClass: TransformationKey,
        requestOptionscj: AnyRequestOptions,
        overrideWidth: Int64,
        overrideHeight: Int64,
        priority: Priority,
        targetcj: Target<R>,
        targetListener: RequestListener<R>,
        requestListeners: ArrayList<RequestListener<R>>,
        requestCoordinatorcj: Option<RequestCoordinator>,
        engine: Engine
    ) {
        this.requestLock = requestLock
        this.context = context
        this.dropletContext = dropletContext
        this.model = model
        this.transcodeTypeClass = transcodeTypeClass
        this.requestOptions = requestOptionscj
        this.overrideWidth = overrideWidth
        this.overrideHeight = overrideHeight
        this.priority = priority
        this.target = targetcj
        this.targetListener = targetListener
        this.requestListeners = requestListeners
        this.requestCoordinator = requestCoordinatorcj
        this.engine = engine
        status = Status.PENDING

        UNIQUE_CODE = STATIC_UNIQUE_CODE
        STATIC_UNIQUE_CODE = STATIC_UNIQUE_CODE + 1
    }

    public func getRequestListenersSize(): Int64 {
        return requestListeners.size
    }

    public func getRequestLock(): ReentrantMutex {
        return requestLock
    }

    public func getOverrideWidth(): Int64 {
        return overrideWidth
    }

    public func getOverrideHeight(): Int64 {
        return overrideHeight
    }

    public func getModel(): Model {
        return model
    }

    public func getPriority(): Priority {
        return priority
    }

    public func getRequestOptions(): AnyRequestOptions {
        return requestOptions
    }

    public override func begin(): Unit {
        synchronized(requestLock) {
            stateVerifier.throwIfRecycled()

            if(status == Status.RUNNING){
                throw IllegalArgumentException("Cannot restart a running request")
            }

            if(status == Status.COMPLETE){
                onResourceReady((resource.getOrThrow() as AnyDropletResource), DataSource.MEMORY_CACHE, /* isLoadedFromAlternateCacheKey= */ false)
                return
            }

            // Restarts for requests that are neither complete nor running can be treated as new requests
            // and can run again from the beginning.
            // 非完成和未开始的请求重新启动视为新请求  droplet暂时不用废弃
            status = Status.WAITING_FOR_SIZE
            if (Utils.isValidDimensions(overrideWidth, overrideHeight)) {
                onSizeReady(overrideWidth, overrideHeight);
            } else {
                target.getSize(this);
            }

            let ffff = match (status) {
                case Status.RUNNING => "RUNNING"
                case Status.WAITING_FOR_SIZE => "WAITING_FOR_SIZE"
                case Status.COMPLETE => "COMPLETE"
                case Status.FAILED => "FAILED"
                case Status.CLEARED => "CLEARED"
                case _ => "OTHER"
            }
            AppLog.error("single request begin: ${ffff} ----  ${canNotifyStatusChanged()}")
            if ((match (status) {
                case Status.RUNNING | Status.WAITING_FOR_SIZE => true
                case _ => false
            }) && canNotifyStatusChanged()) {
                let d: Option<CJResourceDrawable> = getPlaceholderDrawable()
                if(let Some(i) <- d){
                    target.onLoadStarted(i)
                }else{
                    target.onLoadStarted(Option<CJResourceDrawable>.None)
                }
            }
        }
    }

    /**
     * Cancels the current load but does not release any resources held by the request and continues
     * to display the loaded resource if the load completed before the call to cancel.
     *
     * <p>Cancelled requests can be restarted with a subsequent call to {@link #begin()}.
     *
     * @see #clear()
     */
    private func cancel(): Unit {
        stateVerifier.throwIfRecycled();
        target.removeCallback();

        // TODO Engine
        if(let Some(i) <- loadStatus){
            i.cancel()
            loadStatus = None
        }
    }



    /**
     * Cancels the current load if it is in progress, clears any resources held onto by the request
     * and replaces the loaded resource if the load completed with the placeholder.
     *
     * <p>Cleared requests can be restarted with a subsequent call to {@link #begin()}
     *
     * @see #cancel()
     */
    public override func clear(): Unit {
        var toRelease: Option<DropletResource<R>> = None;
        synchronized(requestLock) {
            stateVerifier.throwIfRecycled();

            let ffff = match (status) {
                case Status.RUNNING => "RUNNING"
                case Status.WAITING_FOR_SIZE => "WAITING_FOR_SIZE"
                case Status.COMPLETE => "COMPLETE"
                case Status.FAILED => "FAILED"
                case Status.CLEARED => "CLEARED"
                case _ => "OTHER"
            }
            if(status == Status.CLEARED){
                return
            }
            cancel()
            // Resource must be released before canNotifyStatusChanged is called.
            if(let Some(i) <- resource){
                toRelease = resource
                resource = None
            }
            if (canNotifyCleared()) {
                target.onLoadCleared(getPlaceholderDrawable())
            }

            status = Status.CLEARED
        }
        if(let Some(i) <- toRelease){
             engine.release(i)
        }
    }

    public override func pause(): Unit {
        synchronized(requestLock) {
            if (isRunning()) {
                clear()
            }
        }
    }

    public override func isRunning(): Bool {
        synchronized(requestLock) {
            return (match (status) {
                case Status.RUNNING => true
                case _ => false
            } || match (status) {
                case Status.WAITING_FOR_SIZE => true
                case _ => false
            })
        }
    }

    public override func isComplete(): Bool {
        synchronized(requestLock) {
            return match (status) {
                case Status.COMPLETE => true
                case _ => false
            }
        }
    }

    public override func isCleared(): Bool {
        synchronized(requestLock) {
            return match (status) {
                case Status.CLEARED => true
                case _ => false
            }
        }
    }

    public override func isAnyResourceSet(): Bool {
        synchronized(requestLock) {
            return match (status) {
                case Status.COMPLETE => true
                case _ => false
            }
        }
    }

    func getErrorDrawable(): Option<CJResourceDrawable> {
        return requestOptions.getErrorPlaceholderDrawable();
    }

    func getPlaceholderDrawable(): Option<CJResourceDrawable> {
        return requestOptions.getPlaceholderDrawable();
    }


    func setErrorPlaceholder(): Unit {
        if (!canNotifyStatusChanged()) {
            return
        }

        var error: Option<CJResourceDrawable> = None
        // Either the model isn't null, or there was no fallback drawable set.

        if(error.isNone()){
            error = getErrorDrawable()
        }
        // The model isn't null, no fallback drawable was set or no error drawable was set.
        if(error.isNone()){
           error = getPlaceholderDrawable()
        }

        if(let Some(i) <- error){
            target.onLoadFailed(Some(i))
        }else{
            target.onLoadFailed(Option<CJResourceDrawable>.None)
        }
    }

    /** A callback method that should never be invoked directly. */
    public override func onSizeReady(width: Int64, height: Int64): Unit {
        stateVerifier.throwIfRecycled()
        synchronized(requestLock) {

            if(status != Status.WAITING_FOR_SIZE){
                return
            }

            status = Status.RUNNING

            var sizeMultiplier: Float32 = requestOptions.getSizeMultiplier()
            this.width = maybeApplySizeMultiplier(width, sizeMultiplier)
            this.height = maybeApplySizeMultiplier(height, sizeMultiplier)

            // TODO Engine
            loadStatus = engine.load(
                dropletContext,
                requestOptions.getSignature(),
                model,
                this.width,
                this.height,
                requestOptions.getResourceTypeClass(),
                transcodeTypeClass,
                requestOptions.getDiskCacheStrategy(),
                requestOptions.getTransformations(),
                requestOptions.getTransformationRequired(),
                requestOptions.getScaleOnlyOrNoTransform(),
                requestOptions.getOptions(),
                requestOptions.getCacheable(),
                requestOptions.getOnlyRetrieveFromCache(),
                requestOptions.getPlaceHolderFunc(),
                requestOptions.getPlaceholderDrawable(),
                this
            )

            // This is a hack that's only useful for testing right now where loads complete synchronously
            // even though under any executor running on any thread but the main thread, the load would
            // have completed asynchronously.
            // 这是一个现在只对测试加载同步完成有用的破解，即使在除主线程外的任何线程上运行的任何执行器下，加载都会异步完成。
            if(status != Status.RUNNING){
                loadStatus = None
            }
        }
    }

    private static func maybeApplySizeMultiplier(size: Int64, sizeMultiplier: Float32): Int64 {
        return if (size == TARGET_SIZE_ORIGINAL) {
            size
        } else {
            Int64(round(sizeMultiplier * Float32(size)))
        }
    }

    private func canSetResource(): Bool {
        if(requestCoordinator.isNone()){
            return true
        }
        return requestCoordinator.getOrThrow().canSetImage(this);
    }

    private func canNotifyCleared(): Bool {
        if(requestCoordinator.isNone()){
            return true
        }
        return requestCoordinator.getOrThrow().canNotifyCleared(this)
    }

    private func canNotifyStatusChanged(): Bool {
        if(requestCoordinator.isNone()){
            return true
        }
        return requestCoordinator.getOrThrow().canNotifyStatusChanged(this)
    }

    private func isFirstReadyResource(): Bool {
        if(requestCoordinator.isNone()){
             return true
        }
        return !requestCoordinator.getOrThrow().getRoot().isAnyResourceSet()
    }

    private func notifyRequestCoordinatorLoadSucceeded(): Unit {
        if(let Some(i) <- requestCoordinator){
           i.onRequestSuccess(this)
        }
    }

    private func notifyRequestCoordinatorLoadFailed(): Unit {
        if(let Some(i) <- requestCoordinator){
            i.onRequestFailed(this)
        }
    }

    /** A callback method that should never be invoked directly. */
    public override func onResourceReady(resource: Option<AnyDropletResource>, dataSource: DataSource,
        _: Bool): Unit {
        stateVerifier.throwIfRecycled();

        let fff = match (status) {
            case Status.RUNNING => "RUNNING"
            case Status.WAITING_FOR_SIZE => "WAITING_FOR_SIZE"
            case Status.COMPLETE => "COMPLETE"
            case Status.FAILED => "FAILED"
            case Status.CLEARED => "CLEARED"
            case _ => "OTHER"
        }

        var toRelease: Option<AnyDropletResource> = None;
        synchronized(requestLock) {
            try {
                if(resource.isNone()){
                    // TODO onLoadFailed
                    var exception: DropletException = DropletException("Expected to receive a Resource<R> with an object of ${transcodeTypeClass} inside, but instead got null.")
                    onLoadFailed(exception)
                    return
                }
                var received: Any = resource.getOrThrow().getAsAny();
                // TODO 解码类型和资源类型不同的情况 正常应该执行不到
                if (!canSetResource()) {
                    toRelease = resource
                    this.resource = None
                    // We can't put the status to complete before asking canSetResource().
                    status = Status.COMPLETE
                    return
                }
                let a: Option<DropletResource<R>> = resource.getOrThrow() as DropletResource<R>
                var b: Option<R> = received as R
                // transcode
                var s: Option<InputStream> = None
                var g: Option<GifDrawable> = None
                var pixelMap: Option<PixelMap> = None
                if (received is PixelMap) {
                    pixelMap = received as PixelMap
                } else if (received is InputStream) {
                    s = received as InputStream
                } else if (received is GifDrawable) {
                    g = received as GifDrawable
                    if (transcodeTypeClass == TransformationKey(TransformationKey.TRANSFORMATION_PIXELMAP)) {
                        pixelMap = Some(g.getOrThrow().getCurrentFrame())
                    }
                }
                // 文件下载

                if(let Some(kk) <- s){
                     if (transcodeTypeClass == TransformationKey(TransformationKey.TRANSFORMATION_PIXELMAP)) {
                        let inputStream: InputStream = kk
                        var size = match (inputStream as Seekable) {
                            case Some(v) => v.length
                            case None => 0
                        }
                        let buf: Array<UInt8> = Array<UInt8>(size, repeat: 0)
                        inputStream.read(buf)
                    }
                }
                // 图片显示
                if(let Some(i) <- pixelMap){
                     b = i as R
                }
                onResourceReady(a, b.getOrThrow(), dataSource)
            } finally {
                // TODO engine
                if(let Some(i) <- toRelease){
                     engine.release(i)
                }
            }
        }
    }

    private func onResourceReady(resource: Option<DropletResource<R>>, result: R, dataSource: DataSource): Unit {
        // We must call isFirstReadyResource before setting status.
        var isFirstResource: Bool = isFirstReadyResource();
        status = Status.COMPLETE
        this.resource = resource

        notifyRequestCoordinatorLoadSucceeded();

        isCallingCallbacks = true
        try {
            var anyListenerHandledUpdatingTarget: Bool = false;

            if (!requestListeners.isEmpty()) {
                for (listener in requestListeners) {
                    if (listener.onResourceReady(result, model, target, dataSource, isFirstResource)) {
                        anyListenerHandledUpdatingTarget = true
                    }
                }
            }

            if (targetListener.onResourceReady(result, model, target, dataSource, isFirstResource)) {
                anyListenerHandledUpdatingTarget = true
            }

            if (!anyListenerHandledUpdatingTarget) {
                let t: Option<DrawableTransition> = None
                target.onResourceReady(result, t);
            }
        } finally {
            isCallingCallbacks = false
        }

    }

    /** A callback method that should never be invoked directly. */
    public override func onLoadFailed(e: DropletException): Unit {
        onLoadFailed(e, 0);
    }

    public override func getLock(): ReentrantMutex {
        stateVerifier.throwIfRecycled();
        return requestLock;
    }

    private func onLoadFailed(e: DropletException, _: Int64) {
        stateVerifier.throwIfRecycled();
        synchronized(requestLock) {

            loadStatus = None
            status = Status.FAILED

            notifyRequestCoordinatorLoadFailed();

            isCallingCallbacks = true
            try {
                // TODO: what if this is a thumbnail request?
                var anyListenerHandledUpdatingTarget: Bool = false;
                if (!requestListeners.isEmpty()) {
                    for (listener in requestListeners) {
                        if (listener.onLoadFailed(e, model, target, isFirstReadyResource())) {
                            anyListenerHandledUpdatingTarget = true
                        }
                    }
                }

                if (targetListener.onLoadFailed(e, model, target, isFirstReadyResource())) {
                    anyListenerHandledUpdatingTarget = true
                }

                if (!anyListenerHandledUpdatingTarget) {
                    setErrorPlaceholder();
                }
            } finally {
                isCallingCallbacks = false
            }
        }
    }

    public override func isEquivalentTo(loadRequest: LoadRequest): Bool {
        if (!(loadRequest is AnySingleRequest)) {
            return false
        }
        var localOverrideWidthlr: Int64 = 0
        var localOverrideHeightlr: Int64 = 0
        var localModellr: Model

        // TODO TranscodeTypeClass
        var localRequestOptionslr: AnyRequestOptions
        var localPrioritylr: Priority
        var localListenerCountlr: Int64 = 0
        synchronized(requestLock) {
            localOverrideWidthlr = overrideWidth
            localOverrideHeightlr = overrideHeight
            localModellr = model
            localRequestOptionslr = requestOptions
            localPrioritylr = priority
            localListenerCountlr = requestListeners.size
        }

        var otherlr: AnySingleRequest = (loadRequest as AnySingleRequest).getOrThrow();
        var otherLocalOverrideWidthlr: Int64 = 0
        var otherLocalOverrideHeightlr: Int64 = 0
        var otherLocalModellr: Model
        // TODO TranscodeTypeClass
        var otherLocalRequestOptionslr: AnyRequestOptions
        var otherLocalPrioritylr: Priority
        var otherLocalListenerCountlr: Int64 = 0
        synchronized(otherlr.getRequestLock()) {
            otherLocalOverrideWidthlr = otherlr.getOverrideWidth()
            otherLocalOverrideHeightlr = otherlr.getOverrideHeight()
            otherLocalModellr = otherlr.getModel()
            otherLocalRequestOptionslr = otherlr.getRequestOptions()
            otherLocalPrioritylr = otherlr.getPriority()
            otherLocalListenerCountlr = otherlr.getRequestListenersSize()
        }

        // If there's ever a case where synchronization matters for these values, something else has
        // gone wrong. It indicates that we'er comparing at least one recycled object, which has to be
        // protected against via other means. None of these values changes aside from object re-use.
        return localOverrideWidthlr == otherLocalOverrideWidthlr
            && localOverrideHeightlr == otherLocalOverrideHeightlr
            && localModellr == otherLocalModellr
            // TODO TranscodeTypeClass
            && localRequestOptionslr.equals(otherLocalRequestOptionslr)
            && localPrioritylr == otherLocalPrioritylr
            // We do not want to require that RequestListeners implement equals/hashcode, so we
            // don't compare them using equals(). We can however, at least assert that the same
            // amount of request listeners are present in both requests.
            && localListenerCountlr == otherLocalListenerCountlr
    }

    public func getUniqueCode(): Int64 {
        return UNIQUE_CODE
    }

    public func equals(that: LoadRequest): Bool {
        if (!(that is AnySingleRequest)) {
            return false;
        }
        let aa = isEquivalentTo(that)
        let bb = (UNIQUE_CODE == (that as AnySingleRequest).getOrThrow().getUniqueCode())
        return aa && bb
    }


    // TODO
    public func toString(): String {
        return "[model=TODO, transcodeClass=TODO] UNIQUE_CODE=${UNIQUE_CODE}"
    }

    public override func hashCode(): Int64 {
        return toString().hashCode()
    }

    public operator func ==(that: LoadRequest): Bool {
        return equals(that)
    }

    public operator func !=(that: LoadRequest): Bool {
        return !equals(that)
    }
}
