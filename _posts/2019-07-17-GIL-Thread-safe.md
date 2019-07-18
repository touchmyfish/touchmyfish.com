---
layout: post
title:  "GIL与python线程安全 单例模式 singleton"
author: Sky
categories: [ Python ]
tags: [ Python ]
image: assets/images/2019-07-17-GIL-Thread-safe/GIL.jpg
description: "GIL与python线程安全 单例模式 singleton"
date: 2019-07-17 18:00:00 +0800
---

## 什么是GIL
global interpreter lock -- 全局解释器锁
CPython 解释器所采用的一种机制，它确保同一时刻只有一个线程在执行 Python bytecode。此机制通过设置对象模型（包括 dict 等重要内置类型）针对并发访问的隐式安全简化了 CPython 实现。给整个解释器加锁使得解释器多线程运行更方便，其代价则是牺牲了在多处理器上的并行性

## 什么是线程安全
线程安全是多线程编程时的计算机程序代码中的一个概念。在拥有共享数据的多条线程并行执行的程序中，线程安全的代码会通过同步机制保证各个线程都可以正常且正确的执行，不会出现数据污染等意外情况。

## python 线程安全
GIL保证的是bytecode同一时刻只能被一个线程执行，但是同一个操作是对应多个bytecodes的，在此时线程切换将会造成数据污染。

## python 线程调度
python使用C实现的，实际上python的线程就是C语言的pthread，通过操作系统调度算法进行调度；
python线程虽说是系统线程（遵循系统线程调度），但是却有自己的切换条件，在python2中默认是字节码执行100条，python3.2后是时间切片，达到规则后就自动强制释放GIL。

## python2线程切换条件


```python
# sys.setcheckinterval(interval)
# Set the interpreter’s “check interval”.
# This integer value determines how often the interpreter checks for periodic things such as thread switches and signal handlers.
# The default is 100, meaning the check is performed every 100 Python virtual instructions.
# Setting it to a larger value may increase performance for programs using threads. Setting it to a value <= 0 checks every virtual instruction,
# maximizing responsiveness as well as overhead.

import sys
print(sys.getcheckinterval())
```

    100


    /Users/klook/anaconda3/envs/3.7.1_basic/lib/python3.7/site-packages/ipykernel_launcher.py:9: DeprecationWarning: sys.getcheckinterval() and sys.setcheckinterval() are deprecated.  Use sys.getswitchinterval() instead.
      if __name__ == '__main__':


## python3.2后版本线程切换条件


```python
# sys.setswitchinterval(interval)
# Set the interpreter’s thread switch interval (in seconds).
# This floating-point value determines the ideal duration of the “timeslices” allocated to concurrently running Python threads.
# Please note that the actual value can be higher, especially if long-running internal functions or methods are used.
# Also, which thread becomes scheduled at the end of the interval is the operating system’s decision. The interpreter doesn’t have its own scheduler.
# New in version 3.2.

import sys
print(sys.getswitchinterval())
```

    0.005


## 线程安全的单例模式（面试可能遇到哦）

### 利用模块只加载一次的特性


```python
class Singleton:
    __instance = None
    def __new__(cls, age, name):
        if not cls.__instance:
            cls.__instance = object.__new__(cls)
        return cls.__instance

singleton = Singleton(99, 'sky')
```

### 给资源加锁


```python
import threading

lock = threading.Lock()

class Singleton:
    __instance = None
    def __new__(cls, age, name):
        with lock:
            if not cls.__instance:
                cls.__instance = object.__new__(cls)
        return cls.__instance

```


```python

```
