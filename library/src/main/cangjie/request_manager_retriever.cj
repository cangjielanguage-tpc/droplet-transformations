/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet


public class RequestManagerRetriever {

    private var factory: RequestManagerFactory;

    private var lifecycleRequestManagerRetriever: LifecycleRequestManagerRetriever;

    init() {
        this.factory = DefaultRequestManagerFactory()
        lifecycleRequestManagerRetriever = LifecycleRequestManagerRetriever(this.factory);
    }

    func get(context: StageContext, key: String) {
        var droplet: Droplet = Droplet.get(context);
        return lifecycleRequestManagerRetriever.getOrCreate(
            context,
            droplet,
            key,
            true);
    }

    func getDeviceLifecycle(key: String): DeviceLifecycle {
        return lifecycleRequestManagerRetriever.getDeviceLifecycle(key)
    }
}

public class DefaultRequestManagerFactory <: RequestManagerFactory {
    public func build(droplet: Droplet, dropletLifecycle: LifecycleLifecycle, context: StageContext, key: String): RequestManager {
        return RequestManager(droplet, dropletLifecycle, context, key)
    }
}

public interface RequestManagerFactory {
    func build(droplet: Droplet, dropletLifecycle: LifecycleLifecycle, context: StageContext, key: String): RequestManager
}
