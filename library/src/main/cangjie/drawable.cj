/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2025. All rights reserved.
 */
 
package droplet



public interface Drawable {
    func getPixelMap(): PixelMap;
    func draw(isErrorPic:Bool): Unit;
    func setDrawFunc(drawFunc: (PixelMap) -> Unit): Unit
    func getType(): Int64
}

public class NoneDrawable <: Drawable {

    private let noneDrawableType:Int64 = -1

    public override func getPixelMap(): PixelMap {
        let size: Size = Size(width: 1, height: 1)
        let arr: Array<UInt8> = Array<UInt8>(96, repeat: 0)
        return createPixelMap(arr, InitializationOptions(size: size))
    }
    public override func draw(_:Bool): Unit {}
    public override func setDrawFunc(_: (PixelMap) -> Unit): Unit {}
    public override func getType(): Int64 {
        return noneDrawableType
    }
}

public class PixelMapDrawable <: Drawable {
    private static let mtx = ReentrantMutex()

    private let pixelMapDrawableType:Int64 = 1
    private let pixelMap: PixelMap
    private var drawFunc: ArrayList<(PixelMap) -> Unit> = ArrayList<(PixelMap) -> Unit>()

    public init(pixelMap: PixelMap) {
        this.pixelMap = pixelMap
    }

    public override func getType(): Int64 {
        return pixelMapDrawableType
    }

    public override func getPixelMap(): PixelMap {
        return this.pixelMap
    }

    public override func draw(_:Bool): Unit {
       synchronized(mtx){
           if(this.drawFunc.size > 0) {
                for(f in this.drawFunc) {
                    f(this.pixelMap)
                }
            }
        }
    }

    public override func setDrawFunc(drawFunc: (PixelMap) -> Unit): Unit {
        synchronized(mtx){
            this.drawFunc.clear()
            this.drawFunc.add(drawFunc)
        }
    }
}

public class CJResourceDrawable <: Drawable {
    private let cJResourceDrawableType:Int64 = 3
    private let cjResource: AppResource
    private var drawFunc: ArrayList<(AppResource,Bool) -> Unit> = ArrayList<(AppResource,Bool) -> Unit>()

     func getCJResource(): AppResource {
        return cjResource
    }

    public init(cjResource: AppResource) {
        this.cjResource = cjResource
    }

    public override func getType(): Int64 {
        return cJResourceDrawableType
    }

    public override func getPixelMap(): PixelMap {
        let size: Size = Size(width: 1, height: 1)
        let arr: Array<UInt8> = Array<UInt8>(96, repeat: 0)
        return createPixelMap(arr, InitializationOptions(size: size))
    }

    public override func draw(isErrorPic:Bool): Unit {
        if(this.drawFunc.size > 0) {
            for(f in this.drawFunc) {
                f(this.cjResource,isErrorPic)
            }
        }
    }

    public override func setDrawFunc(_: (PixelMap) -> Unit): Unit {
    }

     func setDrawFuncCJResource(drawFunc: (AppResource,Bool) -> Unit): Unit {
        this.drawFunc.clear()
        this.drawFunc.add(drawFunc)
    }
}
