/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package transform

internal import ohos.image.*
internal import droplet.Transformation
internal import droplet.AnyDropletResource
internal import droplet.DropletResource
internal import droplet.AnyKey
internal import droplet.MD5
internal import droplet.Utils
internal import droplet.CommonBitmap
internal import droplet.DropletException
internal import droplet.PixelMapResource
internal import droplet.PixelMapTransformation

foreign func tfTask(pOut: CPointer<UInt8>, pIn: CPointer<UInt8>, pparam: CPointer<Float32>): UInt32

foreign func malloc(size: UIntNative): CPointer<Unit>

foreign func free(ptr: CPointer<Unit>): Unit

foreign func getBrightIdx(): UInt32

foreign func getContrastIdx(): UInt32

foreign func getGrayscaleIdx(): UInt32

foreign func getInvertIdx(): UInt32

foreign func getKuwaharaIdx(): UInt32

foreign func getPixelationIdx(): UInt32

foreign func getSepiaIdx(): UInt32

foreign func getSketchIdx(): UInt32

foreign func getSwirlIdx(): UInt32

foreign func getToonIdx(): UInt32

foreign func getVignetteIdx(): UInt32

foreign func getFastBlurIdx(): UInt32

foreign func getIdxNum(): UInt32

public abstract open class PixelMapTransformationBridge <: PixelMapTransformation {

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
