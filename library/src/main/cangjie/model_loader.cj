/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package droplet

public interface ModelLoader {
    func loadModel(t: Any, options: DropletOptions,customGetImage:Option<(String)->InputStream>,paramMap:?HashMap<String,String>): Option<InputStream>
}

public class FileModelLoader <: ModelLoader {
    public override func loadModel(o: Any, _: DropletOptions,_:Option<(String)->InputStream>,_:?HashMap<String,String>): Option<InputStream> {
        if (o is File) {
            return (o as File).getOrThrow()
        } else {
            return None
        }
    }
}

public class ResourceModelLoader <: ModelLoader {
    public override func loadModel(o: Any, _: DropletOptions,_:Option<(String)->InputStream>,_:?HashMap<String,String>): Option<InputStream> {
        if (o is AppResource) {
            return getImageFromResource((o as AppResource).getOrThrow())
        } else {
            return None
        }
    }

    private func getImageFromResource(res:AppResource): Option<InputStream> {
          try {
            let resourceManager = ResourceManager.getResourceManager(Droplet.globalcontext.getOrThrow())
            let arr: Array<UInt8> = resourceManager.getMediaContent(Int32(res.id),0)
            var byteStream: ByteBufferes = ByteBufferes()
            byteStream.write(arr)
            return byteStream
        } catch (e: Exception) {
            return None
        }
    }
}


 class CancelBean{
    public var isCancel:Bool = false

    public func setCancel(b:Bool){
        this.isCancel = b
    }
 }

public class StringModelLoader <: ModelLoader {
    public override func loadModel(o: Any, _: DropletOptions,customeGetImage:Option<(String)->InputStream>,paramMap:?HashMap<String,String>): Option<InputStream> {
        if (o is String) {
            let s: String = (o as String).getOrThrow()
            getImage(s,customeGetImage,paramMap)
        } else {
            return None
        }
    }

    private func getImage(path: String,customeGetImage:Option<(String)->InputStream>,paramMap:?HashMap<String,String>): Option<InputStream> {
        let s: String = path.trimAscii()
        if (s.startsWith("/")) {
            return getImageFromFile(s)
        } else if (s.startsWith("http")) {
            if(customeGetImage.isNone()){
                return getImageFromHttpClient(s,paramMap)
            }else{
                return customeGetImage.getOrThrow()(s)
            }
        } else {
            return getImageFromRawFile(s)
        }
    }

    private func getImageFromFile(path: String): Option<InputStream> {
        let f: File = File(path, ReadWrite)
        if (f.canRead()) {
            return Some(f)
        }
        return None
    }

    private func getImageFromHttpClient(path: String,headerMap:?HashMap<String,String>): Option<InputStream> {
        let cancelBean = CancelBean()
        let f = EventCallback("callback",{
            e:EventData =>
                cancelBean.setCancel(true)
                Emitter.off(path)
                })
        Emitter.once(path,f)
        var tls = TlsClientConfig()
        tls.verifyMode = CertificateVerifyMode.TrustAll
        var client = ClientBuilder().readTimeout(Duration.minute * 1).tlsConfig(tls).build()

        var requestBuilder = HttpRequestBuilder()

        if(!headerMap.isNone()){
            for((k,v) in headerMap.getOrThrow()){
                requestBuilder.header(k,v)
            }
        }

        let req = requestBuilder
                   .method("GET")
                   .url(path)
                   .build()

        if(cancelBean.isCancel){
            Emitter.off(path)
            client.close()
            return None
        }
        let resp = client.send(req)
        if(cancelBean.isCancel){
            Emitter.off(path)
            client.close()
            return None
        }
        Emitter.off(path)
        return Some(resp.body)
    }

    private func getImageFromRawFile(rawFileName: String): Option<InputStream> {
        try {
            let resourceManager = ResourceManager.getResourceManager(
                Droplet.globalcontext.getOrThrow())
            let arr: Array<UInt8> = resourceManager.getRawFileContent(rawFileName)
            var byteStream: ByteBufferes = ByteBufferes()
            byteStream.write(arr)
            return byteStream
        } catch (e: Exception) {
            return None
        }
    }

}
