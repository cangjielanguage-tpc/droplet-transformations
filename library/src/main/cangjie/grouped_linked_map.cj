/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
 
package droplet

public class LinkedEntry<K, V> <: Equatable<LinkedEntry<K, V>> where K <: Equatable<K> & Hashable & ToString {
    public var key: Option<K> = None;
    private var values: ArrayList<V> = ArrayList<V>();
    public var next: Option<LinkedEntry<K, V>> = None;
    public var prev: Option<LinkedEntry<K, V>> = None;

    // Used only for the first item in the list which we will treat specially and which will not
    // contain a value.
    public init() {
      this(Option<K>.None);
    }

    public init(key: Option<K>) {
        this.key = key;

        this.next = Some(this)
        this.prev = Some(this)
      
    }

     func removeLast(): Option<V> {
      let valueSize: Int64 = size();
      return if(valueSize > 0) {
        this.values.remove(at:valueSize - 1)
      } else {
        None
      };
    }

     func size(): Int64 {
      return this.values.size
    }

     func add(value: V): Unit {
      this.values.add(value);
    }

    public operator func ==(right: LinkedEntry<K, V>): Bool {
        return equals(right)
    }
    public operator func !=(right: LinkedEntry<K, V>): Bool {
      return !equals(right)
    } 

     func equals(right: LinkedEntry<K, V>): Bool {
        var thiskeySome = false
        var rightkeySome = false
        if(this.key.isSome()){
            thiskeySome = true
        }
        if(right.key.isSome()){
            rightkeySome = true
        }

        if(thiskeySome && rightkeySome){
            return this.key.getOrThrow() == right.key.getOrThrow()
        }else if(!thiskeySome && !rightkeySome){
            return true
        }else{
            return false
        }
    }

     func toString(): String {
        if(let Some(i) <- this.key){
            i.toString()
        }else{
            "None"
        }
    }
  }

public class GroupedLinkedMap<K, V> where K <: Poolable & Hashable & Equatable<K> & ToString {
  private let head: LinkedEntry<K, V> = LinkedEntry<K, V>()
  private let keyToEntry: HashMap<K, LinkedEntry<K, V>>  = HashMap<K, LinkedEntry<K, V>>()

   func put(key: K, value: V): Unit {
    var entry: Option<LinkedEntry<K, V>> = keyToEntry.get(key)
    if(entry.isSome()){
        key.offer()
    }else{
        entry = LinkedEntry<K, V>(key)
        makeTail(entry.getOrThrow())
        let b = keyToEntry.add(key, entry.getOrThrow())
    }
    entry.getOrThrow().add(value)
  }

   func get(key: K): Option<V> {
    var entry: Option<LinkedEntry<K, V>> = keyToEntry.get(key)

    if(entry.isSome()){
      key.offer()
    }else{
      entry = LinkedEntry<K, V>(key)
      let b = keyToEntry.add(key, entry.getOrThrow())
    }
    let en = entry.getOrThrow()
    makeHead(en)
    return en.removeLast()
  }

   func removeLast(): Option<V> {
    var last: LinkedEntry<K, V> = head.prev.getOrThrow()
    while (!last.equals(head)) {
      let removed: Option<V> = last.removeLast()
      if(removed.isSome()){
         return removed
      }else{
        // We will clean up empty lru entries since they are likely to have been one off or
        // unusual sizes and
        // are not likely to be requested again so the gc thrash should be minimal. Doing so will
        // speed up our
        // removeLast operation in the future and prevent our linked list from growing to
        // arbitrarily large
        // sizes.
        removeEntry(last)
        keyToEntry.remove(last.key.getOrThrow())
        last.key.getOrThrow().offer()
      }
      last = last.prev.getOrThrow()
    }
    return None
  }

   func toString(): String {
    var sb: StringBuilder = StringBuilder("GroupedLinkedMap( ");
    var current: LinkedEntry<K, V> = head.next.getOrThrow();
    var hadAtLeastOneItem: Bool  = false;
    while (!current.equals(head)) {
      hadAtLeastOneItem = true;
      sb.append('{')
      sb.append(current.key.getOrThrow())
      sb.append(':')
      sb.append(current.size())
      sb.append("}, ")
      current = current.next.getOrThrow();
    }
    if (hadAtLeastOneItem) {
        let r = Range<Int64>(sb.size - 2, sb.size, 1, true, false, true)
        var strTemp = sb.toString()
        let r2: Range<Int64> = 0 .. sb.size - 2
        var subStrTemp = strTemp[r2]
        sb = StringBuilder(subStrTemp)
    }
    return sb.append(" )").toString();
  }

  // Make the entry the most recently used item.
  private func makeHead(entry: LinkedEntry<K, V>): Unit {
    removeEntry<K, V>(entry);
    entry.prev = head;
    entry.next = head.next;
    updateEntry<K, V>(entry);
  }

  // Make the entry the least recently used item.
  private func makeTail(entry: LinkedEntry<K, V>): Unit {
    removeEntry<K, V>(entry);
    entry.prev = head.prev;
    entry.next = head;
    updateEntry<K, V>(entry);
  }

  private static func updateEntry<K, V>(entry: LinkedEntry<K, V>) where K <: Poolable & Hashable & Equatable<K> & ToString {
    entry.next.getOrThrow().prev = Some(entry);
    entry.prev.getOrThrow().next = Some(entry);
  }

  private static func removeEntry<K, V>(entry: LinkedEntry<K, V>) where K <: Poolable & Hashable & Equatable<K> & ToString  {
    entry.prev.getOrThrow().next = entry.next;
    entry.next.getOrThrow().prev = entry.prev;
  }
  
}
