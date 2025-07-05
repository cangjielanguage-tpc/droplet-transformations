/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package droplet

foreign func tfTask(pOut: CPointer<UInt8>, pIn: CPointer<UInt8>, pparam: CPointer<Float32>): UInt32

foreign func getFitcenterIdx(): UInt32

foreign func getCenterinsideIdx(): UInt32

foreign func getCentercropIdx(): UInt32

foreign func getCirclecropIdx(): UInt32

foreign func getRoundedcornersIdx(): UInt32

foreign func getRotateIdx(): UInt32

foreign func getIdxNum(): UInt32

public interface TransformationType <: DropletAny<TransformationType> {}

public class TransformationPixelMap <: TransformationType {
    public var res: PixelMap

    public init(res: PixelMap) {
        this.res = res
    }

    public func toString(): String {
        // TODO PixelMap
        return ""
    }

    public func hashCode(): Int64 {
        // TODO PixelMap
        return 0
    }

    public operator func ==(_: TransformationType): Bool {
        return true
        // TODO PixelMap
    }

    public operator func !=(_: TransformationType): Bool {
        return false
        // TODO PixelMap
    }
}

public interface AnyTransformation <: AnyKey {
    func transform(resource: AnyDropletResource, outWidth: Int64, outHeight: Int64): AnyDropletResource
}

public interface Transformation<T> <: AnyTransformation {
    func transform(resource: DropletResource<T>, outWidth: Int64, outHeight: Int64): DropletResource<T>
}

public abstract open class PixelMapTransformation <: Transformation<PixelMap> {
    public static let SIZE_ORIGINAL: Int64 = -0x7FFFFFFFFFFFFFFF

    let szofParam = 4
    let maxNumParam = 14
    var nParam = 1
    public var puParam = CPointer<Unit>()
    public var pfParam = CPointer<Float32>()

    public func transform(resource: AnyDropletResource, outWidth: Int64, outHeight: Int64): AnyDropletResource {
        if (resource is DropletResource<PixelMap>) {
            let r: DropletResource<PixelMap> = (resource as DropletResource<PixelMap>).getOrThrow()
            return (transform(r, outWidth, outHeight) as AnyDropletResource).getOrThrow()
        } else {
            return resource
        }
    }

    public func transform(resource: DropletResource<PixelMap>, outWidth: Int64, outHeight: Int64): DropletResource<PixelMap> {
        if (!Utils.isValidDimensions(outWidth, outHeight)) {
            throw IllegalArgumentException(
                "Cannot apply transformation on width: ${outWidth} or height: ${outHeight} less than or equal to zero and not Target.SIZE_ORIGINAL"
            );
        }

        var toTransform: PixelMap = resource.get();
        var targetWidth: Int64 = if (outWidth == SIZE_ORIGINAL) {
            // TODO PixelMap getWidth()
            0
        } else {
            outWidth
        };
        var targetHeight: Int64 = if (outHeight == SIZE_ORIGINAL) {
            // TODO PixelMap getHeight()
            0
        } else {
            outHeight
        };
        var transformed: PixelMap = transform(toTransform, targetWidth, targetHeight);

        var result: DropletResource<PixelMap>
        // TODO PixelMap equals
        result = PixelMapResource.obtain(transformed)
        return result;
    }

    /**
     * Transforms the given {@link android.graphics.Bitmap} based on the given dimensions and returns
     * the transformed result.
     *
     * <p>The provided Bitmap, toTransform, should not be recycled or returned to the pool. Droplet will
     * automatically recycle and/or reuse toTransform if the transformation returns a different
     * Bitmap. Similarly implementations should never recycle or return Bitmaps that are returned as
     * the result of this method. Recycling or returning the provided and/or the returned Bitmap to
     * the pool will lead to a variety of runtime exceptions and drawing errors. See #408 for an
     * example. If the implementation obtains and discards intermediate Bitmaps, they may safely be
     * returned to the BitmapPool and/or recycled.
     *
     * <p>outWidth and outHeight will never be {@link
     * com.bumptech.droplet.request.target.Target#SIZE_ORIGINAL}, this class converts them to be the
     * size of the Bitmap we're going to transform before calling this method.
     *
     * @param pool A {@link com.bumptech.droplet.load.engine.bitmap_recycle.BitmapPool} that can be used
     *     to obtain and return intermediate {@link Bitmap}s used in this transformation. For every
     *     {@link android.graphics.Bitmap} obtained from the pool during this transformation, a {@link
     *     android.graphics.Bitmap} must also be returned.
     * @param toTransform The {@link android.graphics.Bitmap} to transform.
     * @param outWidth The ideal width of the transformed bitmap (the transformed width does not need
     *     to match exactly).
     * @param outHeight The ideal height of the transformed bitmap (the transformed height does not
     *     need to match exactly).
     */
    protected func transform(toTransform: PixelMap, outWidth: Int64, outHeight: Int64): PixelMap
}

////////////////////////////////////////////////////////
public class RotateTrans <: PixelMapTransformation {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.RotateTrans"
    private static let tfId: UInt32 = unsafe { getRotateIdx() }
    var degree: Float32
    var wi: Int32 = 0
    var hi: Int32 = 0
    var wo: Int32 = 0
    var ho: Int32 = 0
    public var vx: Array<Float32> = [-1.0, 1.0, -1.0, 1.0]
    public var vy: Array<Float32> = [-1.0, -1.0, 1.0, 1.0]
    let pi: Float32 = 3.1416926

    public init(degree: Float32) {
        this.degree = degree
        nParam = 5
    }

    private func updateParams() {
        var w1 = Float32(wi) / 2.0
        var h1 = Float32(hi) / 2.0
        vx = [-w1, w1, -w1, w1]
        vy = [-h1, -h1, h1, h1]
        let rad = degree / 180.0 * pi
        let c: Float32 = cos(rad)
        let s: Float32 = sin(rad)

        for (i in 0..4) {
            var x = vx[i]
            var y = vy[i]
            vx[i] = c * x - s * y
            vy[i] = s * x + c * y
        }

        var xmin = min(min(vx[0], vx[1]), min(vx[2], vx[3]))
        var ymin = min(min(vy[0], vy[1]), min(vy[2], vy[3]))
        var xmax = max(max(vx[0], vx[1]), max(vx[2], vx[3]))
        var ymax = max(max(vy[0], vy[1]), max(vy[2], vy[3]))

        wo = Int32(round(xmax - xmin))
        ho = Int32(round(ymax - ymin))

        var w2 = (xmax - xmin) / 2.0
        var h2 = (ymax - ymin) / 2.0
        for (i in 0..4) {
            vx[i] = vx[i] / w2
            vy[i] = vy[i] / h2
        }
    }

    protected func transform(toTransform: PixelMap, _: Int64, _: Int64): PixelMap {
        let arr: Array<UInt8> = Array<UInt8>(Int64(toTransform.getPixelBytesNumber()), repeat: 0)
        toTransform.readPixelsToBuffer(arr)
        var info = toTransform.getImageInfo()
        var w = info.size.width
        var h = info.size.height
        var bitmap = CommonBitmap(w, h, 4, arr)

        wi = Int32(w)
        hi = Int32(h)
        updateParams()
        puParam = unsafe { malloc(UIntNative(maxNumParam * szofParam)) }
        pfParam = unsafe { CPointer<Float32>(puParam) }
        unsafe { pfParam.write(0, Float32(tfId)) }
        unsafe { pfParam.write(1, Float32(w)) }
        unsafe { pfParam.write(2, Float32(h)) }
        unsafe { pfParam.write(3, Float32(4)) }
        unsafe { pfParam.write(4, Float32(wo)) }
        unsafe { pfParam.write(5, Float32(ho)) }
        unsafe { pfParam.write(6, vx[0]) }
        unsafe { pfParam.write(7, vx[1]) }
        unsafe { pfParam.write(8, vx[2]) }
        unsafe { pfParam.write(9, vx[3]) }
        unsafe { pfParam.write(10, vy[0]) }
        unsafe { pfParam.write(11, vy[1]) }
        unsafe { pfParam.write(12, vy[2]) }
        unsafe { pfParam.write(13, vy[3]) }

        var bitmapOut = CommonBitmap(wo, ho, 4)
        bitmapOut.allocCdata()
        let res = unsafe { tfTask(bitmapOut.cdata, bitmap.cdata, pfParam) }
        bitmapOut.cdataToData()

        let color: Array<UInt8> = Array<UInt8>(bitmapOut.data.size, repeat: 0)
        let px: PixelMap = createPixelMap(color,
            InitializationOptions(size: Size(width: wo, height: ho), pixelFormat: PixelMapFormat.RGBA_8888,
            editable: true))
        px.writeBufferToPixels(bitmapOut.data)
        bitmap.release()
        bitmapOut.release()
        unsafe { free(puParam) }
        return px
    }

    public func toString(): String {
        return "RotateTrans(degree=${degree})";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        Utils.hashCodeWrite(degree)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is RotateTrans) {
            var other: RotateTrans = (that as RotateTrans).getOrThrow();
            return degree == other.degree
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is RotateTrans) {
            var other: RotateTrans = (that as RotateTrans).getOrThrow();
            return degree != other.degree
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}${degree}".toArray()) //update data
    }
}



public class CenterCrop <: PixelMapTransformation {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.CenterCrop"
    private static let tfId: UInt32 = unsafe { getCentercropIdx() }

    public init() {
        nParam = 8
    }

    protected func transform(toTransform: PixelMap, outWidth: Int64, outHeight: Int64): PixelMap {
        let arr: Array<UInt8> = Array<UInt8>(Int64(toTransform.getPixelBytesNumber()), repeat: 0)
        toTransform.readPixelsToBuffer(arr)
        var info = toTransform.getImageInfo()
        var w = info.size.width
        var h = info.size.height
        var wo = Int32(outWidth)
        var ho = Int32(outHeight)
        var bitmap = CommonBitmap(w, h, 4, arr)

        if (w == wo && h == ho) {
            return toTransform
        }

        var scale: Float32 = 0.0
        var dx: Float32 = 1.0
        var dy: Float32 = 1.0
        if (Int64(w) * Int64(ho) > Int64(wo) * Int64(h)) {
            scale = Float32(ho) / Float32(h)
            dx = abs(Float32(wo) - Float32(w) * scale) / Float32(wo) + 1.0
        } else {
            scale = Float32(wo) / Float32(w)
            dy = abs(Float32(ho) - Float32(h) * scale) / Float32(ho) + 1.0
        }

        puParam = unsafe { malloc(UIntNative(maxNumParam * szofParam)) }
        pfParam = unsafe { CPointer<Float32>(puParam) }
        unsafe { pfParam.write(0, Float32(tfId)) }
        unsafe { pfParam.write(1, Float32(w)) }
        unsafe { pfParam.write(2, Float32(h)) }
        unsafe { pfParam.write(3, Float32(4)) }
        unsafe { pfParam.write(4, Float32(dx)) }
        unsafe { pfParam.write(5, Float32(dy)) }
        unsafe { pfParam.write(6, Float32(wo)) }
        unsafe { pfParam.write(7, Float32(ho)) }

        var bitmapOut = CommonBitmap(wo, ho, 4)
        bitmapOut.allocCdata()
        let res = unsafe { tfTask(bitmapOut.cdata, bitmap.cdata, pfParam) }
        bitmapOut.cdataToData()

        let color: Array<UInt8> = Array<UInt8>(bitmapOut.data.size, repeat: 0)
        let px: PixelMap = createPixelMap(color,
            InitializationOptions(size: Size(width: wo, height: ho), pixelFormat: PixelMapFormat.RGBA_8888,
            editable: true))

        px.writeBufferToPixels(bitmapOut.data)
        bitmap.release()
        bitmapOut.release()
        unsafe { free(puParam) }
        return px
    }

    public func toString(): String {
        return "CenterCrop()";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is CenterCrop) {
            return true
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is CenterCrop) {
            return false
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}".toArray()) //update data
    }
}

public class CenterInside <: PixelMapTransformation {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.CenterInside"
    private static let tfId: UInt32 = unsafe { getCenterinsideIdx() }

    public init() {
        nParam = 6
    }

    protected func transform(toTransform: PixelMap, outWidth: Int64, outHeight: Int64): PixelMap {
        let arr: Array<UInt8> = Array<UInt8>(Int64(toTransform.getPixelBytesNumber()), repeat: 0)
        toTransform.readPixelsToBuffer(arr)
        var info = toTransform.getImageInfo()
        var w = info.size.width
        var h = info.size.height
        var wo = Int32(outWidth)
        var ho = Int32(outHeight)
        var bitmap = CommonBitmap(w, h, 4, arr)

        if (w <= wo && h <= ho) {
            return toTransform
        }

        var wr = Float32(wo) / Float32(w)
        var hr = Float32(ho) / Float32(h)
        var minr = min(wr, hr)
        wo = Int32(round(minr * Float32(w)))
        ho = Int32(round(minr * Float32(h)))

        puParam = unsafe { malloc(UIntNative(maxNumParam * szofParam)) }
        pfParam = unsafe { CPointer<Float32>(puParam) }
        unsafe { pfParam.write(0, Float32(tfId)) }
        unsafe { pfParam.write(1, Float32(w)) }
        unsafe { pfParam.write(2, Float32(h)) }
        unsafe { pfParam.write(3, Float32(4)) }
        unsafe { pfParam.write(4, Float32(wo)) }
        unsafe { pfParam.write(5, Float32(ho)) }

        var bitmapOut = CommonBitmap(wo, ho, 4)
        bitmapOut.allocCdata()
        let res = unsafe { tfTask(bitmapOut.cdata, bitmap.cdata, pfParam) }
        bitmapOut.cdataToData()

        let color: Array<UInt8> = Array<UInt8>(bitmapOut.data.size, repeat: 0)
        let px: PixelMap = createPixelMap(color,
            InitializationOptions(size: Size(width: wo, height: ho), pixelFormat: PixelMapFormat.RGBA_8888,
            editable: true))

        px.writeBufferToPixels(bitmapOut.data)
        bitmap.release()
        bitmapOut.release()
        unsafe { free(puParam) }
        return px
    }

    public func toString(): String {
        return "CenterInside()";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is CenterInside) {
            return true
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is CenterInside) {
            return false
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}".toArray()) //update data
    }
}

public class FitCenter <: PixelMapTransformation {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.FitCenter"
    private static let tfId: UInt32 = unsafe { getFitcenterIdx() }

    public init() {
        nParam = 6
    }

    protected func transform(toTransform: PixelMap, outWidth: Int64, outHeight: Int64): PixelMap {
        let arr: Array<UInt8> = Array<UInt8>(Int64(toTransform.getPixelBytesNumber()), repeat: 0)
        toTransform.readPixelsToBuffer(arr)
        var info = toTransform.getImageInfo()
        var w = info.size.width
        var h = info.size.height
        var wo = Int32(outWidth)
        var ho = Int32(outHeight)
        var bitmap = CommonBitmap(w, h, 4, arr)

        if (w == wo && h == ho) {
            return toTransform
        }

        var wr = Float32(wo) / Float32(w)
        var hr = Float32(ho) / Float32(h)
        var minr = min(wr, hr)
        wo = Int32(round(minr * Float32(w)))
        ho = Int32(round(minr * Float32(h)))

        puParam = unsafe { malloc(UIntNative(maxNumParam * szofParam)) }
        pfParam = unsafe { CPointer<Float32>(puParam) }
        unsafe { pfParam.write(0, Float32(tfId)) }
        unsafe { pfParam.write(1, Float32(w)) }
        unsafe { pfParam.write(2, Float32(h)) }
        unsafe { pfParam.write(3, Float32(4)) }
        unsafe { pfParam.write(4, Float32(wo)) }
        unsafe { pfParam.write(5, Float32(ho)) }

        var bitmapOut = CommonBitmap(wo, ho, 4)
        bitmapOut.allocCdata()
        let res = unsafe { tfTask(bitmapOut.cdata, bitmap.cdata, pfParam) }
        bitmapOut.cdataToData()

        let color: Array<UInt8> = Array<UInt8>(bitmapOut.data.size, repeat: 0)
        let px: PixelMap = createPixelMap(color,
            InitializationOptions(size: Size(width: wo, height: ho), pixelFormat: PixelMapFormat.RGBA_8888,
            editable: true))

        px.writeBufferToPixels(bitmapOut.data)
        bitmap.release()
        bitmapOut.release()
        unsafe { free(puParam) }
        return px
    }

    public func toString(): String {
        return "FitCenter()";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is FitCenter) {
            return true
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is FitCenter) {
            return false
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}".toArray()) //update data
    }
}

public class CircleCrop <: PixelMapTransformation {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.CircleCrop"
    private static let tfId: UInt32 = unsafe { getCirclecropIdx() }

    public init() {
        nParam = 8
    }

    protected func transform(toTransform: PixelMap, outWidth: Int64, outHeight: Int64): PixelMap {
        let arr: Array<UInt8> = Array<UInt8>(Int64(toTransform.getPixelBytesNumber()), repeat: 0)
        toTransform.readPixelsToBuffer(arr)
        var info = toTransform.getImageInfo()
        var w = info.size.width
        var h = info.size.height
        var edge = Int32(min(outWidth, outHeight))
        var wo = edge
        var ho = edge
        var bitmap = CommonBitmap(w, h, 4, arr)

        var scale: Float32 = 0.0
        var dx: Float32 = 1.0
        var dy: Float32 = 1.0
        if (Int64(w) * Int64(ho) > Int64(wo) * Int64(h)) {
            scale = Float32(ho) / Float32(h)
            dx = abs(Float32(wo) - Float32(w) * scale) / Float32(wo) + 1.0
        } else {
            scale = Float32(wo) / Float32(w)
            dy = abs(Float32(ho) - Float32(h) * scale) / Float32(ho) + 1.0
        }

        puParam = unsafe { malloc(UIntNative(maxNumParam * szofParam)) }
        pfParam = unsafe { CPointer<Float32>(puParam) }
        unsafe { pfParam.write(0, Float32(tfId)) }
        unsafe { pfParam.write(1, Float32(w)) }
        unsafe { pfParam.write(2, Float32(h)) }
        unsafe { pfParam.write(3, Float32(4)) }
        unsafe { pfParam.write(4, Float32(dx)) }
        unsafe { pfParam.write(5, Float32(dy)) }
        unsafe { pfParam.write(6, Float32(edge)) }

        var bitmapOut = CommonBitmap(wo, ho, 4)
        bitmapOut.allocCdata()
        let res = unsafe { tfTask(bitmapOut.cdata, bitmap.cdata, pfParam) }
        bitmapOut.cdataToData()

        let color: Array<UInt8> = Array<UInt8>(bitmapOut.data.size, repeat: 0)
        let px: PixelMap = createPixelMap(color,
            InitializationOptions(size: Size(width: wo, height: ho), pixelFormat: PixelMapFormat.RGBA_8888,
            editable: true))

        px.writeBufferToPixels(bitmapOut.data)
        bitmap.release()
        bitmapOut.release()
        unsafe { free(puParam) }
        return px
    }

    public func toString(): String {
        return "CircleCrop()";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is CircleCrop) {
            return true
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is CircleCrop) {
            return false
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}".toArray()) //update data
    }
}

public class RoundedCorners <: PixelMapTransformation {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.RoundedCorners"
    private static let tfId: UInt32 = unsafe { getRoundedcornersIdx() }
    var radius: Int32

    public init(radius: Int32) {
        if (radius <= 0) {
            throw DropletException("radius must be greater than 0.")
        }
        this.radius = radius
        nParam = 8
    }

    protected func transform(toTransform: PixelMap, _: Int64, _: Int64): PixelMap {
        let arr: Array<UInt8> = Array<UInt8>(Int64(toTransform.getPixelBytesNumber()), repeat: 0)
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
        unsafe { pfParam.write(4, Float32(radius)) }
        unsafe { pfParam.write(5, Float32(radius)) }
        unsafe { pfParam.write(6, Float32(radius)) }
        unsafe { pfParam.write(7, Float32(radius)) }
        let res = unsafe { tfTask(bitmapOut.cdata, bitmap.cdata, pfParam) }
        bitmapOut.cdataToData()

        let color: Array<UInt8> = Array<UInt8>(bitmapOut.data.size, repeat: 0)
        let px: PixelMap = createPixelMap(color,
            InitializationOptions(size: info.size, pixelFormat: PixelMapFormat.RGBA_8888, editable: true))
        px.writeBufferToPixels(bitmapOut.data)
        bitmap.release()
        bitmapOut.release()
        unsafe { free(puParam) }
        return px
    }

    public func toString(): String {
        return "RoundedCorners(radius=${radius})";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        Utils.hashCodeWrite(Int64(radius))
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is RoundedCorners) {
            var other: RoundedCorners = (that as RoundedCorners).getOrThrow();
            return radius == other.radius
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is RoundedCorners) {
            var other: RoundedCorners = (that as RoundedCorners).getOrThrow();
            return radius != other.radius
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}${radius}".toArray()) //update data
    }
}

public class GranularRoundedCorners <: PixelMapTransformation {
    private static let ID: String = "com.cj.droplet.load.resource.pixelmap.GranularRoundedCorners"
    private static let tfId: UInt32 = unsafe { getRoundedcornersIdx() }
    var radiusTL: Int32
    var radiusTR: Int32
    var radiusBL: Int32
    var radiusBR: Int32

    public init(radiusTL: Int32, radiusTR: Int32, radiusBL: Int32, radiusBR: Int32) {
        if (radiusTL < 0 || radiusTR < 0 || radiusBL < 0 || radiusBR < 0) {
            throw DropletException("radius must not be less than 0.")
        }
        this.radiusTL = radiusTL
        this.radiusTR = radiusTR
        this.radiusBL = radiusBL
        this.radiusBR = radiusBR
        nParam = 5
    }

    protected func transform(toTransform: PixelMap, _: Int64, _: Int64): PixelMap {
        let arr: Array<UInt8> = Array<UInt8>(Int64(toTransform.getPixelBytesNumber()), repeat: 0)
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
        unsafe { pfParam.write(4, Float32(radiusBL)) }
        unsafe { pfParam.write(5, Float32(radiusBR)) }
        unsafe { pfParam.write(6, Float32(radiusTL)) }
        unsafe { pfParam.write(7, Float32(radiusTR)) }
        let res = unsafe { tfTask(bitmapOut.cdata, bitmap.cdata, pfParam) }
        bitmapOut.cdataToData()

        let color: Array<UInt8> = Array<UInt8>(bitmapOut.data.size, repeat: 0)
        let px: PixelMap = createPixelMap(color,
            InitializationOptions(size: info.size, pixelFormat: PixelMapFormat.RGBA_8888, editable: true))
        px.writeBufferToPixels(bitmapOut.data)
        bitmap.release()
        bitmapOut.release()
        unsafe { free(puParam) }
        return px
    }

    public func toString(): String {
        return "GranularRoundedCorners(radiusTL=${radiusTL},radiusTR=${radiusTR},radiusBL=${radiusBL},radiusBR=${radiusBR})";
    }

    public func hashCode(): Int64 {
        Utils.hashCodeWrite(ID, reset: true)
        Utils.hashCodeWrite(Int64(radiusTL))
        Utils.hashCodeWrite(Int64(radiusTR))
        Utils.hashCodeWrite(Int64(radiusBL))
        Utils.hashCodeWrite(Int64(radiusBR))
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: AnyKey): Bool {
        if (that is GranularRoundedCorners) {
            var other: GranularRoundedCorners = (that as GranularRoundedCorners).getOrThrow();
            return ((radiusTL == other.radiusTL) && (radiusTR == other.radiusTR) && (radiusBL == other.radiusBL) && (radiusBR ==
                other.radiusBR))
        } else {
            return false
        }
    }

    public operator func !=(that: AnyKey): Bool {
        if (that is GranularRoundedCorners) {
            var other: GranularRoundedCorners = (that as GranularRoundedCorners).getOrThrow();
            return !((radiusTL == other.radiusTL) && (radiusTR == other.radiusTR) && (radiusBL == other.radiusBL) && (radiusBR ==
                other.radiusBR))
        } else {
            return true
        }
    }

    public func updateDiskCacheKey(md5: MD5) {
        md5.MD5Update("${ID}${radiusTL}${radiusTR}${radiusBL}${radiusBR}".toArray()) //update data
    }
}
