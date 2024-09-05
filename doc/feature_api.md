
## droplet-transformations

### 介绍
droplet-transformations是一个依赖于droplet的图像转换库(必须搭配droplet使用),提供了
高亮(BrightnessFilter),
滤镜(ContrastFilter),
灰度(Grayscale),
虚幻(InvertFilter),
马赛克(KuwaharaFilter),
漫画(SepiaFilter),
像素(PixelationFilter),
素描(SketchFilter),
漩涡(SwirlFilter),
油画(ToonFilter),
暗边(VignetteFilter),
模糊(FastBlur)
这些特效



### 1 图片变换接口


#### 1.1 BrightnessFilterTransformation

```cangjie
public class BrightnessFilterTransformation <: PixelMapTransformation {
    /**
     * 增亮变换：图片增亮滤镜，增加亮度值默认为0。
     */
    public init()

    /**
     * 增亮变换：图片增亮滤镜。
     *
     * @参数 brightness - 增加亮度值。
     */
    public init(brightness: Float32)
}
```


#### 1.2 ContrastFilterTransformation

```cangjie
public class ContrastFilterTransformation <: PixelMapTransformation {
    /**
     * 对比度变换：调节图片对比度，对比度值默认为1.0。
     */
    public init()

    /**
     * 对比度变换：调节图片对比度。
     * 
     * @参数 contrast - 对比度值。
     */
    public init(contrast: Float32)
}
```


#### 1.3 GrayscaleTransformation

```cangjie
public class GrayscaleTransformation <: PixelMapTransformation {
    /**
     * 灰度变换：为图片添加灰度滤镜。
     */
    public init()
}
```


#### 1.4 InvertFilterTransformation

```cangjie
public class InvertFilterTransformation <: PixelMapTransformation {
    /**
     * 反色变换：为图片添加反色滤镜。
     */
    public init()
}
```


#### 1.5 KuwaharaFilterTransformation

```cangjie
public class KuwaharaFilterTransformation <: PixelMapTransformation {

    /**
     * 油画效果变换：为图片添加油画效果滤镜，效果半径默认为25。
     */
    public init()

    /**
     * 油画效果变换：为图片添加油画效果滤镜。
     * 
     * @参数 radius - 效果半径。
     */
    public init(radius: Int32)
}
```


#### 1.6 SepiaFilterTransformation

```cangjie
public class SepiaFilterTransformation <: PixelMapTransformation {

    /**
     * 棕褐色变换：为图片添加棕褐色滤镜，效果强度默认为10.0。
     */
    public init()

    /**
     * 棕褐色变换：为图片添加棕褐色滤镜。
     * 
     * @参数 intensity - 效果强度。
     */
    public init(intensity: Float32)
}
```


#### 1.7 PixelationFilterTransformation

```cangjie
public class PixelationFilterTransformation <: PixelMapTransformation {
    /**
     * 像素化变换：为图片添加像素化滤镜。
     */
    public init()
}
```


#### 1.8 SketchFilterTransformation

```cangjie
public class SketchFilterTransformation <: PixelMapTransformation {
    /**
     * 素描变换：为图片添加素描滤镜。
     */
    public init()
}
```


#### 1.9 SwirlFilterTransformation

```cangjie
public class SwirlFilterTransformation <: PixelMapTransformation {

    /**
     * 扭曲效果变换：为图片添加扭曲效果滤镜，扭曲半径默认为0.5，扭曲角度默认为1.0，扭曲中心点x坐标默认为0.5，扭曲中心点y坐标默认为0.5。
     */
    public init()

    /**
     * 扭曲效果变换：为图片添加扭曲效果滤镜。
     * 
     * @参数 radius - 扭曲半径。
     * @参数 angle - 扭曲角度。
     * @参数 x - 扭曲中心点x坐标。
     * @参数 y - 扭曲中心点y坐标。
     */
    public init(radius: Float32, angle: Float32, x: Float32, y: Float32)
}
```


#### 1.10 ToonFilterTransformation

```cangjie
public class ToonFilterTransformation <: PixelMapTransformation {

    /**
     * 卡通效果变换：为图片添加卡通效果滤镜，量化阈值默认为0.2，量化级别默认值为10.0。
     */
    public init()

    /**
     * 卡通效果变换：为图片添加卡通效果滤镜。
     * 
     * @参数 threshold - 量化阈值。
     * @参数 quantizationLevels - 量化级别。
     */
    public init(threshold: Float32, quantizationLevels: Float32)
}
```


#### 1.11 VignetteFilterTransformation

```cangjie
public class VignetteFilterTransformation <: PixelMapTransformation {

    /**
     * 装饰图变换：为图片添加装饰图滤镜，装饰图中心点默认为0.5，0.5。装饰图颜色默认为0，0，0。装饰图颜色透明度起始半径默认为0，装饰图颜色透明度结束半径默认为0.75。
     */
    public init()

    /**
     * 装饰图变换：为图片添加装饰图滤镜。
     * 
     * @参数 x - 装饰图中心点x坐标。
     * @参数 y - 装饰图中心点y坐标。
     * @参数 r - 装饰图颜色r通道。
     * @参数 g - 装饰图颜色g通道。
     * @参数 b - 装饰图颜色b通道。
     * @参数 start - 装饰图颜色透明度起始半径。
     * @参数 end - 装饰图颜色透明度结束半径。
     */
    public init(x: Float32, y: Float32, r: Float32, g: Float32, b: Float32, start: Float32, end: Float32)
}
```


#### 1.12 FastBlur

```cangjie
public class FastBlur <: PixelMapTransformation {

    /**
     * 快速模糊变换：为图片添加快速模糊滤镜。
     * 
     * @参数 radius - 模糊半径。
     */
    public init(radius: Int32)
}
```


### 2 示例

```cangjie

package ohos_app_cangjie_entry

import ohos.window.*
import ohos.base.*
import ohos.ability.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import cj_res_entry.app
import droplet.droplet.*
import transform.*

@Entry
@Component
class TestCase {

    @State
    var text: String = ""

    @State
    var textTmp: String = ""

    @State
    var option: DropletRequestOption = DropletRequestOption(
        loadSrc: "https://xxxxxxx.jpg", //这里填写一张网络图片地址
        transformCate: Option<PixelMapTransformation>.Some(BrightnessFilterTransformation(0.6)),
        strategy: Option<DiskCacheStrategy>.Some(DiskCacheStrategyDATA()),
    )
    

    let scroller = Scroller()

    func build() {
        Column(30) {
            Scroll(this.scroller) {
                Column() {
                        DropletImageComponent(
                            globalContext: globalAbilityContext,    //注意这个globalAbilityContext是在main_ability中获取到的context
                            option: option,
                            beginFn: {=>
                                text = "begin"
                                AppLog.error("droplet hhs begin")},
                            endFn: {=>
                                textTmp = "end"
                                AppLog.error("droplet hhs end")}
                        )
                    }
             }.width(100.percent)
        }
    }
}


```

执行结果如下：
图片在手机正常显示

```shell
load成功
```
