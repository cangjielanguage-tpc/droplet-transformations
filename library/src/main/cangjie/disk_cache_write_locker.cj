/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package droplet

public class DiskCacheWriteLocker {
  private let locks: HashMap<String, WriteLock> = HashMap<String, WriteLock>();
  private let writeLockPool: WriteLockPool = WriteLockPool();
  private let mtx = ReentrantMutex()

   func acquire(safeKey: String) {
    var writeLock: Option<WriteLock>
    synchronized (mtx) {
      writeLock = locks.get(safeKey)
      if(writeLock.isNone()){
          writeLock = writeLockPool.obtain()
          locks.add(safeKey, writeLock.getOrThrow())
      }
      writeLock.getOrThrow().interestedThreads++
    }
    writeLock.getOrThrow().getMtx().lock()
  }

   func release(safeKey: String): Unit {
    var writeLock: Option<WriteLock>
    synchronized (mtx) {
      writeLock = locks.get(safeKey)
      if(let Some(i) <- writeLock){
            if (i.interestedThreads < 1) {
                throw Exception("Cannot release a lock that is not held safeKey: ${safeKey}, interestedThreads: ${writeLock.getOrThrow().interestedThreads}");
            }
            i.interestedThreads--
            if (i.interestedThreads == 0) {
                var removed: Option<WriteLock> = locks.remove(safeKey)
                if (!(removed.getOrThrow() == i)) {
                  throw Exception("droplet error: Removed the wrong lock")
                }
                writeLockPool.offer(removed.getOrThrow())
            }
      }else{
         throw Exception("droplet error: release --- writeLock is null")
      }
    }
    writeLock.getOrThrow().getMtx().unlock()
  }
}
