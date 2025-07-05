/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet


public interface LifecycleListener <: Hashable & Equatable<LifecycleListener> {

  func onStart(): Unit;

  func onStop(): Unit;

  func onDestroy(): Unit;
}

public interface Lifecycle {
  func addListener(listener: LifecycleListener): Unit;

  func removeListener(listener: LifecycleListener): Unit;
}

public interface LifecycleObserver <: Hashable & Equatable<LifecycleObserver> {
  func onStart(): Unit

  func onStop(): Unit

  func onDestroy(): Unit
}

public class DeviceLifecycle <: Hashable & Equatable<DeviceLifecycle> {
  public let key: String
  private let state: LifecycleState = LifecycleState()
  private var observer: HashSet<LifecycleObserver> = HashSet<LifecycleObserver>()

  public init(key: String) {
    this.key = key
  }
  
   func getCurrentState(): Int64 {
    return this.state.getCurrentState()
  }

   func isAtLeast(s: Int64): Bool {
    return this.state.isAtLeast(s)
  }

   func setCurrentState(s: Int64): Unit {
    this.state.setCurrentState(s)
  }

   func addObserver(o: LifecycleObserver): Unit {
    this.observer.add(o)
  }

   func removeObserver(o: LifecycleObserver): Unit {
    this.observer.remove(o)
  }

   func onAppear(): Unit {
    setCurrentState(LifecycleState.STATE_STARTED)
    for(o in this.observer) {
      o.onStart()
    }
  }

   func onDisAppear(): Unit {
    setCurrentState(LifecycleState.STATE_DESTROYED)
    let cloneObserve = this.observer.clone()
    for(o in cloneObserve) {
      o.onStop()
      o.onDestroy()
    }
    setCurrentState(LifecycleState.STATE_INITIALIZED)
  }
  
  public operator func ==(right: DeviceLifecycle): Bool {
    return key == right.key
  }
  public operator func !=(right: DeviceLifecycle): Bool {
    return key != right.key
  } 
  public func hashCode(): Int64 {
    return key.hashCode()
  }

}

public class LifecycleState {
  public static var STATE_DESTROYED: Int64 = 0xF1;
  public static var STATE_INITIALIZED: Int64 = 0xF2;
  public static var STATE_CREATED: Int64 = 0xF3;
  public static var STATE_STARTED: Int64 = 0xF4;
  public static var STATE_RESUMED: Int64 = 0xF5;

  public var state: Int64;

   init() {
    this.state = STATE_INITIALIZED
  }

   init(s: Int64) {
    this.state = s
  }

   func getCurrentState(): Int64 {
    return this.state
  }

   func isAtLeast(s: Int64): Bool {
    return (this.state - s) >= 0;
  }

   func setCurrentState(s: Int64): Unit {
    this.state = s
  }

}

public class LifecycleLifecycle <: Lifecycle & LifecycleObserver {
  public var deviceLifecycle: DeviceLifecycle;
  private var lifecycleListeners: HashSet<LifecycleListener> = HashSet<LifecycleListener>();

  public init(deviceLifecycle: DeviceLifecycle) {
    this.deviceLifecycle = deviceLifecycle
    deviceLifecycle.addObserver(this)
  }

  public override func addListener(listener: LifecycleListener): Unit {
    lifecycleListeners.add(listener);

    if (deviceLifecycle.getCurrentState() == LifecycleState.STATE_DESTROYED) {
      listener.onDestroy();
    } else if (deviceLifecycle.isAtLeast(LifecycleState.STATE_STARTED)) {
      listener.onStart();
    } else {
      listener.onStop();
    }
  }

  public override func removeListener(listener: LifecycleListener): Unit {
    lifecycleListeners.remove(listener);
  }

  public func onStart(): Unit {
    for (lifecycleListener in Utils.getSnapshot(lifecycleListeners)) {
      lifecycleListener.onStart();
    }
  }

  public func onStop(): Unit {
    for (lifecycleListener in Utils.getSnapshot(lifecycleListeners)) {
      lifecycleListener.onStop();
    }
  }

  public func onDestroy(): Unit {
    
    for (lifecycleListener in Utils.getSnapshot(lifecycleListeners)) {
      lifecycleListener.onDestroy();
    }
    deviceLifecycle.removeObserver(this)
  }

  public operator func ==(right: LifecycleObserver): Bool {
    if(right is LifecycleLifecycle) {
      return deviceLifecycle == (right as LifecycleLifecycle).getOrThrow().deviceLifecycle
    } else {
      return false
    }
  }
  public operator func !=(right: LifecycleObserver): Bool {
    if(right is LifecycleLifecycle) {
      return deviceLifecycle != (right as LifecycleLifecycle).getOrThrow().deviceLifecycle
    } else {
      return true
    }
  } 
  public func hashCode(): Int64 {
    deviceLifecycle.hashCode()
  }
}