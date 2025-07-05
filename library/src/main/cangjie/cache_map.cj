/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet

public class CacheMap<K, V> <: CustomMap<K, V> where K <: Hashable & ToString & Equatable<K>, V <: ToString & Equatable<V> {

}
