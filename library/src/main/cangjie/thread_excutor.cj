/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet

foreign func getThreadId(): UInt64
foreign func startThread(): UInt64
foreign func stopThread(): Unit
foreign func setTask(param: UInt32): UInt32

public class OpenGLThreadExcutor {

     func openGLGetThreadId(): UInt64 {
        return unsafe{getThreadId()}
    }

     func openGLStartThread(): UInt64 {
        return unsafe{startThread()}
    }

     func openGLStopThread(): Unit {
        return unsafe{stopThread()}
    }

     func openGLSetTask(param: UInt32): UInt32 {
        return unsafe{setTask(param)}
    }

}
