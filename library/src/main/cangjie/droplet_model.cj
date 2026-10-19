/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet



public enum ModelType {
    ARRAY | STRING | FILE | GIFDECODER | NONE | CJRESOURCE
}

public abstract class Model <: DropletAny<Model> {
    public var arr: Array<UInt8> = Array<UInt8>()
    public var str: String = ""
    public var file: DropletFile = DropletFile("")
    public var res: AppResource = AppResource("app","media",1)
    public var decoder: Option<GifDecoder> = None
    public var modelType: ModelType = ModelType.NONE
    public var mCustomeGetImage:Option<(String)->InputStream> = Option<(String)->InputStream>.None
    public var mParamMap:?HashMap<String,String> = Option<HashMap<String,String>>.None

    init(arr: Array<UInt8>) {
        this.arr = arr
        this.modelType = ModelType.ARRAY
    }

    init(str: String) {
        this.str = str
        this.modelType = ModelType.STRING
    }

    init(str: String,customeGetImage:Option<(String)->InputStream>,paramMap:?HashMap<String,String>) {
        this.str = str
        this.mCustomeGetImage = customeGetImage
        this.mParamMap = paramMap
        this.modelType = ModelType.STRING
    }

    init(file: FSPath) {
        this.file = DropletFile(file)
        this.modelType = ModelType.FILE
    }

    init(file: File) {
        this.file = DropletFile(file)
        this.modelType = ModelType.FILE
    }

    init(res: AppResource) {
        this.res = res
        this.modelType = ModelType.CJRESOURCE
    }

    init(decoder: GifDecoder) {
        this.decoder = decoder
        this.modelType = ModelType.GIFDECODER
    }

    public func toString(): String {
        match(modelType) {
            case ModelType.ARRAY => "modeltype: ${this.arr}"
            case ModelType.STRING => "modeltype: ${this.str}"
            case ModelType.FILE => "modeltype: ${this.file}"
            case ModelType.GIFDECODER => "modeltype: ${this.file}"
            case ModelType.CJRESOURCE => "modeltype: res ${this.res.id}"
            case ModelType.NONE => "modeltype: NONE"
        }
    }

    public func hashCode(): Int64 {
        match(modelType) {
            case ModelType.ARRAY => Utils.hashCode<UInt8>(this.arr)
            case ModelType.STRING => this.str.hashCode()
            case ModelType.FILE => this.file.hashCode()
            case ModelType.CJRESOURCE => Int64(this.res.id)
            case ModelType.GIFDECODER => 0i64
            case ModelType.NONE => 0i64
        }
    }

    public operator func ==(that: Model): Bool {
        if(that is LoadModel) {
            var t = (that as LoadModel).getOrThrow()
            return this.arr == t.arr && this.str == t.str && this.file == t.file && this.res.id == t.res.id
        }
        return false
    }

    public operator func !=(that: Model): Bool {
        if(that is LoadModel) {
            var t = (that as LoadModel).getOrThrow()
            return !(this.arr == t.arr && this.str == t.str && this.file == t.file && this.res.id == t.res.id)
        }
        return true
    }

    func getDataSource(): DataSource {
        match(modelType) {
            case ModelType.ARRAY => DataSource.LOCAL
            case ModelType.STRING => 
                if(str.startsWith("/")) {
                    DataSource.LOCAL
                } else if(str.startsWith("http")) {
                    DataSource.REMOTE
                } else {
                    DataSource.LOCAL
                }
            case ModelType.FILE => DataSource.LOCAL
            case ModelType.CJRESOURCE => DataSource.LOCAL
            case ModelType.GIFDECODER => DataSource.LOCAL
            case ModelType.NONE => DataSource.NONE
        }
    }

}

public class LoadModel <: Model {
    init(arr: Array<UInt8>) {
        super(arr)
    }

    init(str: String) {
        super(str)
    }

    init(str: String,customeGetImage:Option<(String)->InputStream>,paramMap:?HashMap<String,String>) {
        super(str,customeGetImage,paramMap)
    }

    init(file: FSPath) {
        super(file)
    }

    init(file: File) {
        super(file)
    }

    init(res: AppResource) {
        super(res)
    }
}
