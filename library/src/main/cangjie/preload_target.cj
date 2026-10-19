/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package droplet

public class PreloadTarget<R> <: CustomTarget<R> {
    private static let MESSAGE_CLEAR: Int64 = 1
    private var requestManager: ?RequestManager = None

    public static func obtain(requestManager: RequestManager, width: Int64, height: Int64): PreloadTarget<R> {
        return PreloadTarget<R>(requestManager, width, height);
    }

    private init(requestManager: RequestManager, width: Int64, height: Int64) {
        super(width, height);
        this.requestManager = requestManager
    }

    public func onResourceReady(resource: R, transition: Option<DrawableTransition>): Unit {
        // If a thumbnail request is set and the thumbnail completes, we don't want to cancel the
        // primary load. Instead we wait until the primary request (the one set on the target) says
        // that it is complete.
        // Note - Any thumbnail request that does not complete before the primary request will be
        // cancelled and may not be preloaded successfully. Cancellation of outstanding thumbnails after
        // the primary request succeeds is a common behavior of all Glide requests and we're not trying
        // to override it here.
        var request: Option<LoadRequest> = getRequest()
        if (!request.isNone() && request.getOrThrow().isComplete()) {
            clear()
        }
    }

    public override func onLoadCleared(placeholder: Option<CJResourceDrawable>): Unit {
        // Do nothing, we don't retain a reference to our resource.
    }

    func clear(): Unit {
        requestManager.getOrThrow().clear(this)
    }

    public override func hashCode(): Int64 {
        Utils.hashCodeWrite(width.hashCode(), reset: true)
        Utils.hashCodeWrite(height.hashCode())
        if(let Some(i) <- request){
            Utils.hashCodeWrite(i.hashCode())
        }
        return Utils.hashCodeFinish()
    }

    public operator func ==(that: LifecycleListener): Bool {
        if (that is PreloadTarget<R>) {
            return this.request == (that as PreloadTarget<R>).getOrThrow().request
        }
        return false
    }

    public operator func !=(that: LifecycleListener): Bool {
        if (that is PreloadTarget<R>) {
            return this.request != (that as PreloadTarget<R>).getOrThrow().request
        }
        return true
    }

    public operator func ==(that: AnyTarget): Bool {
        if (that is PreloadTarget<R>) {
            return this.request == (that as PreloadTarget<R>).getOrThrow().request
        }
        return false
    }

    public operator func !=(that: AnyTarget): Bool {
        if (that is PreloadTarget<R>) {
            return this.request != (that as PreloadTarget<R>).getOrThrow().request
        }
        return true
    }
}
