/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package droplet

public enum TransitionType {
    Opacity | Scale | Rotate | Translate
}

public class TransitionOption {
    private var transType: TransitionType //过渡动画类型
    private var begin: Float64 //过渡动画开始值
    private var end: Float64 //过渡动画结束值
    private var duration: Int32 //过渡动画时长

    /**
     * 构造函数
     * @参数 transType - TransitionType 过渡动画类型，有四种，透明度，旋转，缩放,平移
     * @参数 begin - Float64 对应动画的起始参数
     * @参数 end: - Float64 对应动画的结束参数
     * @参数 duration - Int32 动画执行时长
     */
    public init(transType: TransitionType, begin: Float64, end: Float64, duration: Int32) {
        this.transType = transType
        this.begin = begin
        this.end = end
        this.duration = duration
    }

    /**
     * 获取动画类型
     *
     * @返回值 TransitionType 过渡动画的类型
     */
    public func getTransType(): TransitionType {
        return transType
    }

    /**
     * 获取开始点参数
     *
     * @返回值 Float64 开始点的参数
     */
    public func getBegin(): Float64 {
        return begin
    }

    /**
     * 获取结束点参数
     *
     * @返回值 Float64 结束点的参数
     */
    public func getEnd(): Float64 {
        return end
    }

    /**
     * 获取过渡动画时长
     *
     * @返回值 Int32 过渡动画时长
     */
    public func getDuration(): Int32 {
        return duration
    }

    /**
     * 设置动画类型
     *
     * @参数 transType - TransitionType 过渡动画的类型
     */
    public func setTransType(transType: TransitionType): Unit {
        this.transType = transType
    }

    /**
     * 设置开始点值
     *
     * @参数 begin - Float64 动画开始点的参数值
     */
    public func setBegin(begin: Float64): Unit {
        this.begin = begin
    }

    /**
     * 设置结束点
     *
     * @参数 end - Float64 动画结束点的参数值
     */
    public func setEnd(end: Float64): Unit {
        this.end = end
    }

    /**
     * 设置时长
     *
     * @参数 duration - Int32 动画的时长
     */
    public func setDuration(duration: Int32): Unit {
        this.duration = duration
    }
}
