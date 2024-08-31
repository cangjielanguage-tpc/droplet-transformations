/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
 */

package transform

public class VignetteFilterTransformation <: PixelMapTransformationBridge {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.VignetteFilterTransformation"
    private static let tfId: UInt32 = unsafe { getVignetteIdx() }
    private var xCenter: Float32 = 0.5
    private var yCenter: Float32 = 0.5
    private var rVnt: Float32 = 0.0
    private var gVnt: Float32 = 0.0
    private var bVnt: Float32 = 0.0
    private var startVnt: Float32 = 0.0
    private var endVnt: Float32 = 0.75

    var nParam = 1
    let szofParam = 4
    let maxNumParam = 14

    public init() {
        nParam = 11
    }

    public init(x: Float32, y: Float32, r: Float32, g: Float32, b: Float32, start: Float32, end: Float32) {
        this.xCenter = x
        this.yCenter = y
        this.rVnt = r
        this.gVnt = g
        this.bVnt = b
        this.startVnt = start
        this.endVnt = end
        nParam = 11
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
        unsafe { pfParam.write(4, xCenter) }
        unsafe { pfParam.write(5, yCenter) }
        unsafe { pfParam.write(6, rVnt) }
        unsafe { pfParam.write(7, gVnt) }
        unsafe { pfParam.write(8, bVnt) }
        unsafe { pfParam.write(9, startVnt) }
        unsafe { pfParam.write(10, endVnt) }
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
        return "VignetteFilterTransformation(center=(${xCenter},${yCenter}),color=(${rVnt},${gVnt},${bVnt}),range=(${startVnt},${endVnt}))";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        Utils.hashCodeWrite(xCenter)
        Utils.hashCodeWrite(yCenter)
        Utils.hashCodeWrite(rVnt)
        Utils.hashCodeWrite(gVnt)
        Utils.hashCodeWrite(bVnt)
        Utils.hashCodeWrite(startVnt)
        Utils.hashCodeWrite(endVnt)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is VignetteFilterTransformation) {
            var other: VignetteFilterTransformation = (that as VignetteFilterTransformation).getOrThrow();
            return ((xCenter == other.xCenter) && (yCenter == other.yCenter) && (rVnt == other.rVnt) && (gVnt == other.
                gVnt) && (bVnt == other.bVnt) && (startVnt == other.startVnt) && (endVnt == other.endVnt))
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is VignetteFilterTransformation) {
            var other: VignetteFilterTransformation = (that as VignetteFilterTransformation).getOrThrow();
            return !((xCenter == other.xCenter) && (yCenter == other.yCenter) && (rVnt == other.rVnt) && (gVnt == other.
                gVnt) && (bVnt == other.bVnt) && (startVnt == other.startVnt) && (endVnt == other.endVnt))
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}${xCenter}${yCenter}${rVnt}${gVnt}${bVnt}${startVnt}${endVnt}".toArray()) //update data
    }
}
