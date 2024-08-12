<div align="center">
<h1>droplet-transformations</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.53.4-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## 介绍

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


### 特性

- 🚀 支持高亮,滤镜,灰度,虚幻,马赛克,漫画,像素,素描,漩涡,油画,暗边,模糊的图像变换效果。


### 源码目录

```shell
├── README.md                                 #整体介绍
├── doc                                       #文档目录
│   └── feature_api.md                        #API接口文档
├── transform                                 #源码目录 
└── entry                                     #示例目录
```

### 接口说明

主要类和函数接口说明详见 [API](./doc/feature_api.md)


## 使用说明

### 编译构建

描述具体的编译过程：

```shell

1.下载测试工程与git子模块

git clone --single-branch --recursive https://gitcode.com/Cangjie-TPC/droplet-transformations.git

2. 如需切换droplet分支, 进入transform/third_party/droplet目录自行操作

3. 将transform/third_party/droplet在deveco上编译成功

4. 运行当前项目

```

### 功能示例

#### 图片加载 功能示例
功能示例描述: 对一张图片加上高亮特效

示例代码如下：

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

    public func onAppear(): Unit {
    }

    public func onDisappear(): Unit {
    }

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
图片在手机上成功展示。

```shell
load成功
```


## 约束与限制

当前基于 OpenHarmony Cangjie Mobile B100 版本实现的

## 开源协议

本项目基于 [Google License](./LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。