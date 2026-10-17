/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2025. All rights reserved.
 */
 
package droplet


public class GifDrawable <: Drawable & Animatable2 & FrameCallback {

    private let gifDrawableType: Int64 = 2
    public static var UNI_CODE: Int64 = 0
    public var uniCode: Int64;

    public static let LOOP_FOREVER: Int64 = -1;
    public static let LOOP_INTRINSIC: Int64 = 0;
    public static let TOTAL_ITERATION_COUNT_FOREVER: Int64 = 0;

    public var frameLoader: GifFrameLoader

    private var isRunningBool: Bool = false;
    /** True if the drawable should animate while visible. */
    private var isStarted: Bool = false;
    /** True if the drawable's resources have been recycled. */
    private var isRecycled: Bool = false;
    /**
    * True if the drawable is currently visible. Default to true because on certain platforms (at
    * least 4.1.1), setVisible is not called on {@link android.graphics.drawable.Drawable Drawables}
    * during {@link android.widget.ImageView#setImageDrawable(android.graphics.drawable.Drawable)}.
    * See issue #130.
    */
    private var isVisible: Bool = true;

    private var loopCount: Int64 = 0;
    /** The number of times to loop through the GIF animation. */
    private var maxLoopCount: Int64 = LOOP_FOREVER;

    private var animationCallbacks: Option<ArrayList<AnimationCallback>> = None

    private var drawFunc: ArrayList<(PixelMap) -> Unit> = ArrayList<(PixelMap) -> Unit>()

    public init(decoder: GifDecoder, targetFrameWidth: Int64, targetFrameHeight: Int64, firstFrame: PixelMap, transformation: Option<AnyTransformation>) {
        
        this.frameLoader = GifFrameLoader(decoder, targetFrameWidth, targetFrameHeight, firstFrame, transformation)

        UNI_CODE++
        this.uniCode = UNI_CODE

    }

    public override func setDrawFunc(drawFunc: (PixelMap) -> Unit): Unit {
        this.drawFunc.add(drawFunc)
    }

     func getSize(): Int32 {
        return Int32(frameLoader.getSize())
    }

    public override func getType(): Int64 {
        return gifDrawableType
    }

    public override func draw(_:Bool): Unit {
        if(this.drawFunc.size > 0) {
            for(f in this.drawFunc) {
                drawCurrentFrame(f)
            }
        }
    }

     func getCurrentFrame(): PixelMap {
        return frameLoader.getCurrentFrame();
    }

    public override func getPixelMap(): PixelMap {
        return this.getCurrentFrame()
    }

     func drawCurrentFrame(f: (PixelMap) -> Unit): Unit {
        // draw pixelMap
        let pixelMap: PixelMap = frameLoader.getCurrentFrame();
        f(pixelMap)
    }

     func getFrameIndex(): Int64 {
        return frameLoader.getCurrentIndex();
    }

    public func setLoopCount(loopCount: Int64): Unit {
        if (loopCount <= 0 && loopCount != LOOP_FOREVER && loopCount != LOOP_INTRINSIC) {
        throw IllegalArgumentException(
            "Loop count must be greater than 0, or equal to DropletDrawable.LOOP_FOREVER, or equal to DropletDrawable.LOOP_INTRINSIC");
        }

        if (loopCount == LOOP_INTRINSIC) {
        let intrinsicCount: Int64 = frameLoader.getLoopCount();
            maxLoopCount =
                if(intrinsicCount == TOTAL_ITERATION_COUNT_FOREVER) {
                    LOOP_FOREVER
                } else {
                    intrinsicCount
                }
        } else {
            maxLoopCount = loopCount;
        }
    }

    public override func onFrameReady(): Unit {
        // 重绘
        invalidateSelf();

        if (getFrameIndex() == frameLoader.getFrameCount() - 1) {
            loopCount++;
        }

        if (maxLoopCount > 0 && loopCount >= maxLoopCount) {
            notifyAnimationEndToListeners();
            stop();
        }
    }

    private func notifyAnimationEndToListeners(): Unit {
        if(let Some(j) <- animationCallbacks){
            let list = j
            for(i in 0 .. list.size) {
                list[i].onAnimationEnd(this)
            }
        }
    }

    private func resetLoopCount(): Unit {
        loopCount = 0
    }

    private func startRunning(): Unit {
        if(isRecycled) {
            throw DropletException("You cannot start a recycled Drawable. Ensure thatyou clear any references to the Drawable when clearing the corresponding request.")
        }

        // If we have only a single frame, we don't want to decode it endlessly.
        if (frameLoader.getFrameCount() == 1) {
            invalidateSelf()
        } else if (!isRunningBool) {
            isRunningBool = true
            frameLoader.subscribe(this)
            invalidateSelf()
        }
    }

    public override func start(): Unit {
        isStarted = true;
        resetLoopCount();
        if (isVisible) {
            startRunning();
        }
    }

    public override func isRunning(): Bool {
        return isRunningBool
    }

    public override func stop(): Unit {
        isStarted = false;
        stopRunning();
    }

    public override func registerAnimationCallback(animationCallback: AnimationCallback): Unit {
        if(animationCallbacks.isNone()){
           animationCallbacks = ArrayList<AnimationCallback>()
        }
        animationCallbacks.getOrThrow().add(animationCallback)
    }

    public override func unregisterAnimationCallback(animationCallback: AnimationCallback): Bool {
        if(animationCallbacks.isNone()){
            return false
        }
        let list: ArrayList<AnimationCallback> = animationCallbacks.getOrThrow()
        for(i in 0 .. list.size) {
            let callback: AnimationCallback = list[i]
            if(animationCallback == callback) {
                list.remove(at:i)
                break
            }
        }
        return true
    }

    public override func clearAnimationCallbacks(): Unit {
        if(let Some(i) <- animationCallbacks){
           i.clear()
        }
    }

    // TODO 优化
    public func equals(that: GifDrawable): Bool {
        this.uniCode == that.uniCode
    }

    public operator func ==(that: FrameCallback): Bool {
        if(that is GifDrawable) {
            return this.equals((that as GifDrawable).getOrThrow())
        }
        return false
    }

    public operator func !=(that: FrameCallback): Bool {
        if(that is GifDrawable) {
            return !this.equals((that as GifDrawable).getOrThrow())
        }
        return true
    }

    public operator func ==(that: AnimationCallback): Bool {
        if(that is GifDrawable) {
            return this.equals((that as GifDrawable).getOrThrow())
        }
        return false
    }

    public operator func !=(that: AnimationCallback): Bool {
        if(that is GifDrawable) {
            return !this.equals((that as GifDrawable).getOrThrow())
        }
        return true
    }

    private func stopRunning(): Unit {
        isRunningBool = false;
        frameLoader.unsubscribe(this)
    }

    private func invalidateSelf(): Unit {
        this.draw(false);
    }

}
