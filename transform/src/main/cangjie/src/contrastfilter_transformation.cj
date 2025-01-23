/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package transform

public class ContrastFilterTransformation <: PixelMapTransformationBridge {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.ContrastFilterTransformation"
    private static let tfId: UInt32 = unsafe { getContrastIdx() }
    var contrast: Float32
    var nParam = 1
    let szofParam = 4
    let maxNumParam = 14

    public init() {
        contrast = 1.0
        nParam = 5
    }

    public init(contrast: Float32) {
        this.contrast = contrast
        nParam = 5
    }

    protected func transform(toTransform: PixelMap, _: Int64, _: Int64): PixelMap {
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
        unsafe { pfParam.write(4, contrast) }
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
        return "ContrastFilterTransformation(contrast=${contrast})";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        Utils.hashCodeWrite(contrast)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is ContrastFilterTransformation) {
            var other: ContrastFilterTransformation = (that as ContrastFilterTransformation).getOrThrow();
            return contrast == other.contrast
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is ContrastFilterTransformation) {
            var other: ContrastFilterTransformation = (that as ContrastFilterTransformation).getOrThrow();
            return contrast != other.contrast
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}${contrast}".toArray()) //update data
    }
}
