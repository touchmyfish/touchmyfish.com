---
layout: post
title:  "常用内存缓存 cache模块"
author: Sky
categories: [ Python ]
tags: [ Python ]
image: assets/images/2019-07-18-Meomery-Cache/123.jpg
description: "常用内存缓存 simple cache, lurcache, lfucache, rrcache"
date: 2019-07-18 18:00:00 +0800
---



## 自定义实现cache


```python
import time

def cached(ttl=3600*24, maxsize=None):
    def decorator(func):
        cache = {}
        def wrapper(*args,**kwargs):
            key = str(args)+str(kwargs)

            if key not in cache or time.time() > cache[key]['expires']:

                if len(cache) > maxsize:
                    print('cache buffer pop: %s' %key)
                    for key in cache.keys():
                        cache.pop(key)
                        break
                else:
                    print ('missing: %s' %key)
                cache[key] = {"value": func(*args,**kwargs),"expires":time.time()+ ttl}
            else:
                print ('hit: %s' %key)

            return cache[key]['value']

        return wrapper
    return decorator


@cached(ttl=5, maxsize=2)
def add(x, y):
    return x+y

# 插入缓存
for i in range(3):
    print('1+%s = ' %i, add(1, i))

# 缓存命中
print ('==='*10)
for i in range(3):
    print('1+%s = ' %i, add(1, i))

# 缓存过期
print ('==='*10)
time.sleep(5)
for i in range(3):
    print('1+%s = ' %i, add(1, i))

```

    missing: (1, 0){}
    1+0 =  1
    missing: (1, 1){}
    1+1 =  2
    missing: (1, 2){}
    1+2 =  3
    ==============================
    hit: (1, 0){}
    1+0 =  1
    hit: (1, 1){}
    1+1 =  2
    hit: (1, 2){}
    1+2 =  3
    ==============================
    cache buffer pop: (1, 0){}
    1+0 =  1
    cache buffer pop: (1, 1){}
    1+1 =  2
    cache buffer pop: (1, 2){}
    1+2 =  3


## python自带模块functools.lru_cache

@functools.lru_cache(maxsize=128, typed=False)
一个为函数提供缓存功能的装饰器，缓存 maxsize 组传入参数，在下次以相同参数调用时直接返回上一次的结果。用以节约高开销或I/O函数的调用时间。


### 特点
* 由于使用了字典存储缓存，所以该函数的固定参数和关键字参数必须是可哈希的。

* 不同模式的参数可能被视为不同从而产生多个缓存项，例如, f(a=1, b=2) 和 f(b=2, a=1) 因其参数顺序不同，可能会被缓存两次。

* 如果 maxsize 设置为 None ，LRU功能将被禁用且缓存数量无上限。 maxsize 设置为2的幂时可获得最佳性能。

* 如果 typed 设置为true，不同类型的函数参数将被分别缓存。例如， f(3) 和 f(3.0) 将被视为不同而分别缓存。

### 命中率查看
为了衡量缓存的有效性以便调整 maxsize 形参，被装饰的函数带有一个 cache_info() 函数。当调用 cache_info() 函数时，返回一个具名元组，包含命中次数 hits，未命中次数 misses ，最大缓存数量 maxsize 和 当前缓存大小 currsize。在多线程环境中，命中数与未命中数是不完全准确的。

### 适用
“最久未使用算法”（LRU）缓存 在“最近的调用是即将到来的调用的最佳预测因子”时性能最好（比如，新闻服务器上最受欢迎的文章倾向于每天更改）。 “缓存大小限制”参数保证缓存不会在长时间运行的进程比如说网站服务器上无限制的增加自身的大小。

一般来说，LRU缓存只在当你想要重用之前计算的结果时使用。因此，用它缓存具有副作用的函数、需要在每次调用时创建不同、易变的对象的函数或者诸如time（）或random（）之类的不纯函数是没有意义的。

### 其他
该装饰器也提供了一个用于清理/使缓存失效的函数 cache_clear() 。
原始的未经装饰的函数可以通过 __wrapped__ 属性访问。它可以用于检查、绕过缓存，或使用不同的缓存再次装饰原始函数。


```python
# 简单案例，通过cache_info查看命中率

import functools
@functools.lru_cache(maxsize=100)
def add(x, y):
    return x+y

print ('1+2 =',add(1,2))
print (add.cache_info())
print ('3+4 =',add(3,4))
print (add.cache_info())
print ('1+2 =',add(1,2))
print (add.cache_info())

```

    1+2 = 3
    CacheInfo(hits=0, misses=1, maxsize=100, currsize=1)
    3+4 = 7
    CacheInfo(hits=0, misses=2, maxsize=100, currsize=2)
    1+2 = 3
    CacheInfo(hits=1, misses=2, maxsize=100, currsize=2)



```python
# 获取原始函数

import functools
@functools.lru_cache(maxsize=100)
def add(x, y):
    return x+y

print('当前函数：', add)
print('获取原始函数：', add.__wrapped__)

```

    当前函数： <functools._lru_cache_wrapper object at 0x10de27e10>
    获取原始函数： <function add at 0x10da56598>


## cachetools模块


```python
pip install cachetools
```

    [33mWARNING: The directory '/Users/klook/Library/Caches/pip/http' or its parent directory is not owned by the current user and the cache has been disabled. Please check the permissions and owner of that directory. If executing pip with sudo, you may want sudo's -H flag.[0m
    [33mWARNING: The directory '/Users/klook/Library/Caches/pip' or its parent directory is not owned by the current user and caching wheels has been disabled. check the permissions and owner of that directory. If executing pip with sudo, you may want sudo's -H flag.[0m
    Collecting cachetools
      Downloading https://files.pythonhosted.org/packages/2f/a6/30b0a0bef12283e83e58c1d6e7b5aabc7acfc4110df81a4471655d33e704/cachetools-3.1.1-py2.py3-none-any.whl
    Installing collected packages: cachetools
    Successfully installed cachetools-3.1.1
    Note: you may need to restart the kernel to use updated packages.



```python
# 看看可用模块
import cachetools
for item in dir(cachetools):
    if not item.startswith('__'):
        print(item)
```

    Cache
    LFUCache
    LRUCache
    RRCache
    TTLCache
    _update_wrapper
    abc
    absolute_import
    cache
    cached
    cachedmethod
    functools
    keys
    lfu
    lru
    rr
    ttl


### cache策略
cachetools支持的cache策略有以下几种方式：
Cache     Simple cache。
LFUCache  Least Frequently Used (LFU) cache implementation.
LRUCache  Least Recently Used (LRU) cache implementation.
RRCache  Random Replacement (RR) cache implementation.
TTLCache  LRU Cache implementation with per-item time-to-live (TTL) value.

LRU (Least recently used) 最近最少使用，如果数据最近被访问过，那么将来被访问的几率也更高。
LFU (Least frequently used) 最不经常使用，如果一个数据在最近一段时间内使用次数很少，那么在将来一段时间内被使用的可能性也很小。

### 使用方法
* 利用cached


```python
# cached方法， 装饰器， 修饰函数
def cached(cache, key=keys.hashkey, lock=None):
    """Decorator to wrap a function with a memoizing callable that saves
    results in a cache.

    """
    def decorator(func):
        if cache is None:
```


```python
# 用字典来做cache
from cachetools import cached
@cached(cache={})
def add(x, y):
    print ('%s %s missing' %(x,y))
    return x+y

for i in range(3):
    print (add(i,10))

print ('==='*10)
for i in range(3):
    print (add(i,10))

```

    0 10 missing
    10
    1 10 missing
    11
    2 10 missing
    12
    ==============================
    10
    11
    12



```python
# 使用Cachetools.Cache来做缓存
from cachetools import cached, Cache
@cached(cache=Cache(maxsize=2))   ##  注意这里的maxsize不能少于你的存取数量，否则缓存会失效
def add(x, y):
    print ('%s %s missing' %(x,y))
    return x+y

for i in range(3):
    print (add(i,10))

print ('==='*10)
for i in range(3):
    print (add(i,10))
```

    0 10 missing
    10
    1 10 missing
    11
    2 10 missing
    12
    ==============================
    0 10 missing
    10
    1 10 missing
    11
    2 10 missing
    12



```python
# 使用Cachetools.Cache来做缓存
from cachetools import cached, LRUCache
@cached(cache=LRUCache(maxsize=2))  ##  注意这里的maxsize不能少于你的存取数量，否则缓存会失效
def add(x, y):
    print ('%s %s missing' %(x,y))
    return x+y

for i in range(3):
     print ('result--->', add(i,10))

for i in range(3):
     print ('result--->', add(i,10))

print ('==='*10)
for i in range(3):
    print ('result--->', add(i,10))
```

    0 10 missing
    result---> 10
    1 10 missing
    result---> 11
    2 10 missing
    result---> 12
    0 10 missing
    result---> 10
    1 10 missing
    result---> 11
    2 10 missing
    result---> 12
    ==============================
    0 10 missing
    result---> 10
    1 10 missing
    result---> 11
    2 10 missing
    result---> 12


* 利用cachedmethod


```python
# cachedmethod方法， 装饰器， 修饰类方法
def cachedmethod(cache, key=keys.hashkey, lock=None):
    """Decorator to wrap a class or instance method with a memoizing
    callable that saves results in a cache.

    """
    def decorator(method):
        if lock is None:
            def wrapper(self, *args, **kwargs):
                c = cache(self) # 这里导致调用不是很方便，可以用IDE查看源码
```


```python
# cachedmethod的使用
from operator import attrgetter
from cachetools import Cache, cachedmethod
class Test:
    def __init__(self, maxsize=3): ##  注意这里的maxsize不能少于你的存取数量，否则缓存会失效
        self.cache = Cache(maxsize=maxsize)
    @cachedmethod(cache=attrgetter('cache'))
    def add(self, x, y):
        print ('%s %s missing' %(x,y))
        return x+y

t = Test()

for i in range(3):
     print ('result--->', t.add(i,10))

for i in range(3):
     print ('result--->', t.add(i,10))

print ('==='*10)
for i in range(3):
    print ('result--->', t.add(i,10))
```

    0 10 missing
    result---> 10
    1 10 missing
    result---> 11
    2 10 missing
    result---> 12
    result---> 10
    result---> 11
    result---> 12
    ==============================
    result---> 10
    result---> 11
    result---> 12


## 自定义利用TTLCache


```python
from cachetools import TTLCache
from functools import wraps

class Memorize:
    def __init__(self, maxsize, ttl, create_key=None):
        self.create_key = create_key or (lambda *args, **kwargs: str(args)+str(kwargs))
        self.ttl = ttl
        self._cache = TTLCache(maxsize=maxsize, ttl=ttl)

    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            key = "{}.{}".format(func.__qualname__, self.create_key(*args, **kwargs))
            value = self._cache.get(key, None)
            if value is None:
                value = func(*args, **kwargs)
                if value is not None:
                    print ('missing----')
                    self._cache[key] = value
            else:
                print ('hit----')

            return value
        return wrapper


@Memorize(maxsize=3, ttl=2)
def add(x,y):
    return x+y


for i in range(3):
     print ('result--->', add(i,10))

for i in range(3):
     print ('result--->', add(i,10))

import time
time.sleep(2)  # sleep 2 seconds

print ('==='*10)
for i in range(3):
    print ('result--->', add(i,10))
```

    missing----
    result---> 10
    missing----
    result---> 11
    missing----
    result---> 12
    hit----
    result---> 10
    hit----
    result---> 11
    hit----
    result---> 12
    ==============================
    missing----
    result---> 10
    missing----
    result---> 11
    missing----
    result---> 12



