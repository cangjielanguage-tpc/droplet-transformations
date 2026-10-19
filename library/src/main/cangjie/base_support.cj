/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2025. All rights reserved.
 */
 
package droplet



public class DropletString <: AnyDropletOptionValue & DropletAny<DropletString> {
  public let str: String
  public init(str: String) {
    this.str = str
  }
  public func toString(): String {
    return str
  }

  public operator func ==(that: AnyDropletOptionValue): Bool {
    if(that is DropletString) {
        return this.str == (that as DropletString).getOrThrow().str
    }
    return false
  }

  public operator func !=(that: AnyDropletOptionValue): Bool {
    if(that is DropletString) {
        return this.str != (that as DropletString).getOrThrow().str
    }
      return true
  }

  public operator func ==(that: DropletString): Bool {
    return this.str == that.str
  }

  public operator func !=(that: DropletString): Bool {
    return this.str != that.str
  }

  public func hashCode(): Int64 {
      return this.str.hashCode()
  }
}

public class DropletInt <: AnyDropletOptionValue {

    public var key: Int64 = 0
    public init(key: Int64) {
        this.key = key
    }

    public operator func ==(that: AnyDropletOptionValue): Bool {
        if(that is DropletInt) {
            return key == (that as DropletInt).getOrThrow().key
        }
        return false;
    }

    public operator func !=(that: AnyDropletOptionValue): Bool {
        if(that is DropletInt) {
            return key != (that as DropletInt).getOrThrow().key
        }
        return true
    }

    public func hashCode(): Int64 {
        return key.hashCode()
    }

    public func toString(): String {
        return "Option{key=${key}}";
    }
}

public interface AnyDropletOptionValue <: DropletAny<AnyDropletOptionValue> {

}

public interface DropletAny<K> <: ToString & Equatable<K> & Hashable {
}

public class DropletFile <: DropletAny<DropletFile> {
    public var filePath: FSPath
    public var file: Option<File> = None
    public var directory: Option<FSPath> = None
    public var stringWriter: Option<StringWriter<File>> = None
    public var stringReader: Option<StringReader<File>> = None
    private let mtx = ReentrantMutex()

    public init(){
        this.filePath = FSPath("")
    }

    public init(path: FSPath) {
        this.filePath = path
    }

    public init(file: File) {
        this.filePath = file.info.path
        this.file = file
    }

    public init(path: String) {
        this(FSPath(path))
    }
    
    public init(parent: String, child: String) {
        this("${parent}/${child}")
    }

    public init(parent: DropletFile, child: String) {
        this(parent.filePath.join(child))
    }

    public init(parent: DropletFile, child: FSPath) {
        this(parent.filePath.join(child))
    }

    func openFile() {
        if(exists(this.filePath) && FileInfo(this.filePath).isDirectory()) {
            this.directory = this.filePath
        } else if(exists(this.filePath) && FileInfo(this.filePath).isRegular()) {
            this.file = File(this.filePath, ReadWrite)
        } else if(!exists(this.filePath)) {
            this.file = File(this.filePath, ReadWrite)
        } else {
            throw Exception("openFile: error  file path ${this.filePath}")
        }
    }

     func safeOpenFile() {
        if(let Some(i) <- this.file){
            if(i.isClosed()) {
                openFile()
            }
        }else{
            openFile()
        }
    }

     func close(): Unit {
        if(!this.file.getOrThrow().isClosed()) {
            this.file.getOrThrow().close()
        }
    }

     func getStringReader(): StringReader<File> {
        safeOpenFile()
        return StringReader(this.file.getOrThrow())
    }

     func getStringWriter(): StringWriter<File> {
        safeOpenFile()
        this.file.getOrThrow().seek(SeekPosition.End(0))
        return StringWriter(this.file.getOrThrow())
    }

     func getFile(): File {
        safeOpenFile()
        this.file.getOrThrow().seek(SeekPosition.End(0))
        return this.file.getOrThrow()
    }

     func getFileNoSeek(): File {
        safeOpenFile()
        return this.file.getOrThrow()
    }

     func toByteBuffer(): ByteBufferes {
        synchronized (mtx) {
            let outStream: ByteBufferes = ByteBufferes()
            safeOpenFile()
            copyToStream(outStream,this.file.getOrThrow())
            this.file.getOrThrow().close()
            return outStream
        }
    }

        func copyToStream(outStream:ByteBufferes,file:File){
            var arrDataTemp:Array<UInt8> = Array<UInt8>(2048,repeat:0)
            var read:Int64 = 0
            do{
                if(!exists(file.info.path)){
                    AppLog.error("preload cache file 不存在") //打印过
                }
                read = this.file.getOrThrow().read(arrDataTemp)
                outStream.write(arrDataTemp.slice(0,read))
            }while(read > 0)
        }

     func length(): Int64 {
        return FileInfo(this.filePath).size
    }

     func isDirectory(): Bool {
        let r = exists(this.filePath) && FileInfo(this.filePath).isDirectory()
        return r
    }

     func isFile(): Bool {
        return exists(this.filePath) && FileInfo(this.filePath).isRegular()
    }

     func exists(): Bool {
        return exists(this.filePath)
    }

    func delete(): Bool {
        if (isFile()) {
            if (let Some(i) <- this.file) {
                i.close()
            }
            remove(this.filePath)
            return true
        } else if (isDirectory()) {
            if (let Some(i) <- this.directory) {
                remove(this.filePath)
                return true
            }
        }
        return false
    }

     func renameTo(to: DropletFile): Bool {
        if(!isFile()) {
            return false
        }
        try {
             rename(this.filePath, to:to.filePath, overwrite:false)
        } catch(e: Exception) {
            return false
        }

        return true
    }

     func mkdirs(): Bool {
        if(isFile()) {
            return false
        }
        if(!exists(this.filePath)) {
            Directory.create(this.filePath, recursive: true)
            this.directory = this.filePath
            return true
        }
        return false
    }

    public func toString(): String {
        return this.filePath.toString()
    }

    public func hashCode(): Int64 {
        return this.filePath.hashCode()
    }

    public operator func ==(that: DropletFile): Bool {
        return this.filePath == that.filePath
    }

    public operator func !=(that: DropletFile): Bool {
        return this.filePath != that.filePath
    }


}
