<div align="center">
<h1>droplet-transformations</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.0-brightgreen" style="display: inline-block;" />
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
├── entry                                     #示例目录
└── hvigor                                    #构建工具目录
```

### 接口说明

主要类和函数接口说明详见 [API](./doc/feature_api.md)


## 使用说明

### 编译构建

描述具体的编译过程：

```shell

1.下载测试工程与git子模块

git clone -b 分支名 --single-branch --recursive https://gitcode.com/Cangjie-TPC/droplet-transformations.git

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
    let scroller = Scroller()

    @State
    var flag: Bool = false

    var option: DropletRequestOption = DropletRequestOption(
        loadSrc: "http://xxxxxxx.jpg",
        strategy: DiskCacheStrategyDATA(),
        transformCate: BrightnessFilterTransformation(0.6)
    )

    protected open func aboutToAppear() {
        Droplet.get(globalAbilityContext.getOrThrow()).onAppear("TestCase") //onAppear和onDisAppear一起使用或一起不使用,参数和组件的label保持一致,
        //组件没设置label,就调用空参的onAppear
    }

    protected open func aboutToDisappear() {
        Droplet.get(globalAbilityContext.getOrThrow()).onDisAppear("TestCase") //onAppear和onDisAppear一起使用或一起不使用,参数和组件的label保持一致
        //组件没设置label,就调用空参的onDisAppear
    }

    func build() {
        Column(30) {
            Scroll(this.scroller) {
                Column() {
                    Button("加载").onClick {
                        flag = true
                    }

                    if (flag) {
                        DropletImageComponent(
                            globalContext: globalAbilityContext.getOrThrow(),
                            dropletOption: option,
                        )
                    }
                }.width(100.percent)
            }
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

DevEco Studio (5.1.0) Release
Cangjie Support Plugin 5.1.0.828
Cangjie Compiler: 1.0.0


## 开源协议

本项目基于 [Apache License](./LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。