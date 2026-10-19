/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet


/**
* RequestManager查找器
*/
public class LifecycleRequestManagerRetriever {
    private let lifecycleToRequestManager: HashMap<String, RequestManager> = HashMap<String, RequestManager>();
    private let deviceLifecycleMap: HashMap<String, DeviceLifecycle> = HashMap<String, DeviceLifecycle>()

    private var factory: RequestManagerFactory;

    public init(factory: RequestManagerFactory) {
        this.factory = factory
    }

     func getDeviceLifecycle(key: String): DeviceLifecycle {
        let deviceLifecycle: Option<DeviceLifecycle> = deviceLifecycleMap.get(key)
        if(deviceLifecycle.isNone()){
            let deviceLifecycleObj: DeviceLifecycle = DeviceLifecycle(key)
            deviceLifecycleMap.add(key, deviceLifecycleObj)
            return deviceLifecycleObj
        }
        return deviceLifecycle.getOrThrow()
    }

     func getOrCreate(
        context: StageContext,
        droplet: Droplet,
        key: String,
        isParentVisible: Bool): RequestManager {

        var managerKey: String = Utils.getRequestManagerKey(key)

        var result: Option<RequestManager> = lifecycleToRequestManager.get(managerKey)

        if(result.isNone()){
            let deviceLifecycle = getDeviceLifecycle(key)
            var dropletLifecycle: LifecycleLifecycle = LifecycleLifecycle(deviceLifecycle)
            result = factory.build(droplet,dropletLifecycle,context,managerKey)
            lifecycleToRequestManager.add(managerKey, result.getOrThrow())
            dropletLifecycle.addListener(DefaultLifecycleListener(lifecycleToRequestManager, managerKey,deviceLifecycleMap,key))

            // This is a bit of hack, we're going to start the RequestManager, but not the
            // corresponding Lifecycle. It's safe to start the RequestManager, but starting the
            // Lifecycle might trigger memory leaks. See b/154405040
            if (isParentVisible) {
                result.getOrThrow().onStart()
            }
        }
        return result.getOrThrow()
    }
    
}

public class DefaultLifecycleListener <: LifecycleListener {

    public var lifecycleToRequestManager: HashMap<String, RequestManager>;

    public var requestManagerKey: String

    public var deviceLifecycleMap: HashMap<String, DeviceLifecycle>;

    public var key: String

    public init(lifecycleToRequestManager: HashMap<String, RequestManager>, requestManagerKey: String,deviceLifecycleMap:HashMap<String, DeviceLifecycle>,key:String) {
        this.lifecycleToRequestManager = lifecycleToRequestManager
        this.requestManagerKey = requestManagerKey
        this.deviceLifecycleMap = deviceLifecycleMap
        this.key = key
    }

    public override func onStart(): Unit {
    }

    public override func onStop(): Unit {
    }

    public override func onDestroy(): Unit {
        this.lifecycleToRequestManager.remove(requestManagerKey);
        this.deviceLifecycleMap.remove(key)
    }

    public override func hashCode(): Int64 {
        return requestManagerKey.hashCode()
    }

    public operator func ==(that: LifecycleListener): Bool {
        if(that is DefaultLifecycleListener) {
            return this.requestManagerKey == (that as DefaultLifecycleListener).getOrThrow().requestManagerKey
        }
        return false
    }

    public operator func !=(that: LifecycleListener): Bool {
        if(that is DefaultLifecycleListener) {
            return this.requestManagerKey != (that as DefaultLifecycleListener).getOrThrow().requestManagerKey
        }
        return true
    }
}
