/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package droplet

public abstract class CustomTarget<R> <: BaseTarget<R> {
    protected let width: Int64
    protected let height: Int64

    public init() {
        this(Downsampler.SIZE_ORIGINAL, Downsampler.SIZE_ORIGINAL)
    }

    public init(width: Int64, height: Int64) {
        if (!Utils.isValidDimensions(width, height)) {
            throw IllegalArgumentException(
                "Width and height must both be > 0 or Target#SIZE_ORIGINAL, but given width: ${width} and height: ${height}"
            )
        }
        this.width = width
        this.height = height
    }

    public override func onStart(): Unit {
    }

    public override func onStop(): Unit {
    }

    public override func onDestroy(): Unit {
    }

    public override func onLoadStarted(placeholder: Option<CJResourceDrawable>): Unit {
    }

    public override func onLoadFailed(placeholder: Option<CJResourceDrawable>): Unit {
    }

    public override func getSize(cb: SizeReadyCallback): Unit {
        cb.onSizeReady(width, height)
    }

    public override func removeCallback(): Unit {
    }
}
