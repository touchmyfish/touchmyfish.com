---
layout: post
title:  "Python 中如何优雅地将字典转化对象"
author: Mayne
categories: [ Python ]
tags: [ Python ]
description: "能少敲4个字符呢"
date: 2019-07-19 11:29:00 +0800
---

## 羡慕 JS 的语法糖

先看下面一段 JS 代码
```javascript
let npc =  {
        name: {
            "first": "san",
            last: "zhang"
        },
        hp: 1000
}

npc.name.first
// "san"

npc["name"].first
// "san"
```

JS中的“字典”天然就是一个对象，所以可以通过点的方式访问对象属性。而 python 中通过键获取映射值通常需要下面这样。

```python
a_dict["key"] 
a_dict.get("key")
```

有点怀念 JS 简洁的语法了。你要知道用点访问，可以少敲 `[` 、 `"` *2 、 `]`  4 个字符，这个语法糖难道不甜嘛？

在 python 中要用点访问，必须把字典转化为对象。

## 字典转对象

强大的内置电池

```python
In [1]: from types import SimpleNamespace

In [2]: npc = {
   ...:  'name': {
   ...:    'first': 'san',
   ...:    'last': 'zhang'
   ...:  },
   ...:  'hp': 1000
   ...: }

In [3]: npc
Out[3]: {'name': {'first': 'san', 'last': 'zhang'}, 'hp': 1000}

In [4]: npc = SimpleNamespace(**npc)

In [5]: npc.hp
Out[5]: 1000
```

到目前为止一切 OK，又可以点点点了。

```python
In [6]: npc.name
Out[6]: {'first': 'san', 'last': 'zhang'}

In [7]: npc.name.first
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
<ipython-input-7-7749b491d382> in <module>
----> 1 npc.name.first

AttributeError: 'dict' object has no attribute 'first'
```

很明显，对于嵌套字典 `SimpleNamespace` 没法自动处理，只能转换第一层字典为对象。我们需要对其进行递归处理。

## 处理通用的嵌套字典

嵌套字典中的值，可能是 list，可能是 dict，也可能是基础数据类型。因此在处理递归的过程中，我们需要对不同类型的值，做不同的处理。

下面推荐内置电池中的 `singledispatch` 

```python 
In [12]: singledispatch?
Signature: singledispatch(func)
Docstring:
Single-dispatch generic function decorator.

Transforms a function into a generic function, which can have different
behaviours depending upon the type of its first argument. The decorated
function acts as the default implementation, and additional
implementations can be registered using the register() attribute of the
generic function.
File:      /usr/local/Cellar/python/3.7.3/Frameworks/Python.framework/Versions/3.7/lib/python3.7/functools.py
Type:      function
```

简单的说，它是一个装饰器。可以为被装饰函数第一个参数，注册不同的处理逻辑。

举个例子
```python
In [13]: @singledispatch
    ...: def mytype(obj):
    ...:     return obj

In [16]: @mytype.register(list)
    ...: def handle_list(obj):
    ...:     print("i am list")
    ...:     return obj

# 返回 list 之前，打印自己的类型
In [17]: mytype([1,2,3,4])
i am list
Out[17]: [1, 2, 3, 4]

# 因为没有注册对于字符串的处理函数，所以会直接返回 obj，即 mytype 的处理逻辑。
In [18]: mytype("a")
Out[18]: 'a'
```

下面我们来构建一个可以处理嵌套字典的 `dict2obj` 函数

``` python
In [22]: @singledispatch
    ...: def dict2obj(o):
    ...:     return o
    ...:

In [23]: @dict2obj.register(dict)
    ...: def handle_obj(obj):
    ...:     return SimpleNamespace(**{ k:dict2obj(v) for k,v in obj.items() })
    ...:

In [24]: @dict2obj.register(list)
    ...: def handle_list(lst):
    ...:     return [ dict2obj(i) for i in lst]
```

测试一下
``` python
In [28]: zhangsan = {'name': {'first': 'san', 'last': 'zhang'}, 'hp': 1000}

In [29]: lisi = {'name': {'first': 'si', 'last': 'li'}, 'hp': 1000, 'friends': [zhangsan]}

In [32]: lisi
Out[32]:
{'name': {'first': 'si', 'last': 'li'},
 'hp': 1000,
 'friends': [{'name': {'first': 'san', 'last': 'zhang'}, 'hp': 1000}]}

In [33]: obj_lisi = dict2obj(lisi)

In [34]: obj_lisi.name
Out[34]: namespace(first='si', last='li')

In [35]: obj_lisi.name.first
Out[35]: 'si'

In [36]: obj_lisi.hp
Out[36]: 1000

In [37]: obj_lisi.friends[0].name
Out[37]: namespace(first='san', last='zhang')

In [38]: obj_lisi.friends[0].name.first
Out[38]: 'san'
```

## 完整演示代码

[https://gist.github.com/mayneyao/6a09bd97237f23c0cb68730715b21851](https://gist.github.com/mayneyao/6a09bd97237f23c0cb68730715b21851)
