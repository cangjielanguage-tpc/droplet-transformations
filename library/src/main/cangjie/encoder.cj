/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package droplet

import ohos.file_fs.FileFs
import ohos.file_fs.OpenMode

public interface Encoder<T> {
  /**
   * Writes the given data to the given output stream and returns True if the write completed
   * successfully and should be committed.
   *
   * @param data The data to write.
   * @param file The file to write the data to.
   * @param options The set of options to apply when encoding.
   */
  func encode(data: T, file: DropletFile, options: DropletOptions): Bool;
}

public interface AnyResourceEncoder {
  // specializing the generic arguments
  func getEncodeStrategy(options: DropletOptions): EncodeStrategy;
}

public interface ResourceEncoder<T> <: Encoder<DropletResource<T>> & AnyResourceEncoder {
  
}

public class PixelMapEncoder <: ResourceEncoder<PixelMap> {
  public func getEncodeStrategy(_: DropletOptions): EncodeStrategy {
    return EncodeStrategy.TRANSFORMED
  }

  public func encode(data: DropletResource<PixelMap>, file: DropletFile, _: DropletOptions): Bool {
    let pixelMap: PixelMap = data.get()
    let info = pixelMap.getImageInfo()
    let arr: Array<UInt8> = Array<UInt8>(Int64(pixelMap.getPixelBytesNumber()), repeat: 0)
    pixelMap.readPixelsToBuffer(arr)
    if(arr.size > 0) {
      let width: Int32 = info.size.width
      let height: Int32 = info.size.height
      let imageInfoArr: Array<UInt8> = Array<UInt8>(4, repeat: 0)
      imageInfoArr[0] = UInt8(width >> 8 & 0xFF);
      imageInfoArr[1] = UInt8(width & 0xFF);
      imageInfoArr[2] = UInt8(height >> 8 & 0xFF);
      imageInfoArr[3] = UInt8(height & 0xFF);
      let f = file.getFile()
      f.write(imageInfoArr)
      f.write(arr)
      f.flush()
      f.close()
    }
    return true
  }
}

public class PixelMapDrawableEncoder <: ResourceEncoder<PixelMapDrawable> {
  public func getEncodeStrategy(_: DropletOptions): EncodeStrategy {
    return EncodeStrategy.TRANSFORMED
  }

    public func encode(data: DropletResource<PixelMapDrawable>, file: DropletFile, _: DropletOptions): Bool {
            let pixelMap:PixelMap = data.get().getPixelMap()
            let imagePacker : ImagePacker = createImagePacker()
            let path = file.filePath.toString()
            let tempFile = FileFs.open(path,mode:CREATE.mode|WRITE_ONLY.mode)
            let packingOption = PackingOption("image/png",100)
            try{
                imagePacker.packToFile(pixelMap, IntNative(tempFile.fd), packingOption)
            }catch(e:Exception){
                AppLog.error("${e.toString()}")
            }
         return true
     }
}

