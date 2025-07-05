/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2025. All rights reserved.
 */
 
package droplet

public class ResourceCacheGenerator <: DataFetcherGenerator {

  private let cb: FetcherReadyCallback;
  private let helper: DecodeHelper;

  private var sourceKey: Option<AnyKey> = None;
  private var cacheFile: Option<DropletFile> = None;

  private var currentKey: Option<ResourceCacheKey> = None;

  public init(helper: DecodeHelper, cb: FetcherReadyCallback) {
    this.helper = helper;
    this.cb = cb;
  }

  public func startNext(): Bool {
    synchronized (DecodeJob.mtx){
    try {
    let transformationKey: TransformationKey = helper.getTransformationKey()
    // 查询缓存
    let a = helper.getTransformation(transformationKey)
    currentKey = Some(ResourceCacheKey( // NOPMD AvoidInstantiatingObjectsInLoops
                helper.getArrayPool(),
                ModelKey(helper.getModel()),
                helper.getSignature(),
                helper.getWidth(),
                helper.getHeight(),
                helper.getTransformation(transformationKey).getOrThrow(),
                transformationKey,
                helper.getOptions()));

        cacheFile = helper.getDiskCache().get(currentKey.getOrThrow());


        if(let Some(i) <- cacheFile){
            // cacheFile to inputstream
            let outStream: ByteBufferes = i.toByteBuffer()
            // TODO 关闭 or seek
            cb.onDataFetcherReady(ModelKey(helper.getModel()), outStream, DataSource.RESOURCE_DISK_CACHE);
            return true
        }

      return false;
    } finally {
    }
   }
  }

  public func cancel(): Unit {
  }

   func onDataReady(data: Any): Unit {
      cb.onDataFetcherReady(sourceKey.getOrThrow(), Some(data), DataSource.RESOURCE_DISK_CACHE);
    }

   func onLoadFailed(_: DropletException): Unit {
    cb.onDataFetcherFailed();

  }
}
