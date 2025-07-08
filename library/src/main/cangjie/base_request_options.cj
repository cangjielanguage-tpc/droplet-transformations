/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2025. All rights reserved.
 */

package droplet

public interface AnyRequestOptions {

    func getFields(): Int64

    func getTransformationAllowed(): Bool

    func getSignature(): AnyKey

    func getResourceTypeClass(): ResourceTypeClass

    func getSizeMultiplier(): Float32
    func getPlaceholderDrawable(): Option<CJResourceDrawable>
    func getErrorPlaceholderDrawable(): Option<CJResourceDrawable>

    func getOverrideWidth(): Int64
    func getOverrideHeight(): Int64

    func isPrioritySet(): Bool
    func isValidOverride(): Bool

    func getCacheable(): Bool

    func getTransformationRequired(): Bool

    func getScaleOnlyOrNoTransform(): Bool

    func getOnlyRetrieveFromCache(): Bool

    func getPlaceHolderFunc():Option<(PixelMap)->Unit>

    func equals(o: Any): Bool

    func getOptions(): DropletOptions

    func getDiskCacheStrategy(): DiskCacheStrategy

    func getTransformations(): CachedHashCodeArrayMap<TransformationKey, AnyKey>

    func getPriority(): Priority
}

public open class BaseRequestOptions<T> <: AnyRequestOptions where T <: BaseRequestOptions<T> {

    // 选项设置标记
    protected static let SIZE_MULTIPLIER = 1 << 1;
    // 硬盘缓存策略
    protected static let DISK_CACHE_STRATEGY = 1 << 2;
    protected static let PRIORITY = 1 << 3;
    // 错误图片
    protected static let ERROR_PLACEHOLDER = 1 << 4;
    // 占位图
    protected static let PLACEHOLDER = 1 << 6;
    // 是否使用内存缓存
    protected static let IS_CACHEABLE = 1 << 8;
    // 覆盖宽高
    protected static let OVERRIDE = 1 << 9;
    // 缓存自定义标记
    protected static let SIGNATURE = 1 << 10;
    // 图片变换
    protected static let TRANSFORMATION = 1 << 11;
    protected static let TRANSFORMATION_ALLOWED = 1 << 16;

    protected static let TRANSFORMATION_REQUIRED = 1 << 17;

    protected static let RESOURCE_CLASS = 1 << 12;

    protected static let ONLY_RETRIEVE_FROM_CACHE = 1 << 19;

    private var sizeMultiplier: Float32 = 1.0f32;

    // 属性
    private var fields: Int64 = 0;

    public var isLocked: Bool = false;

    public var isAutoCloneEnabled: Bool = false;

    private var options: DropletOptions = DropletOptions();

    private var isScaleOnlyOrNoTransform: Bool = true;

    private var isTransformationAllowed: Bool = true;

    private var isTransformationRequired: Bool = false;

    private var resourceTypeClass: ResourceTypeClass = ResourceTypeClass.RESOURCE_TYPE_NONE

    private var transformations: CachedHashCodeArrayMap<TransformationKey, AnyKey> = CachedHashCodeArrayMap<TransformationKey, AnyKey>(
        );

    private var errorPlaceholder: Option<CJResourceDrawable> = None;

    private var placeholderDrawable: Option<CJResourceDrawable> = None;

    private var priority: Priority = Priority.NORMAL;
    private var isCacheable: Bool = true

    private var overrideWidth: Int64 = 0;
    private var overrideHeight: Int64 = 0;

    private var onlyRetrieveFromCache: Bool = false;

    private var signature: AnyKey = EmptySignature.obtain();

    private var diskCacheStrategy: DiskCacheStrategy = DiskCacheStrategyALL();

    private var placeholderFunc:Option<(PixelMap)->Unit> = Option<(PixelMap)->Unit>.None

    public func getFields(): Int64 {
        return fields
    }

    public func getOptions(): DropletOptions {
        return options;
    }

    public func getTransformationRequired(): Bool {
        return isTransformationRequired
    }

    public func getScaleOnlyOrNoTransform(): Bool {
        return isScaleOnlyOrNoTransform
    }

    public func getOnlyRetrieveFromCache(): Bool {
        return onlyRetrieveFromCache
    }

    public func getPlaceHolderFunc():Option<(PixelMap) -> Unit>{
        return placeholderFunc
    }

    public func getSignature(): AnyKey {
        return signature
    }

    public func getResourceTypeClass(): ResourceTypeClass {
        return resourceTypeClass
    }

    public func getOverrideWidth(): Int64 {
        return overrideWidth;
    }

    public func getOverrideHeight(): Int64 {
        return overrideHeight;
    }

    public func getCacheable(): Bool {
        return isCacheable;
    }

    public func getDiskCacheStrategy(): DiskCacheStrategy {
        return diskCacheStrategy;
    }

    public func getTransformations(): CachedHashCodeArrayMap<TransformationKey, AnyKey> {
        return transformations;
    }

    func set<V>(option: DropletOption<V>, value: V, t: T): T where V <: AnyDropletOptionValue {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.set(option, value, t2);
        }
        t.options.set<V>(option, value);
        return selfOrThrowIfLocked();
    }

    public func setOptions(option: String, value: String): T {
        setOptions(option, value, (this as T).getOrThrow())
    }

    func setOptions(option: String, value: String, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.setOptions(option, value, t2);
        }
        t.options.setOptions(option, value);
        return selfOrThrowIfLocked();
    }

    func setSizeMultiplier(sizeMultiplier: Float32): T {
        setSizeMultiplier(sizeMultiplier, (this as T).getOrThrow())
    }

    func setSizeMultiplier(sizeMultiplier: Float32, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.setSizeMultiplier(sizeMultiplier, t2);
        }

        if (sizeMultiplier < 0.0 || sizeMultiplier > 1.0) {
            throw IllegalArgumentException("sizeMultiplier must be between 0 and 1");
        }
        t.sizeMultiplier = sizeMultiplier
        t.fields |= SIZE_MULTIPLIER

        return selfOrThrowIfLocked();
    }

    public func dontTransform(): T {
        dontTransform((this as T).getOrThrow())
    }

    func dontTransform(t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.dontTransform(t2);
        }
        transformations.clear()
        fields &= !TRANSFORMATION
        isTransformationAllowed = false
        fields &= !TRANSFORMATION_REQUIRED
        isTransformationAllowed = false
        fields &= !TRANSFORMATION_ALLOWED
        isScaleOnlyOrNoTransform = true
        return selfOrThrowIfLocked()
    }

    public func getTransformationAllowed(): Bool {
        return isTransformationAllowed
    }

    public override func getSizeMultiplier(): Float32 {
        return sizeMultiplier;
    }

    public func getErrorPlaceholderDrawable(): Option<CJResourceDrawable> {
        return errorPlaceholder;
    }

    public func getPlaceholderDrawable(): Option<CJResourceDrawable> {
        return placeholderDrawable;
    }

    public func isDiskCacheStrategySet(): Bool {
        return isSet(DISK_CACHE_STRATEGY);
    }

    public func isPrioritySet(): Bool {
        return isSet(PRIORITY);
    }

    public func isValidOverride(): Bool {
        return Utils.isValidDimensions(overrideWidth, overrideHeight);
    }

    public open func equals(o: Any): Bool {
        if (o is AnyRequestOptions) {
            var other: AnyRequestOptions = (o as AnyRequestOptions).getOrThrow();

            return other.getSizeMultiplier() == sizeMultiplier
                && isCacheable == other.getCacheable()
                && overrideHeight == other.getOverrideHeight()
                && overrideWidth == other.getOverrideWidth()
                && isTransformationRequired == other.getTransformationRequired()
                && isTransformationAllowed == other.getTransformationAllowed()
                // TODO useUnlimitedSourceGeneratorsPool
                && onlyRetrieveFromCache == other.getOnlyRetrieveFromCache()
                && diskCacheStrategy.equals(other.getDiskCacheStrategy())
                && priority == other.getPriority()
                && options == other.getOptions()
                && transformations == other.getTransformations()
                && resourceTypeClass == other.getResourceTypeClass()
                && signature == other.getSignature()
        }
        return false;
    }

    protected func selfOrThrowIfLocked(): T {
        if (isLocked) {
            throw IllegalStateException("You cannot modify locked T, consider clone()");
        }
        return self();
    }

    func self(): T {
        return (this as T).getOrThrow()
    }

    private func isSet(flag: Int64): Bool {
        return isSetStatic(this.fields, flag);
    }

    private static func isSetStatic(fields: Int64, flag: Int64): Bool {
        return (fields & flag) != 0;
    }

    protected func getIsAutoCloneEnabled(): Bool {
        return isAutoCloneEnabled;
    }

    // 仓颉没有克隆方法 需要传入一个空对象来赋值
    func clone(t: T): T {

        // TODO 克隆对象
        t.fields = this.fields
        t.sizeMultiplier = this.sizeMultiplier
        t.diskCacheStrategy = this.diskCacheStrategy
        t.priority = this.priority
        t.isCacheable = this.isCacheable
        t.signature = this.signature
        t.isTransformationRequired = this.isTransformationRequired
        t.isTransformationAllowed = this.isTransformationAllowed
        t.isScaleOnlyOrNoTransform = this.isScaleOnlyOrNoTransform

        let tempOptions = this.options
        t.options = DropletOptions()
        t.options.putAll(tempOptions);
        let tempTrans = this.transformations
        t.transformations = CachedHashCodeArrayMap<TransformationKey, AnyKey>()
        t.transformations.putAll(tempTrans);
        t.isLocked = false
        t.isAutoCloneEnabled = false

        return t
    }

    func autoClone(): T {
        if (isLocked && !isAutoCloneEnabled) {
            throw IllegalStateException("You cannot auto lock an already locked options object" + ", try clone() first");
        }
        isAutoCloneEnabled = true
        return lock();
    }

    func lock(): T {
        isLocked = true
        // This is the only place we should not check locked.
        return self();
    }

    func apply(v: AnyRequestOptions, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.apply(v, t2)
        }
        let other: AnyRequestOptions = v;

        // TODO
        if (isSetStatic(other.getFields(), SIZE_MULTIPLIER)) {
            t.sizeMultiplier = other.getSizeMultiplier()
        }
        if (isSetStatic(other.getFields(), DISK_CACHE_STRATEGY)) {
            t.diskCacheStrategy = other.getDiskCacheStrategy()
        }
        if (isSetStatic(other.getFields(), PRIORITY)) {
            t.priority = other.getPriority()
        }
        if (isSetStatic(other.getFields(), ERROR_PLACEHOLDER)) {
            t.errorPlaceholder = other.getErrorPlaceholderDrawable()
        }
        if (isSetStatic(other.getFields(), PLACEHOLDER)) {
            t.placeholderDrawable = other.getPlaceholderDrawable()
        }

        if (isSetStatic(other.getFields(), IS_CACHEABLE)) {
            t.isCacheable = other.getCacheable()
        }
        if (isSetStatic(other.getFields(), OVERRIDE)) {
            t.overrideWidth = other.getOverrideWidth()
            t.overrideHeight = other.getOverrideHeight()
        }
        if (isSetStatic(other.getFields(), SIGNATURE)) {
            t.signature = other.getSignature()
        }
        if (isSetStatic(other.getFields(), RESOURCE_CLASS)) {
            t.resourceTypeClass = other.getResourceTypeClass()
        }
        if (isSetStatic(other.getFields(), TRANSFORMATION_ALLOWED)) {
            t.isTransformationAllowed = other.getTransformationAllowed()
        }
        if (isSetStatic(other.getFields(), TRANSFORMATION_REQUIRED)) {
            t.isTransformationRequired = other.getTransformationRequired()
        }
        if (isSetStatic(other.getFields(), TRANSFORMATION)) {
            t.transformations.putAll(other.getTransformations());
            t.isScaleOnlyOrNoTransform = other.getScaleOnlyOrNoTransform()
        }
        if (isSetStatic(other.getFields(), ONLY_RETRIEVE_FROM_CACHE)) {
            t.onlyRetrieveFromCache = other.getOnlyRetrieveFromCache()
        }

        // // Applying options with dontTransform() is expected to clear our transformations.
        if (!t.isTransformationAllowed) {
            t.transformations.clear();
            t.fields &= !TRANSFORMATION
            t.isTransformationRequired = false
            t.fields &= !TRANSFORMATION_REQUIRED
            t.isScaleOnlyOrNoTransform = true
        }

        t.fields |= other.getFields()

        t.options.putAll(other.getOptions());
        return t.selfOrThrowIfLocked();
    }

    // TODO skipMemoryCache改成disableMemoryCache

    public func skipMemoryCache(skip: Bool): T {
        skipMemoryCache(skip, (this as T).getOrThrow())
    }

    func skipMemoryCache(skip: Bool, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.skipMemoryCache<T>(true, t2);
        }

        t.isCacheable = !skip
        t.fields |= IS_CACHEABLE

        return t.selfOrThrowIfLocked();
    }

    func setPlaceholderFunc(f:(PixelMap)->Unit){
        this.placeholderFunc = f
    }

    public func onlyRetrieveFromCachecj(flag: Bool): T {
        return onlyRetrieveFromCachecj(flag, (this as T).getOrThrow())
    }

    func onlyRetrieveFromCachecj(flag: Bool, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.onlyRetrieveFromCachecj<T>(true, t2);
        }
        t.onlyRetrieveFromCache = flag
        t.fields |= ONLY_RETRIEVE_FROM_CACHE

        return t.selfOrThrowIfLocked();
    }


    public func setDiskCacheStrategy(strategy: DiskCacheStrategy): T {
        return setDiskCacheStrategy(strategy, (this as T).getOrThrow())
    }

    func setDiskCacheStrategy(strategy: DiskCacheStrategy, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.setDiskCacheStrategy(strategy, t2);
        }

        t.diskCacheStrategy = strategy
        t.fields |= DISK_CACHE_STRATEGY

        return t.selfOrThrowIfLocked();
    }

    public func setOverride(width: Int64, height: Int64): T {
        return setOverride(width, height, (this as T).getOrThrow())
    }

    func setOverride(width: Int64, height: Int64, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.setOverride(width, height, t2);
        }

        t.overrideWidth = width
        t.overrideHeight = height
        fields |= OVERRIDE

        return t.selfOrThrowIfLocked();
    }

    func setSignature(signature: AnyKey, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.setSignature(signature, t2);
        }
        t.signature = signature
        fields |= SIGNATURE
        return t.selfOrThrowIfLocked();
    }

    public func setSignature(signature: AnyKey): T {
        return setSignature(signature, (this as T).getOrThrow())
    }

    func optionalCenterInside(): T {
        return optionalCenterInside((this as T).getOrThrow())
    }

    /**
     * 转换失败时直接返回原图
     */
    func optionalCenterInside(t: T): T {
        return optionalScaleOnlyTransform(DownsampleStrategy.CENTER_INSIDE, CenterInside(), t);
    }

    func centerInside(): T {
        return centerInside((this as T).getOrThrow())
    }

    /**
     * 转换失败时报错
     */
    func centerInside(t: T): T {
        return scaleOnlyTransform(DownsampleStrategy.CENTER_INSIDE, CenterInside(), t);
    }

    func optionalCircleCrop(t: T): T {
        return optionalTransform(DownsampleStrategy.CENTER_OUTSIDE, CircleCrop(), t);
    }

    func circleCrop(): T {
        return circleCrop((this as T).getOrThrow())
    }

    func circleCrop(t: T): T {
        return transform(DownsampleStrategy.CENTER_INSIDE, CircleCrop(), t);
    }

    func fitCenter(): T {
        return fitCenter((this as T).getOrThrow())
    }

    func fitCenter(t: T): T {
        return scaleOnlyTransform(DownsampleStrategy.FIT_CENTER, FitCenter(), t);
    }

    func optionalFitCenter(): T {
        return optionalFitCenter((this as T).getOrThrow())
    }

    func optionalFitCenter(t: T): T {
        return optionalScaleOnlyTransform(DownsampleStrategy.FIT_CENTER, FitCenter(), t);
    }

    private func optionalScaleOnlyTransform(strategy: DownsampleStrategy, transformation: Transformation<PixelMap>, t: T): T {
        return scaleOnlyTransform(strategy, transformation, false /*isTransformationRequired*/ , t);
    }

    private func scaleOnlyTransform(strategy: DownsampleStrategy, transformation: Transformation<PixelMap>, t: T): T {
        return scaleOnlyTransform(strategy, transformation, true, t);
    }

    private func scaleOnlyTransform(strategy: DownsampleStrategy, transformation: Transformation<PixelMap>,
        isTransformationRequired: Bool, t: T): T {
        var result: BaseRequestOptions<T>
        if (isTransformationRequired) {
            result = transform(strategy, transformation, t)
        } else {
            result = optionalTransform(strategy, transformation, t)
        }
        result.isScaleOnlyOrNoTransform = true
        return (result as T).getOrThrow();
    }

    func optionalTransform(downsampleStrategy: DownsampleStrategy, transformation: Transformation<PixelMap>, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.optionalTransform(downsampleStrategy, transformation, t2);
        }

        t.downsample(downsampleStrategy);
        return t.transform(transformation, /*isRequired=*/ false, t);
    }

    // TODO 支持其他类型
    func optionalTransform(resourceClass: TransformationKey, transformation: Transformation<PixelMap>, t: T): T {
        return transform(resourceClass, transformation, /*isRequired=*/ false, t);
    }

    // TODO 支持其他类型
    func transform(downsampleStrategy: DownsampleStrategy, transformation: Transformation<PixelMap>, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.transform(downsampleStrategy, transformation, t2);
        }

        t.downsample(downsampleStrategy);
        return t.transform(transformation, t);
    }

    func downsample(strategy: DownsampleStrategy): T {
        var s2 = (this as T).getOrThrow()

        return set<DownsampleStrategy>(DownsampleStrategy.OPTION, strategy, s2);
    }

    public func transforms(transformations: ArrayList<PixelMapTransformation>): T {
        return transform(MultiTransformation(transformations))
    }

    public func transform(transformation: Transformation<PixelMap>): T {
        return transform(transformation, true, (this as T).getOrThrow());
    }

    func transform(transformation: Transformation<PixelMap>, t: T): T {
        return transform(transformation, true, t);
    }

    func transform(transformation: Transformation<PixelMap>, isRequired: Bool, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2 = clone(t)
            return t2.transform(transformation, isRequired, t2);
        }

        t.transform<PixelMap>(TransformationKey(TransformationKey.TRANSFORMATION_PIXELMAP), transformation, isRequired,
            t);
        let drawableTransformation: DrawableTransformation = DrawableTransformation(transformation, isRequired);
        t.transform<PixelMapDrawable>(TransformationKey(TransformationKey.TRANSFORMATION_DRAWABLE),
            drawableTransformation, isRequired, t);

        // TODO: remove BitmapDrawable decoder and this transformation.
        // Registering as BitmapDrawable is simply an optimization to avoid some iteration and
        // isAssignableFrom checks when obtaining the transformation later on. It can be removed without
        // affecting the functionality.
        return selfOrThrowIfLocked();
    }

    func transform<Y>(resourceClass: TransformationKey, transformation: Transformation<Y>, isRequired: Bool, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2: T = clone(t)
            return t2.transform(resourceClass, transformation, isRequired, t2);
        }

        t.transformations.put(resourceClass, transformation);
        t.fields |= TRANSFORMATION
        t.isTransformationAllowed = true
        t.fields |= TRANSFORMATION_ALLOWED
        // Always set to false here. Known scale only transformations will call this method and then
        // set isScaleOnlyOrNoTransform to true immediately after.
        t.isScaleOnlyOrNoTransform = false
        if (isRequired) {
            t.fields |= TRANSFORMATION_REQUIRED
            t.isTransformationRequired = true
        }
        return t.selfOrThrowIfLocked();
    }

    public func getPriority(): Priority {
        return priority;
    }

    func decode(resourceTypeClass: ResourceTypeClass, t: T): T {
        if (getIsAutoCloneEnabled()) {
            var t2: T = clone(t)
            return t2.decode(resourceTypeClass, t2);
        }

        t.resourceTypeClass = resourceTypeClass
        t.fields |= RESOURCE_CLASS
        return t.selfOrThrowIfLocked();
    }

    func placeholder(res: AppResource): T {
        this.placeholderDrawable = CJResourceDrawable(res)
        fields |= PLACEHOLDER
        return self();
    }

    func error(res: AppResource): T {
        this.errorPlaceholder = CJResourceDrawable(res)
        fields |= ERROR_PLACEHOLDER
        return self();
    }
}
