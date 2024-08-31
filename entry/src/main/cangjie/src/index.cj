/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */

package ohos_app_cangjie_entry


import ohos.state_macro_manage.*

@Entry
@Component
class MyView {
    @State
    var message: String = "Hello Cangjie"
    func build() {
        Row {
            Column {
               Button("TestCase").onClick {Router.push(url:  "TestCase")}
            }.width(100.percent)
        }.height(100.percent)
    }
}
