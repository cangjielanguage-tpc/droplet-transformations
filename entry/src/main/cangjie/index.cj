package ohos_app_cangjie_entry

internal import ohos.base.*
internal import ohos.component.*
internal import ohos.state_manage.*
import ohos.state_macro_manage.*

@Entry
@Component
class EntryView {
    @State
    var message: String = "Hello World"

    let scroller = Scroller()

    func build() {
            Row {
            Scroll(this.scroller){
                Column {
                    Button("Index_LLT").onClick {Router.push(url: "Index_LLT")}
                    Divider().color(0x000000).strokeWidth(1).margin(top: 10, bottom: 10)

                }.width(100.percent)
            }
        }.height(100.percent)
    }
}
