/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */

package droplet

import ohos.state_manage.*
import ohos.state_macro_manage.*
internal import ohos.base.*
internal import ohos.component.*
internal import ohos.image.Component as ImageComponent
internal import ohos.image.Image as ImageImage
internal import ohos.image.PixelMap
internal import ohos.image.InitializationOptions
internal import ohos.image.PixelMapFormat
internal import ohos.image.Size
internal import ohos.image.Region
internal import ohos.image.PositionArea
internal import ohos.image.createPixelMap
internal import ohos.image.createImageSource
internal import ohos.image.ImageSource
internal import ohos.image.SourceOptions
internal import ohos.image.DecodingOptions
internal import ohos.image.ImageInfo
internal import ohos.resource_manager.*
internal import ohos.animator.*
internal import ohos.ability.*
internal import ohos.concurrency.*

internal import stdx.net.http.*
internal import std.net.*
internal import stdx.net.tls.*

internal import std.io.*
internal import std.io.ByteBuffer as ByteBufferes

internal import stdx.encoding.url.*

internal import std.fs.Path as FSPath
internal import std.fs.*
internal import std.time.*
internal import std.collection.*
internal import std.math.*
internal import stdx.encoding.hex.*
internal import std.sync.*
internal import std.overflow.*
internal import std.convert.*
internal import ohos.emitter.*
internal import ohos.ark_interop_helper.StageContext
internal import ohos.image.ImagePacker
internal import ohos.image.createImagePacker
internal import ohos.image.PackingOption

/**
 * Created on 2024/3/4
 */
public class DropletRequestOption {

    private static let count = AtomicInt64(1)

    private let id = count.fetchAdd(1)

    let emitkey = "updateImg${id}"

    private var _loadSrc:String = ""

    public mut prop loadSrc:String{
        get(){
            _loadSrc
        }
        set(v){
            _loadSrc = v
            Emitter.emit(emitkey)
        }
    }

    private var _loadSrcRes : ?AppResource = Option<AppResource>.None

    public mut prop loadSrcRes:?AppResource{
        get(){
            _loadSrcRes
        }
        set(v){
            _loadSrcRes = v
            Emitter.emit(emitkey)
        }
    }

    private var _placeholder : ?AppResource = Option<AppResource>.None

    public mut prop placeholder:?AppResource{
        get(){
            _placeholder
        }
        set(v){
            _placeholder = v
            Emitter.emit(emitkey)
        }
    }


    private var _errholder : ?AppResource = Option<AppResource>.None

    public mut prop errholder:?AppResource{
        get(){
            _errholder
        }
        set(v){
            _errholder = v
            Emitter.emit(emitkey)
        }
    }


    private var _strategy : ?DiskCacheStrategy = Option<DiskCacheStrategy>.None

    public mut prop strategy:?DiskCacheStrategy{
        get(){
            _strategy
        }
        set(v){
            _strategy = v
            Emitter.emit(emitkey)
        }
    }

     private var _transformCate : ?PixelMapTransformation = Option<PixelMapTransformation>.None

    public mut prop transformCate:?PixelMapTransformation{
        get(){
            _transformCate
        }
        set(v){
            _transformCate = v
            Emitter.emit(emitkey)
        }
    }

    private var _transformListCate : ?ArrayList<PixelMapTransformation> = Option<ArrayList<PixelMapTransformation>>.None

    public mut prop transformListCate:?ArrayList<PixelMapTransformation>{
        get(){
            _transformListCate
        }
        set(v){
            _transformListCate = v
            Emitter.emit(emitkey)
        }
    }


    private var _isSkipMemory : ?Bool = Option<Bool>.None

    public mut prop isSkipMemory:?Bool{
        get(){
            _isSkipMemory
        }
        set(v){
            _isSkipMemory = v
            Emitter.emit(emitkey)
        }
    }


    private var _overrideWH : ?(Int64, Int64) = Option<(Int64, Int64)>.None

    public mut prop overrideWH:?(Int64, Int64){
        get(){
            _overrideWH
        }
        set(v){
            _overrideWH = v
            Emitter.emit(emitkey)
        }
    }


     private var _applyRequestOption : ?RequestOptions = Option<RequestOptions>.None

    public mut prop applyRequestOption:?RequestOptions{
        get(){
            _applyRequestOption
        }
        set(v){
            _applyRequestOption = v
            Emitter.emit(emitkey)
        }
    }

    private var _onlyRetrieveFromCache : ?Bool = Option<Bool>.None

    public mut prop onlyRetrieveFromCache:?Bool{
        get(){
            _onlyRetrieveFromCache
        }
        set(v){
            _onlyRetrieveFromCache = v
            Emitter.emit(emitkey)
        }
    }


     private var _dontTransform : ?Bool = Option<Bool>.None

    public mut prop dontTransform:?Bool{
        get(){
            _dontTransform
        }
        set(v){
            _dontTransform = v
            Emitter.emit(emitkey)
        }
    }


   private var _useDefaultRequestOption : ?RequestOptions = Option<RequestOptions>.None

    public mut prop useDefaultRequestOption:?RequestOptions{
        get(){
            _useDefaultRequestOption
        }
        set(v){
            _useDefaultRequestOption = v
            Emitter.emit(emitkey)
        }
    }


    private var _thumbnail : ?Float32 = Option<Float32>.None

    public mut prop thumbnail:?Float32{
        get(){
            _thumbnail
        }
        set(v){
            _thumbnail = v
            Emitter.emit(emitkey)
        }
    }


    private var _thumbnaildrawable : ?RequestBuilder<Drawable> = Option<RequestBuilder<Drawable>>.None

    public mut prop thumbnaildrawable:?RequestBuilder<Drawable>{
        get(){
            _thumbnaildrawable
        }
        set(v){
            _thumbnaildrawable = v
            Emitter.emit(emitkey)
        }
    }


    private var _signature : ?String = Option<String>.None

    public mut prop signature:?String{
        get(){
            _signature
        }
        set(v){
            _signature = v
            Emitter.emit(emitkey)
        }
    }

    private var _transitionOption : ?TransitionOption = Option<TransitionOption>.None

    public mut prop transitionOption:?TransitionOption{
        get(){
            _transitionOption
        }
        set(v){
            _transitionOption = v
            Emitter.emit(emitkey)
        }
    }

    private var _imageFit:ImageFit = ImageFit.ScaleDown

    public mut prop imageFit:ImageFit{
        get(){
            _imageFit
        }
        set(v){
            _imageFit = v
            Emitter.emit(emitkey)
        }
    }

   private var _customGetImage : Option<(String) -> InputStream> = Option<(String) -> InputStream>.None

   public mut prop customGetImage:Option<(String) -> InputStream>{
        get(){
            _customGetImage
        }
        set(v){
            _customGetImage = v
            Emitter.emit(emitkey)
        }
    }

    private var _paramMap:?HashMap<String,String> = Option<HashMap<String,String>>.None

    public mut prop paramMap:Option<HashMap<String,String>>{
        get(){
            _paramMap
        }
        set(v){
            _paramMap = v
            Emitter.emit(emitkey)
        }
    }

    public init(
        loadSrc!: String = "",
        loadSrcRes!: ?AppResource = None,
        placeholder!: ?AppResource = None,
        errholder!: ?AppResource = None,
        strategy!: ?DiskCacheStrategy = None,
        transformCate!: ?PixelMapTransformation = None,
        transformListCate!: ?ArrayList<PixelMapTransformation> = None,
        isSkipMemory!: ?Bool = None,
        overrideWH!: ?(Int64,Int64) = None,
        applyRequestOption!: ?RequestOptions = None,
        onlyRetrieveFromCache!: ?Bool = None,
        dontTransform!: ?Bool = None,
        useDefaultRequestOption!: ?RequestOptions = None,
        thumbnail!: ?Float32 = None,
        thumbnaildrawable!: ?RequestBuilder<Drawable> = None,
        signature!: ?String = None,
        transitionOption!: ?TransitionOption = None,
        imageFit !: ImageFit = ImageFit.ScaleDown,
        customGetImage !: Option<(String) -> InputStream> = None,
        paramMap !: ?HashMap<String,String> = None
    ){
        this._loadSrc = loadSrc
        this._loadSrcRes = loadSrcRes
        this._placeholder = placeholder
        this._errholder = errholder
        this._strategy = strategy
        this._transformCate = transformCate
        this._transformListCate = transformListCate
        this._isSkipMemory = isSkipMemory
        this._overrideWH = overrideWH
        this._applyRequestOption = applyRequestOption
        this._onlyRetrieveFromCache = onlyRetrieveFromCache
        this._dontTransform = dontTransform
        this._useDefaultRequestOption = useDefaultRequestOption
        this._thumbnail = thumbnail
        this._thumbnaildrawable = thumbnaildrawable
        this._signature = signature
        this._transitionOption = transitionOption
        this._imageFit = imageFit
        this._customGetImage = customGetImage
        this._paramMap = paramMap
    }

    public func update(
        loadSrc!: ?String = None,
        loadSrcRes!: ??AppResource = None,
        placeholder!: ??AppResource = None,
        errholder!: ??AppResource = None,
        strategy!: ??DiskCacheStrategy = None,
        transformCate!: ??PixelMapTransformation = None,
        transformListCate!: ??ArrayList<PixelMapTransformation> = None,
        isSkipMemory!: ??Bool = None,
        overrideWH!: ??(Int64,Int64) = None,
        applyRequestOption!: ??RequestOptions = None,
        onlyRetrieveFromCache!: ??Bool = None,
        dontTransform!: ??Bool = None,
        useDefaultRequestOption!: ??RequestOptions = None,
        thumbnail!: ??Float32 = None,
        thumbnaildrawable!: ??RequestBuilder<Drawable> = None,
        signature!: ??String = None,
        transitionOption!: ??TransitionOption = None,
        imageFit !: ?ImageFit = None,
        customGetImage !: Option<Option<(String) -> InputStream>> = None,
        paramMap !: ??HashMap<String,String> = None
    ):Unit{
        if(let Some(i) <- loadSrc){
            this._loadSrc = i
        }

        if(let Some(i) <- loadSrcRes){
            this._loadSrcRes = i
        }

        if(let Some(i) <- placeholder){
            this._placeholder = i
        }

        if(let Some(i) <- errholder){
            this._errholder = i
        }

        if(let Some(i) <- strategy){
            this._strategy = i
        }

        if(let Some(i) <- transformCate){
            this._transformCate = i
        }

        if(let Some(i) <- transformListCate){
            this._transformListCate = i
        }

        if(let Some(i) <- isSkipMemory){
            this._isSkipMemory = i
        }

        if(let Some(i) <- overrideWH){
            this._overrideWH = i
        }

         if(let Some(i) <- applyRequestOption){
            this._applyRequestOption = i
        }

         if(let Some(i) <- onlyRetrieveFromCache){
            this._onlyRetrieveFromCache = i
        }

         if(let Some(i) <- dontTransform){
            this._dontTransform = i
        }

        if(let Some(i) <- useDefaultRequestOption){
            this._useDefaultRequestOption = i
        }

         if(let Some(i) <- thumbnail){
            this._thumbnail = i
        }

        if(let Some(i) <- thumbnaildrawable){
            this._thumbnaildrawable = i
        }

        if(let Some(i) <- signature){
            this._signature = i
        }

        if(let Some(i) <- transitionOption){
            this._transitionOption = i
        }

         if(let Some(i) <- imageFit){
            this._imageFit = i
        }

        if(let Some(i) <- customGetImage){
            this._customGetImage = i
        }

        if(let Some(i) <- paramMap){
            this._paramMap = i
        }
        Emitter.emit(emitkey)
    }
}

@Component
public class DropletImageComponent {
    @Link
    var dropletOption: DropletRequestOption

    var globalContext: Option<StageContext> = Option<StageContext>.None

    @State
    var imageViewWidth: Length = 100.percent

    @State
    var imageViewHeight: Length = 100.percent

    /*生命周期管理用到的标签名称 */
    @State
    var label: String = ""

    /*加载状态*/
    @State
    var isLoading: Bool = true
    /*错误状态*/
    @State
    var isError: Bool = false

    /*加载状态*/
    @State
    var opacityValue: Float64 = 1.0 //默认不透明

    @State
    var rotateValue: Float32 = 0.0

    @State
    var scaleValue: Float32 = 1.0

    @State
    var TranslateValue: Float64 = 0.0

    var flag: Bool = false

    var oldWidth: Int64 = 0
    var oldHeight: Int64 = 0

    let size: Size = Size(width: 1, height: 1)
    let opts: InitializationOptions = InitializationOptions(size: size)
    let color: Array<UInt8> = Array<UInt8>(96, repeat: 0)
    @State
    var pixelMap: PixelMap = createPixelMap(color, opts)

    @State
    var resourceFn: Option<(PixelMap) -> Unit> = Option<(PixelMap) -> Unit>.None

    @State
    var failedFn: Option<(DropletException) -> Unit> = Option<(DropletException) -> Unit>.None

    func updateImg(width: Int64, height: Int64) {
        if ((dropletOption.loadSrc != "" && width > 0 && height > 0) || (!dropletOption.loadSrcRes.isNone() && width > 0 &&
            height > 0)) {
            var requestManager = Option<RequestManager>.None

            if (let Some(v) <- dropletOption.useDefaultRequestOption) {
                requestManager = Droplet.withContext(globalContext.getOrThrow(), label).useDefaultRequestOptions(v)
            } else {
                requestManager = Droplet.withContext(globalContext.getOrThrow(), label)
            }

            var tempBuilder: Option<RequestBuilder<Drawable>> = Option<RequestBuilder<Drawable>>.None
            if (dropletOption.loadSrc != "") {
                tempBuilder = requestManager.getOrThrow().load(dropletOption.loadSrc,dropletOption.customGetImage,dropletOption.paramMap)
            } else if (!dropletOption.loadSrcRes.isNone()) {
                tempBuilder = requestManager.getOrThrow().load(dropletOption.loadSrcRes.getOrThrow())
            } else {
                throw Exception("loadSrc and loadSrcRes can not both be empty")
            }

            var builder = tempBuilder.getOrThrow()

            //设置三级缓存策略
            if (let Some(v) <- dropletOption.strategy) {
                builder = builder.setDiskCacheStrategy(v)
            }

            if (let Some(v) <- dropletOption.onlyRetrieveFromCache) {
                builder = builder.onlyRetrieveFromCachecj(v, builder)
            }

            if (let Some(v) <- dropletOption.isSkipMemory) {
                builder = builder.skipMemoryCache(v, builder)
            }

            if (let Some(v) <- dropletOption.thumbnail) {
                builder = builder.thumbnail(v)
            }

            if (let Some(v) <- dropletOption.thumbnaildrawable) {
                builder = builder.thumbnail(v)
            }

            if (let Some(v) <- dropletOption.overrideWH) {
                builder = builder.setOverride(v[0], v[1])
            }

            if (let Some(v) <- dropletOption.transformCate) {
                builder = builder.transform(v)
            }

            if (let Some(v) <- dropletOption.transformListCate) {
                if (v.size > 1) {
                    builder = builder.transforms(v)
                } else if (v.size == 1) {
                    builder = builder.transform(v[0])
                }
            }

            if (let Some(v) <- dropletOption.dontTransform) {
                if (v) {
                    builder = builder.dontTransform(builder)
                }
            }

            if(let Some(v) <- dropletOption.placeholder){
                builder = builder.placeholder(v)
                builder.setPlaceholderFunc({
                    p:PixelMap => launch{
                        pixelMap = p
                    }
                })
            }

            if (let Some(v) <- dropletOption.errholder) {
                builder = builder.error(v)
            }

            if (let Some(v) <- dropletOption.applyRequestOption) {
                builder = builder.apply(v)
            }

            if (let Some(v) <- dropletOption.signature) {
                builder = builder.setSignature(StringKey(v))
            }

            builder
                .listener(
                    {
                        drawable: Drawable, model: Model, target: Target<Drawable>, datasource: DataSource, 
                        isFirstResource: Bool =>
                        if (resourceFn.isSome()) {
                            resourceFn.getOrThrow()(drawable.getPixelMap())
                        }
                        return false
                    },
                    {
                        e: DropletException, model: Model, target: Target<Drawable>, isFirstResource: Bool =>
                        if (failedFn.isSome()) {
                            failedFn.getOrThrow()(e)
                        }
                        return false
                    }
                )
                .into(
                    {
                        p: PixelMap => launch {
                            isLoading = false
                            pixelMap = p

                            if (let Some(i) <- dropletOption.transitionOption) {
                                //创建动画对象
                                var backAnimator: ?AnimatorResult = AnimatorResult(
                                    AnimatorOptions(
                                        duration: i.getDuration(),
                                        easing: "linear",
                                        delay: 0,
                                        fill: AnimatorFill.Forwards,
                                        direction: AnimatorDirection.Normal,
                                        iterations: 1,
                                        begin: i.getBegin(),
                                        end: i.getEnd()
                                    )
                                )
                                //表明有动画
                                match (i.getTransType()) {
                                    case Opacity => backAnimator?.onframe = {
                                        value: Float64 => this.opacityValue = value
                                    }
                                    case Rotate => backAnimator?.onframe = {
                                        value: Float64 => this.rotateValue = (Float32(value))
                                    }
                                    case Scale => backAnimator?.onframe = {
                                        value: Float64 => this.scaleValue = (Float32(value))
                                    }
                                    case Translate => backAnimator?.onframe = {
                                        value: Float64 => this.TranslateValue = value
                                    }
                                    case _ => false
                                }
                                let callBackGet2 = backAnimator?.onframe
                                let fun2 = callBackGet2.getOrThrow()
                                backAnimator?.play()
                            }
                        }
                    },
                    {
                        cjres: AppResource, isErrorPic: Bool => if (isErrorPic) {
                            launch {
                                isError = true
                                if (let Some(v) <- dropletOption.errholder) {
                                    this.pixelMap = errorhoderToPiexlMap().getOrThrow()
                                }
                            }
                        }
                    },
                    width,
                    height
                )
        }
    }

    func callback(eventData:EventData):Unit{
        updateImg(oldWidth,oldHeight)
    }


    protected override func aboutToAppear() {
        let f = EventCallback("updateImgcallback",callback)
        Emitter.on(dropletOption.emitkey,f)
    }

    protected override func aboutToDisappear() {
        Emitter.off(dropletOption.emitkey)
    }


    func errorhoderToPiexlMap(): ?PixelMap {
        if (let Some(v) <- dropletOption.errholder) {
            //这里将他转化为pixleMap
            let resourceManager = ResourceManager.getResourceManager(globalContext.getOrThrow())
            let arr: Array<UInt8> = resourceManager.getMediaContent(Int32(v.id), 0)
            let imageSource: ImageSource = createImageSource(arr)
            let regionSize: Size = Size(width: imageSource.getImageInfo().size.width,
                height: imageSource.getImageInfo().size.height)
            let desiredRegion: Region = Region(regionSize, 0, 0)
            let desiredSize: Size = Size(width: imageSource.getImageInfo().size.width,
                height: imageSource.getImageInfo().size.height)
            let decodingOptions = DecodingOptions(
                rotate: 0, //rotate: UInt32, //旋转角度。
                desiredSize: desiredSize, //desiredSize: Size, //期望输出大小。
                desiredRegion: desiredRegion, //desiredRegion: Region, //解码区域。
                index: 0, //index: Int32, //解码图片序号。
                desiredPixelFormat: PixelMapFormat.RGBA_8888, //解码的像素格式。
                editable: true,
                sampleSize: 1
            )
            return imageSource.createPixelMap(options: decodingOptions)
        } else {
            return Option<PixelMap>.None
        }
    }


    func build() {
        Image(this.pixelMap)
            .width(imageViewWidth)
            .height(imageViewHeight)
            .objectFit(dropletOption.imageFit)
            .opacity(opacityValue)
            .rotate(rotateValue)
            .scale(scaleValue)
            .translateX(TranslateValue)
            .onAreaChange(
                {
                    oldArea, newArea =>
                    let newWidth: Int64 = Int64(newArea.width)
                    let newHeight: Int64 = Int64(newArea.height)
                    if (oldWidth != newWidth || oldHeight != newHeight) {
                        if (!flag && newWidth > 0 && newHeight > 0) {
                            flag = true
                            let widthpx: ?Length = vp2px(newWidth.vp)
                            let heightpx:?Length = vp2px(newHeight.vp)
                            let width:Int64 = if(let Some(v) <- widthpx){
                                 Int64(v.value)
                            }else{
                                0
                            }

                            let height:Int64 = if(let Some(v) <- heightpx){
                                 Int64(v.value)
                            }else{
                                0
                            }

                            updateImg(width, height)
                            oldWidth = width
                            oldHeight = height
                        }
                    }
                }
            )
    }
}
