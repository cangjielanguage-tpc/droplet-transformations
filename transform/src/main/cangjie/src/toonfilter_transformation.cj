/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package transform

public class ToonFilterTransformation <: PixelMapTransformationBridge {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.ToonFilterTransformation"
    private static let tfId: UInt32 = unsafe { getToonIdx() }
    private let lineSize: Float32 = 1.0
    private var wTexel: Float32 = 0.0
    private var hTexel: Float32 = 0.0

    private var threshold: Float32 = 0.2
    private var quantizationLevels: Float32 = 10.0

    var nParam = 1
    let szofParam = 4
    let maxNumParam = 14

    public init() {
        nParam = 8
    }

    public init(threshold: Float32, quantizationLevels: Float32) {
        this.threshold = threshold
        this.quantizationLevels = quantizationLevels
        nParam = 8
    }

    protected func transform(toTransform: PixelMap, _: Int64, _: Int64): PixelMap {
        let arr: Array<UInt8> = Array<UInt8>(Int64(toTransform.getPixelBytesNumber()), item: 0)
        toTransform.readPixelsToBuffer(arr)
        var info = toTransform.getImageInfo()
        var w = info.size.width
        var h = info.size.height

        wTexel = lineSize / Float32(w)
        hTexel = lineSize / Float32(h)

        var bitmap = CommonBitmap(w, h, 4, arr)
        var bitmapOut = CommonBitmap(w, h, 4)
        bitmapOut.allocCdata()

        puParam = unsafe { malloc(UIntNative(maxNumParam * szofParam)) }
        pfParam = unsafe { CPointer<Float32>(puParam) }
        unsafe { pfParam.write(0, Float32(tfId)) }
        unsafe { pfParam.write(1, Float32(w)) }
        unsafe { pfParam.write(2, Float32(h)) }
        unsafe { pfParam.write(3, Float32(4)) }
        unsafe { pfParam.write(4, wTexel) }
        unsafe { pfParam.write(5, hTexel) }
        unsafe { pfParam.write(6, threshold) }
        unsafe { pfParam.write(7, quantizationLevels) }
        let res = unsafe { tfTask(bitmapOut.cdata, bitmap.cdata, pfParam) }
        bitmapOut.cdataToData()

        let color: Array<UInt8> = Array<UInt8>(bitmapOut.data.size, item: 0)
        let px: PixelMap = createPixelMap(color,
            InitializationOptions(size: info.size, pixelFormat: PixelMapFormat.RGBA_8888, editable: true))
        px.writeBufferToPixels(bitmapOut.data)
        bitmap.release()
        bitmapOut.release()
        unsafe { free(puParam) }
        return px
    }

    public func toString(): String {
        return "ToonFilterTransformation(threshold=${threshold},quantizationLevels=${quantizationLevels})";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        Utils.hashCodeWrite(threshold)
        Utils.hashCodeWrite(quantizationLevels)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is ToonFilterTransformation) {
            var other: ToonFilterTransformation = (that as ToonFilterTransformation).getOrThrow();
            return ((threshold == other.threshold) && (quantizationLevels == other.quantizationLevels))
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is ToonFilterTransformation) {
            var other: ToonFilterTransformation = (that as ToonFilterTransformation).getOrThrow();
            return !((threshold == other.threshold) && (quantizationLevels == other.quantizationLevels))
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}${threshold}${quantizationLevels}".toArray()) //update data
    }
}
