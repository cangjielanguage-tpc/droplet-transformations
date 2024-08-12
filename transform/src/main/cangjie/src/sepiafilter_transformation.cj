/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
 */

package transform

public class SepiaFilterTransformation <: PixelMapTransformationBridge {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.SepiaFilterTransformation"
    private static let tfId: UInt32 = unsafe { getSepiaIdx() }
    var intensity: Float32

    var nParam = 1
    let szofParam = 4
    let maxNumParam = 14

    public init() {
        intensity = 10.0
        nParam = 5
    }

    public init(intensity: Float32) {
        this.intensity = intensity
        nParam = 5
    }

    protected func transform(toTransform: PixelMap, outWidth: Int64, outHeight: Int64): PixelMap {
        let arr: Array<UInt8> = Array<UInt8>(Int64(toTransform.getPixelBytesNumber()), item: 0)
        toTransform.readPixelsToBuffer(arr)
        var info = toTransform.getImageInfo()
        var w = info.size.width
        var h = info.size.height

        var bitmap = CommonBitmap(w, h, 4, arr)
        var bitmapOut = CommonBitmap(w, h, 4)
        bitmapOut.allocCdata()

        puParam = unsafe { malloc(UIntNative(maxNumParam * szofParam)) }
        pfParam = unsafe { CPointer<Float32>(puParam) }
        unsafe { pfParam.write(0, Float32(tfId)) }
        unsafe { pfParam.write(1, Float32(w)) }
        unsafe { pfParam.write(2, Float32(h)) }
        unsafe { pfParam.write(3, Float32(4)) }
        unsafe { pfParam.write(4, intensity) }
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
        return "SepiaFilterTransformation(intensity=${intensity})";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        Utils.hashCodeWrite(intensity)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is SepiaFilterTransformation) {
            var other: SepiaFilterTransformation = (that as SepiaFilterTransformation).getOrThrow();
            return intensity == other.intensity
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is SepiaFilterTransformation) {
            var other: SepiaFilterTransformation = (that as SepiaFilterTransformation).getOrThrow();
            return intensity != other.intensity
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}${intensity}".toArray()) //update data
    }
}
