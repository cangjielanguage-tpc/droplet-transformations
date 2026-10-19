/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet



public class DropletContext {
    private let mtx = ReentrantMutex()
    private var defaultRequestOptions: Option<RequestOptions> = None
    private let defaultRequestOptionsFactory: RequestOptionsFactory;
    
    public var ctx: StageContext;

    private let manager: Manager = Manager(mtx)

    public var arrayPool: ArrayPool

    public let openGLThreadExcutor:OpenGLThreadExcutor
    public let customMonitorGL:CustomMonitor
    public let customMonitorTask:CustomMonitor
    private let glProcessLock:ReentrantMutex = ReentrantMutex()


    public init(defaultRequestOptionsFactory: RequestOptionsFactory, context: StageContext, arrayPool: ArrayPool) {
        this.defaultRequestOptionsFactory = defaultRequestOptionsFactory
        this.ctx = context
        this.arrayPool = arrayPool
        let glMonitor:Monitor = Monitor()
        this.customMonitorGL = CustomMonitor(glMonitor)
        let taskMonitor:Monitor = Monitor()
        this.customMonitorTask = CustomMonitor(taskMonitor)
        this.openGLThreadExcutor = OpenGLThreadExcutor()
        this.openGLThreadExcutor.openGLStartThread()

    }

     func getDefaultRequestOptions(): RequestOptions {
        synchronized (mtx) {
            if(defaultRequestOptions.isNone()){
                defaultRequestOptions = defaultRequestOptionsFactory.build().lock()
            }
            return defaultRequestOptions.getOrThrow()
        }
    }

     func getManager(): Manager {
        return this.manager
    }

     func getArrayPool(): ArrayPool {
        return arrayPool;
    }

}
