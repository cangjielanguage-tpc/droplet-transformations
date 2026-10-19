/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet


public class DropletExecutor<T> {
     func execute(gt: DropletThread<T>): Future<T> {
        return gt.run()
    }
}

public abstract class DropletThread<T> {
    public let name: String

    public init(name: String) {
        this.name = name
    }

    public func runWrap(): T

    public func run(): Future<T> {
        return spawn{runWrap()}
    }
}

