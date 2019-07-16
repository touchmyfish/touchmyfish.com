---
layout: post
title: go fmt 引起的 stack overflow
author: vnotes
categories: [ golang ]
tags: [golang]
image: assets/images/vnotes/2019-07-16-go-stackover.jpg
description: struct String() 遇到的坑
date: 2019-07-16 17:00:00 +0800
featured: true
hidden: true
rating: null
---

在 GO 里实现 String 方法会格式化输出。例如：
```
package main

import (
	"fmt"
)

type People struct {
	Name string
	Age  int
	Sex  string
}

func (p *People) String() string {
	return fmt.Sprintf("people info: %+v", p)
}

func main() {
	p := &People{Name: "Lucy", Age: 18, Sex: "M"}
	fmt.Println(p)
}
```
预期的结果是：`people info: &{Name:Lucy Age:18 Sex:M}`
实际的结果是：
> runtime: goroutine stack exceeds 1000000000-byte limit
fatal error: stack overflow
runtime stack:

在 go 的源码里：`src/fmt/print.go::Stringer`， `Stringer` 接口有 `String` 方法，`People` struct  也有 `String` 方法，间接实现了 `Stringer` 接口，因此出现了 `stack overflow` 的错误，递归了。

## 解决办法：
- 把 `String` 方法改为 `ToString`
- 在 `People.String` 方法里传递属性，即把 `fmt.Sprintf("people info: %+v", p)` 改为 `fmt.Sprintf("people info: Name:%s, Age:%d, Sex:%s", p.Name, p.Age, p.Sex)`

参考文章:[ golang fmt递归引起stack overflow异常]([http://xiaorui.cc/2019/06/17/golang-fmt%E9%80%92%E5%BD%92%E5%BC%95%E8%B5%B7stack-overflow%E5%BC%82%E5%B8%B8/](http://xiaorui.cc/2019/06/17/golang-fmt%E9%80%92%E5%BD%92%E5%BC%95%E8%B5%B7stack-overflow%E5%BC%82%E5%B8%B8/)
)