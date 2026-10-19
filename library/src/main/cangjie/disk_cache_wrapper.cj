/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2025. All rights reserved.
 */
 
package droplet


public class DiskLruCacheWrapper <: DiskCache {
    private static let TAG: String = "DiskLruCacheWrapper"

    private static let APP_VERSION: Int64 = 1
    private static let VALUE_COUNT: Int64 = 1
    private static var wrapper: Option<DiskLruCacheWrapper> = None

    private let safeKeyGenerator: SafeKeyGenerator
    private var directory: DropletFile
    private let maxSize: Int64

    private let writeLocker: DiskCacheWriteLocker = DiskCacheWriteLocker()
    private var diskLruCache: Option<DiskLruCache> = None


    private static let mtx = ReentrantMutex()

  /**
   * Get a DiskCache in the given directory and size. If a disk cache has already been created with
   * a different directory and/or size, it will be returned instead and the new arguments will be
   * ignored.
   *
   * @param directory The directory for the disk cache
   * @param maxSize The max size for the disk cache
   * @return The new disk cache with the given arguments, or the current cache if one already exists
   * @deprecated Use {@link #create(File, long)} to create a new cache with the specified arguments.
   */
    static func getStatic(directory: DropletFile, maxSize: Int64): DiskCache {
    // TODO calling twice with different arguments makes it return the cache for the same
    // directory, it's public!
        synchronized(mtx) {
            if (wrapper.isNone()) {
                wrapper = DiskLruCacheWrapper(directory, maxSize)
            }
            return wrapper.getOrThrow()
        }
    }

    /**
    * Create a new DiskCache in the given directory with a specified max size.
    *
    * @param directory The directory for the disk cache
    * @param maxSize The max size for the disk cache
    * @return The new disk cache with the given arguments
    */
    static func create(directory: DropletFile, maxSize: Int64): DiskCache {
        return DiskLruCacheWrapper(directory, maxSize)
    }

  /**
   * @deprecated Do not extend this class.
   */
    init(directory: DropletFile, maxSize: Int64) {
        this.directory = directory
        this.maxSize = maxSize
        this.safeKeyGenerator = SafeKeyGenerator()
    }

    private func getDiskCache(): DiskLruCache {
        synchronized(mtx) {
            if (diskLruCache.isNone()) {
                diskLruCache = DiskLruCache.openStatic(directory, APP_VERSION, VALUE_COUNT, maxSize)
            }
            return diskLruCache.getOrThrow()
        }
    }

    public func get(key: AnyKey): Option<DropletFile> {
        var safeKey: String = safeKeyGenerator.getSafeKey(key)
        var result: Option<DropletFile> = None
        try {
            // It is possible that the there will be a put in between these two gets. If so that shouldn't
            // be a problem because we will always put the same value at the same key so our input streams
            // will still represent the same data.
            let value: Option<Value> = getDiskCache().get(safeKey)
            if(let Some(i) <- value){
                 result = i.getFile(0)
            }
        } catch (e: Exception) {
        }
        return result
    }

    public func put(key: AnyKey, writer: DiskCacheWriter): Unit {
        // We want to make sure that puts block so that data is available when put completes. We may
        // actually not write any data if we find that data is written by the time we acquire the lock.
        var safeKey: String = safeKeyGenerator.getSafeKey(key)
        writeLocker.acquire(safeKey)
        try {
            // We assume we only need to put once, so if data was written while we were trying to get
            // the lock, we can simply abort.
            var diskCache: DiskLruCache = getDiskCache()
            var current: Option<Value> = diskCache.get(safeKey)
            if (current.isSome()) {
                 return
            }
            var editor: Option<Editor> = diskCache.edit(safeKey)
            if (let Some(i) <- editor) {
                try {
                    var file: DropletFile = i.getFile(0)
                    if (writer.write(file)) {
                        i.commit()
                    }
                } finally {
                    i.abortUnlessCommitted()
                }
            } else {
                throw Exception("droplet error: Had two simultaneous puts for: " + safeKey);
            }
        } catch (e: Exception) {
            AppLog.error("droplet exception: Unable to put to disk cache ${e}")
        } finally {
            writeLocker.release(safeKey)
        }
    }

    public func delete(key: AnyKey): Unit {
        var safeKey: String = safeKeyGenerator.getSafeKey(key);
        try {
            getDiskCache().remove(safeKey);
        } catch (e: Exception) {
            AppLog.error("droplet error: Unable to delete from disk cache")
        }
    }

    public func clear(): Unit {
        synchronized(mtx) {
            try {
                getDiskCache().delete();
            } catch (e: Exception) {
                AppLog.error("Unable to clear disk cache or disk cache cleared externally")
            } finally {
            // Delete can close the cache but still throw. If we don't null out the disk cache here, every
            // subsequent request will try to act on a closed disk cache and fail. By nulling out the disk
            // cache we at least allow for attempts to open the cache in the future. See #2465.
                resetDiskCache()
            }
        }
    }

    private func resetDiskCache(): Unit {
        synchronized(mtx) {
            diskLruCache = None
        }
    }
}
