/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2025. All rights reserved.
 */
 
package droplet

public class DataCacheKey <: AnyKey {

    private let sourceKey: AnyKey
    private let signature: AnyKey

    public init(sourceKey: AnyKey, signature: AnyKey) {
        this.sourceKey = sourceKey
        this.signature = signature
    }

    func getSourceKey(): AnyKey {
        return sourceKey
    }

    public func equals(o: AnyKey): Bool {
        if(let Some(other) <- (o as DataCacheKey)){
            return sourceKey == other.sourceKey && signature == other.signature
        }
        return false
    }

    public operator func ==(that: AnyKey): Bool {
        return equals(that)
    }

    public operator func !=(that: AnyKey): Bool {
        return !equals(that)
    }

    public func hashCode(): Int64 {
        var result: Int64 = sourceKey.hashCode()
        result = 31 * result + signature.hashCode()
        return result
    }

    public func toString(): String {
        return """
        DataCacheKey{sourceKey=${sourceKey},
        signature=${signature}"""
    }

    public func updateDiskCacheKey(md5: MD5): Unit {
        sourceKey.updateDiskCacheKey(md5)
        signature.updateDiskCacheKey(md5)
    }
}
