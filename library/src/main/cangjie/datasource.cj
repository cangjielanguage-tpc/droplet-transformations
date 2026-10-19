/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet

/** Indicates the origin of some retrieved data. */
public enum DataSource <: ToString {
  /**
   * Indicates data was probably retrieved locally from the device, although it may have been
   * obtained through a content provider that may have obtained the data from a remote source.
   */
  LOCAL |
  /** Indicates data was retrieved from a remote source other than the device. */
  REMOTE |
  /** Indicates data was retrieved unmodified from the on device cache. */
  DATA_DISK_CACHE |
  /** Indicates data was retrieved from modified content in the on device cache. */
  RESOURCE_DISK_CACHE |
  /** Indicates data was retrieved from the in memory cache. */
  MEMORY_CACHE |
  NONE

  public func toString(): String {
    match(this) {
      case LOCAL => "DataSourceLOCAL"
      case REMOTE => "DataSourceREMOTE"
      case DATA_DISK_CACHE => "DataSourceDATA_DISK_CACHE"
      case RESOURCE_DISK_CACHE => "DataSourceRESOURCE_DISK_CACHE"
      case MEMORY_CACHE => "DataSourceMEMORY_CACHE"
      case NONE => "DataSourceNONE"
    }
  }


      operator func ==(that: DataSource): Bool {
        match ((this, that)) {
            case (LOCAL, LOCAL) => true
            case (REMOTE, REMOTE) => true
            case (DATA_DISK_CACHE, DATA_DISK_CACHE) => true
            case (RESOURCE_DISK_CACHE, RESOURCE_DISK_CACHE) => true
            case (MEMORY_CACHE, MEMORY_CACHE) => true
            case (NONE, NONE) => true
            case _ => false
        }
    }

    operator func !=(that: DataSource): Bool {
          !(this == that)
    }

}

public enum EncodeStrategy <: ToString {
  /**
   * Writes the original unmodified data for the resource to disk, not include downsampling or
   * transformations.
   */
  SOURCE |

  /** Writes the decoded, downsampled and transformed data for the resource to disk. */
  TRANSFORMED |

  /** Will write no data. */
  NONE

  public func toString(): String {
    match(this) {
      case SOURCE => "EncodeStrategySOURCE"
      case TRANSFORMED => "EncodeStrategyTRANSFORMED"
      case NONE => "EncodeStrategyNONE"
    }
  }


    operator func ==(that: EncodeStrategy): Bool {
        match ((this, that)) {
            case (SOURCE, SOURCE) => true
            case (TRANSFORMED, TRANSFORMED) => true
            case (NONE, NONE) => true
            case _ => false
        }
    }

    operator func !=(that: EncodeStrategy): Bool {
          !(this == that)
    }


}

