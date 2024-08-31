/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */

package ohos_app_cangjie_entry

import ohos.state_macro_manage.*

@Entry
@Component
class TestCase {

    @State
    var text: String = ""

    @State
    var textTmp: String = ""

    @State
    var option: DropletRequestOption = DropletRequestOption(
        loadSrc: "https://xxxxxx.jpg", //这里填写一张网络图片地址
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
                            globalContext: globalAbilityContext,
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
