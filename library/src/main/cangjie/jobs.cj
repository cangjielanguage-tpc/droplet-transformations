/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet


public class Jobs {
  private let jobs: HashMap<AnyKey, EngineJob> = HashMap<AnyKey, EngineJob>();
  private let onlyCacheJobs: HashMap<AnyKey, EngineJob> = HashMap<AnyKey, EngineJob>();

   func getAll(): HashMap<AnyKey, EngineJob> {
    return jobs;
  }

   func get(key: AnyKey, onlyRetrieveFromCache: Bool): Option<EngineJob> {
    let oo: HashMap<AnyKey, EngineJob> = getJobMap(onlyRetrieveFromCache)
    let o: Option<EngineJob> = oo.get(key)
    return o
  }

   func put(key: AnyKey, job: EngineJob): Unit {
    getJobMap(job.onlyRetrieveFromCache).add(key, job);
  }

   func removeIfCurrent(key: AnyKey, expected: EngineJob): Unit {
    var jobMap: HashMap<AnyKey, EngineJob> = getJobMap(expected.onlyRetrieveFromCache);
    if (Some(expected) == jobMap.get(key)) {
      jobMap.remove(key);
    }
  }

  private func getJobMap(onlyRetrieveFromCache: Bool): HashMap<AnyKey, EngineJob> {
    return if(onlyRetrieveFromCache) {
        onlyCacheJobs 
    } else {
        jobs
    }
  }
}
