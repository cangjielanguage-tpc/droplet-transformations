/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet

public class ArrayDeque<K> {
    public var list: ArrayList<K> = ArrayList<K>()

    func offer(k: K): Bool {
        list.add(k)
        return true
    }

    func poll(): Option<K> {
        if(list.size > 0) {
            return Some(list[0])
        }
        return None
    }

    func size(): Int64 {
        return list.size
    }
}