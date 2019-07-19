---
layout: post
title:  "两个常量对象，None 与 ...(ellipsis)"
author: Sky
categories: [ Python ]
tags: [ Python ]
image: assets/images/2019-07-10-None-ellispsis/2019-07-10-None-ellispsis.jpg
description: "None 与。..(ellipsis)"
date: 2019-07-10 18:00:00 +0800
---


## 2019-07-10   两个常量对象, None与...(ellipsis)

本文介绍了两个常量对象None与...(ellipsis)的一些特性，前者非常常见，后者却非常少用，但其实它有一些非常pythonic的用法。


### python版本
```python
# python 版本
import sys
print(sys.version)

```

```
3.6.6 |Anaconda, Inc.| (default, Jun 28 2018, 11:07:29)
[GCC 4.2.1 Compatible Clang 4.0.1 (tags/RELEASE_401/final)]
```


### 1、None对象

None只是一个特殊的对象，不是False，也不是Null

```python
print(type(None))
```

```
<class 'NoneType'>
```



```python
# 1. 单例属性

a = None
b = None
print (a == b)
```

```
True
```



```python
#2. 用is 和is not判断

a = None
if a is None:
    print ('a is None')

b = False
if b is not None:
    print ('b is not None')
```

```
a is None
b is not None
```



```python
#3. 不可添加或者更改属性
a = None
a.test = 1
```

```
---------------------------------------------------------------------------

AttributeError                            Traceback (most recent call last)

<ipython-input-20-4c7cc21b8374> in <module>()
      2 a = None
      3
----> 4 a.test = 1
```

```
AttributeError: 'NoneType' object has no attribute 'test'
```



```python
# 4.  函数不明确return，默认返回None

def test():
    pass

if test() is None:
    print ('test return None')
```

```python
#5. bool类型
print (bool(None))
```

```
False
```

### 2、... 是一个对象，只是一个对象而已

```python
print(type(...))
```

```
<class 'ellipsis'>
```



```python
#1. 单例属性
t = ...
d = ...
print (t == d)
```

```
True
```



```python
#2. 用is 和is not判断

a = ...
if a is not None:
    print ('a is not None')

if a is ...:
    print ('a is ...')
```

```
a is not None
a is ...
```



```python
#3. 不可添加或者更改属性
a = ...
a.test = 1

```

```
---------------------------------------------------------------------------

AttributeError                            Traceback (most recent call last)

<ipython-input-28-8f3574f64285> in <module>()
      1 #3. 不可添加或者更改属性
      2 a = ...
----> 3 a.test = 1

```

```
AttributeError: 'ellipsis' object has no attribute 'test'

```



```python
#5. bool类型
print (bool(...))

```

```
True

```


### ellipsis对象的pythonic用法

```python
#6.  用法, 无限递推 (from https://farer.org/2017/11/29/python-ellipsis-object/)
class Mogic(object):
    def __getitem__(self, key):
        if len(key) == 3 and key[2] is Ellipsis:
            d = key[1] - key[0]
            r = key[0]
            while True:
                yield r
                r += d

ap  =  Mogic()

for i in ap[1,2,...]:
    if i<20:
        print (i)
    else:
        break  ## 阻止循环

```

```
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
```



```python
#7. numpy中的玩法(实现原理同上)
import numpy as np
a = np.arange(6).reshape(2,3)

for x in np.nditer(a, op_flags=['readwrite']):
    x[...] = 2 * x

print (a)
```

```
[[ 0  2  4]
 [ 6  8 10]]
```



```python
#8. type hints用法

# 在类型提示中使用 Callable，不确定参数签名时，可以用 Ellipsis 占位。

from typing import Callable

def foo() -> Callable[..., int]:
    return lambda x: 1

# 使用 Tuple 时返回不定长的 tuple，用 Ellipsis 进行指定。

from typing import  Tuple

def bar() -> Tuple[int, ...]:
    return (1,2,3)

def buzz() -> Tuple[int, ...]:
    return (1,2,3,4)
```
