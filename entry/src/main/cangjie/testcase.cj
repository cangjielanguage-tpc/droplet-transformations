/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */

package ohos_app_cangjie_entry

import ohos.window.*
import ohos.base.*
import ohos.ability.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import droplet.*
import transform.*
import ohos.resource_manager.__GenerateResource__

@Entry
@Component
class TestCase {
    let scroller = Scroller()

    @State
    var flag: Bool = false

    var option: DropletRequestOption = DropletRequestOption(
        loadSrcRes: @r(app.media.cat),
        //loadSrc: "https://.........jpg",
        strategy: DiskCacheStrategyDATA(),
        transformCate: BrightnessFilterTransformation(0.6)
    )

    protected open func aboutToAppear() {
        Droplet.get(getStageContext(globalAbilityContext.getOrThrow())).onAppear("TestCase") //onAppear和onDisAppear一起使用或一起不使用,参数和组件的label保持一致,
        //组件没设置label,就调用空参的onAppear
    }

    protected open func aboutToDisappear() {
        Droplet.get(getStageContext(globalAbilityContext.getOrThrow())).onDisAppear("TestCase") //onAppear和onDisAppear一起使用或一起不使用,参数和组件的label保持一致
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
                            globalContext: getStageContext(globalAbilityContext.getOrThrow()),
                            dropletOption: option,
                        )
                    }
                }.width(100.percent)
            }
        }
    }
}

