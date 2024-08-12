/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
 */

package transform

public class BrightnessFilterTransformation <: PixelMapTransformationBridge {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.BrightnessFilterTransformation"
    private static let tfId: UInt32 = unsafe { getBrightIdx() }
    var brightness: Float32
    var nParam = 1
    let maxNumParam = 14
    let szofParam = 4

    public init() {
        brightness = 0.0
        nParam = 5
    }

    public init(brightness: Float32) {
        if (brightness <= 0.0) {
            throw DropletException("brightness must be greater than 0.")
        }
        this.brightness = brightness
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
        unsafe { pfParam.write(4, brightness) }
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
        return "BrightnessFilterTransformation(brightness=${brightness})";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        Utils.hashCodeWrite(brightness)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is BrightnessFilterTransformation) {
            var other: BrightnessFilterTransformation = (that as BrightnessFilterTransformation).getOrThrow();
            return brightness == other.brightness
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is BrightnessFilterTransformation) {
            var other: BrightnessFilterTransformation = (that as BrightnessFilterTransformation).getOrThrow();
            return brightness != other.brightness
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}${brightness}".toArray()) //update data
    }
}
