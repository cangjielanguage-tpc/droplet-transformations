/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet

public interface Poolable {
  func offer(): Unit;
}

public class Queue<T> {
  private let list: ArrayList<T>
  private let size: Int64
  public init(size: Int64) {
    list = ArrayList<T>()
    this.size = size
  }

   func poll(): Option<T> {
    
    if(list.size == 0) {
      return None
    } 
    
    return list.remove(at:0)

  }

   func getSize(): Int64 {
    return list.size
  }

   func offer(key: T): Bool {

    if(list.size > this.size) {
      return false
    }

    list.add(key)
    return true
  }
  
}

public abstract class BaseKeyPool<T> where T <: Poolable {
  private static let MAX_SIZE: Int64 = 20;
  private let keyPool: Queue<T> = Queue<T>(MAX_SIZE);

  func get(): T {
     var result: Option<T> = keyPool.poll()
     if(result.isNone()){
        return create()
     }
     return result.getOrThrow()
  }

   func offer(key: T): Unit {
    if (keyPool.getSize() < MAX_SIZE) {
      keyPool.offer(key);
    }
  }

  public func create(): T;
}
