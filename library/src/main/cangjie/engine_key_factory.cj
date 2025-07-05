/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet

public class EngineKeyFactory {

   func buildKey(
      model: Model,
      signature: AnyKey,
      width: Int64,
      height: Int64,
      transformations: CachedHashCodeArrayMap<TransformationKey, AnyKey>,
      resourceTypeClass: ResourceTypeClass,
      transformationKey: TransformationKey,
      options: DropletOptions): EngineKey {
    return EngineKey(model, signature, width, height, transformations, resourceTypeClass, transformationKey, options);
  }
}
