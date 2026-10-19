/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package droplet


extend File {
     func write(s: UInt8): Unit {
        this.write(Array<UInt8>(1, repeat: s))
    }
}

     func unsignedShiftRight64(c: Int64, num: Int64) {
        let t: Int64 = 0x7fffffffffffffff<<1 | 0x01;
        Int64(UInt64(t & c) >> num)
    }

     func highestOneBit(i: Int64): Int64 {
        var i2 = i
        i2 |= (i2 >>  1);
        i2 |= i2 | (i2 >>  2);
        i2 |= (i2 >>  4);
        i2 |= (i2 >>  8);
        i2 |= (i2 >> 16);
        return i2 - unsignedShiftRight64(i2, 1);  
    }