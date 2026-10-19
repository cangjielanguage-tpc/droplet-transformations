/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet

public class SafeKeyGenerator {
    private var loadIdToSafeHash: LruCache<AnyKey, DropletString> = LruCache<AnyKey, DropletString>(1000)
    private static let md5: MD5 = MD5()
    private let mtx = ReentrantMutex()
    private let mtxLoadIdToSafeHash = ReentrantMutex()

     func getSafeKey(key: AnyKey): String {
        var safeKey: Option<DropletString> = None
        synchronized (mtxLoadIdToSafeHash) {
          safeKey = loadIdToSafeHash.get(key)
        }
        if(safeKey.isNone()){
            let str = calculateHexStringDigest(key)
            let dropletStr = DropletString(str)
            safeKey = dropletStr
        }
        synchronized (mtxLoadIdToSafeHash) {
          loadIdToSafeHash.put(key, safeKey.getOrThrow())
        }
        return safeKey.getOrThrow().str
        
    }

    private func calculateHexStringDigest(key: AnyKey): String {
      // md5
      synchronized (mtx) {
        md5.MD5Init() 
        key.updateDiskCacheKey(md5)
        return md5.getStringValue()
      }
    }
}

public class WriteLock <: Equatable<WriteLock> {

  private let lock = ReentrantMutex();
  public var interestedThreads: Int64 = 0;

   func getMtx():ReentrantMutex{
        return lock
  }

  public operator func ==(that: WriteLock): Bool {
    return this.interestedThreads == that.interestedThreads
  }

  public operator func !=(that: WriteLock): Bool {
    return this.interestedThreads != that.interestedThreads
  }

}

public class WriteLockPool {
  private static let MAX_POOL_SIZE: Int64 = 10
  private let pool: ArrayDeque<WriteLock> = ArrayDeque<WriteLock>()
  private let mtx = ReentrantMutex()

   func obtain(): WriteLock {
    var result: Option<WriteLock>
    synchronized (mtx) {
      result = pool.poll()
    }
    if(result.isNone()){
        return WriteLock()
    }
    return result.getOrThrow()
  }

   func offer(writeLock: WriteLock): Unit {
    synchronized (mtx) {
      if (pool.size() < MAX_POOL_SIZE) {
        pool.offer(writeLock)
      }
    }
  }
}
