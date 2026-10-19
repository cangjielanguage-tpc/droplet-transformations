/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet


public class Manager {
    private var mtx: ReentrantMutex
    // modelloaders
    private let stringModelLoaders: ArrayList<ModelLoader> = ArrayList<ModelLoader>()
    private let fileModelLoaders: ArrayList<ModelLoader> = ArrayList<ModelLoader>()
    private let resourceModelLoaders: ArrayList<ModelLoader> = ArrayList<ModelLoader>()

    // decoders
    private let drawableResourceDecoders: ArrayList<ResourceDecoder<Array<UInt8>, Drawable>> = ArrayList<ResourceDecoder<Array<UInt8>, Drawable>>()
    private let pixelMapResourceDecoders: ArrayList<ResourceDecoder<Array<UInt8>, PixelMap>> = ArrayList<ResourceDecoder<Array<UInt8>, PixelMap>>()

    private let drawableResourceParser: PixelMapDrawableResourceParser = PixelMapDrawableResourceParser()

    public init(mtx: ReentrantMutex) {
        this.mtx = mtx
        this.stringModelLoaders.add(StringModelLoader())
        this.resourceModelLoaders.add(ResourceModelLoader())
        this.fileModelLoaders.add(FileModelLoader())

        this.drawableResourceDecoders.add(PixelMapDrawableResourceDecoder())
        this.drawableResourceDecoders.add(GifDrawableResourceDecoder())

        this.pixelMapResourceDecoders.add(PixelMapResourceDecoder())
    }

     func getStringModelLoaders(): ArrayList<ModelLoader> {
        synchronized (mtx) {
            return stringModelLoaders
        }
    }

      func getResourceModelLoaders(): ArrayList<ModelLoader> {
        synchronized (mtx) {
            return resourceModelLoaders
        }
    }

     func getFileModelLoaders(): ArrayList<ModelLoader> {
        synchronized (mtx) {
            return fileModelLoaders
        }
    }

     func setStringModelLoader(modelLoader: ModelLoader): Unit {
        synchronized (mtx) {
            this.stringModelLoaders.clear()
            this.stringModelLoaders.add(modelLoader)
        }
    }

    func setResourceModelLoader(modelLoader: ModelLoader): Unit {
        synchronized (mtx) {
            this.resourceModelLoaders.clear()
            this.resourceModelLoaders.add(modelLoader)
        }
    }

     func setFileModelLoader(modelLoader: ModelLoader): Unit {
        synchronized (mtx) {
            this.fileModelLoaders.clear()
            this.fileModelLoaders.add(modelLoader)
        }
    }

     func addDrawableResourceDecoder(decoder: ResourceDecoder<Array<UInt8>, Drawable>): Unit {
        synchronized (mtx) {
            this.drawableResourceDecoders.add(decoder)
        }
    }

     func getDrawableResourceParser(): ResourceDecoder<Array<UInt8>, Drawable> {
        synchronized (mtx) {
            return drawableResourceParser
        }
    }

     func getDrawableResourceDecoders(): ArrayList<ResourceDecoder<Array<UInt8>, Drawable>> {
        synchronized (mtx) {
            return this.drawableResourceDecoders
        }
    }

     func addPixelMapResourceDecoder(decoder: ResourceDecoder<Array<UInt8>, PixelMap>): Unit {
        synchronized (mtx) {
            this.pixelMapResourceDecoders.add(decoder)
        }
    }

     func getPixelMapResourceDecoders(): ArrayList<ResourceDecoder<Array<UInt8>, PixelMap>> {
        synchronized (mtx) {
            return this.pixelMapResourceDecoders
        }
    }

}
