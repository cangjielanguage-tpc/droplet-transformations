package ohos_app_cangjie_entry

internal import ohos.base.AppLog
internal import ohos.ability.Want
internal import ohos.ability.UIAbility
internal import ohos.ability.LaunchParam
internal import ohos.ability.LaunchReason
internal import ohos.window.WindowStage

var globalAbilityContext: Option<AbilityContext> = Option<AbilityContext>.None


class MainAbility <: UIAbility {
    public init() {
        super()
        registerSelf()
    }

    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        AppLog.info("MainAbility OnCreated.${want.abilityName}")
        globalAbilityContext = Option<AbilityContext>.Some(this.context)
        match (launchParam.launchReason) {
            case LaunchReason.START_ABILITY => AppLog.info("START_ABILITY")
            case _ => ()
        }
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        AppLog.info("MainAbility onWindowStageCreate.")
        windowStage.loadContent("EntryView")
    }
}
