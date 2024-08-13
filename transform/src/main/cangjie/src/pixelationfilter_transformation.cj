/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
 */

package transform

public class PixelationFilterTransformation <: PixelMapTransformationBridge {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.PixelationFilterTransformation"
    private static let tfId: UInt32 = unsafe { getPixelationIdx() }
    var pixel: Float32
    private var wFactor: Float32 = 0.0
    private var hFactor: Float32 = 0.0

    var nParam = 1
    let szofParam = 4
    let maxNumParam = 14

    public init() {
        pixel = 10.0
        nParam = 7
    }

    public init(pixel: Float32) {
        this.pixel = pixel
        nParam = 7
    }

    protected func transform(toTransform: PixelMap, outWidth: Int64, outHeight: Int64): PixelMap {
        let arr: Array<UInt8> = Array<UInt8>(Int64(toTransform.getPixelBytesNumber()), item: 0)
        toTransform.readPixelsToBuffer(arr)
        var info = toTransform.getImageInfo()
        var w = info.size.width
        var h = info.size.height
        wFactor = 1.0 / Float32(w)
        hFactor = 1.0 / Float32(h)

        var bitmap = CommonBitmap(w, h, 4, arr)
        var bitmapOut = CommonBitmap(w, h, 4)
        bitmapOut.allocCdata()

        puParam = unsafe { malloc(UIntNative(maxNumParam * szofParam)) }
        pfParam = unsafe { CPointer<Float32>(puParam) }
        unsafe { pfParam.write(0, Float32(tfId)) }
        unsafe { pfParam.write(1, Float32(w)) }
        unsafe { pfParam.write(2, Float32(h)) }
        unsafe { pfParam.write(3, Float32(4)) }
        unsafe { pfParam.write(4, pixel) }
        unsafe { pfParam.write(5, wFactor) }
        unsafe { pfParam.write(6, hFactor) }
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
        return "PixelationFilterTransformation(pixel=${pixel})";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        Utils.hashCodeWrite(pixel)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is PixelationFilterTransformation) {
            var other: PixelationFilterTransformation = (that as PixelationFilterTransformation).getOrThrow();
            return pixel == other.pixel
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is PixelationFilterTransformation) {
            var other: PixelationFilterTransformation = (that as PixelationFilterTransformation).getOrThrow();
            return pixel != other.pixel
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}${pixel}".toArray()) //update data
    }
}
