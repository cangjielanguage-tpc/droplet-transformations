/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
 */

package transform

public class SwirlFilterTransformation <: PixelMapTransformationBridge {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.SwirlFilterTransformation"
    private static let tfId: UInt32 = unsafe { getSwirlIdx() }
    private var radius: Float32 = 0.5
    private var angle: Float32 = 1.0
    private var xCenter: Float32 = 0.5
    private var yCenter: Float32 = 0.5

    var nParam = 1
    let szofParam = 4
    let maxNumParam = 14

    public init() {
        nParam = 8
    }

    public init(radius: Float32, angle: Float32, x: Float32, y: Float32) {
        this.radius = radius
        this.angle = angle
        this.xCenter = x
        this.yCenter = y
        nParam = 8
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
        unsafe { pfParam.write(4, radius) }
        unsafe { pfParam.write(5, angle) }
        unsafe { pfParam.write(6, xCenter) }
        unsafe { pfParam.write(7, yCenter) }
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
        return "SwirlFilterTransformation(radius=${radius},angle=${angle},center=(${xCenter},${yCenter}))";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        Utils.hashCodeWrite(radius)
        Utils.hashCodeWrite(angle)
        Utils.hashCodeWrite(xCenter)
        Utils.hashCodeWrite(yCenter)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is SwirlFilterTransformation) {
            var other: SwirlFilterTransformation = (that as SwirlFilterTransformation).getOrThrow();
            return ((radius == other.radius) && (angle == other.angle) && (xCenter == other.xCenter) && (yCenter == other.
                yCenter))
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is SwirlFilterTransformation) {
            var other: SwirlFilterTransformation = (that as SwirlFilterTransformation).getOrThrow();
            return !((radius == other.radius) && (angle == other.angle) && (xCenter == other.xCenter) && (yCenter ==
                other.yCenter))
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}${radius}${angle}${xCenter}${yCenter}".toArray()) //update data
    }
}
