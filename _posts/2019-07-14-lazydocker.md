---
layout: post
title: lazydocker 使用时 log 过长的解决方案
author: elfgzp
categories: [ tools ]
tags: [ tools, docker, docker-compose ]
image: assets/images/2019-07-14-lazydocker/59972109-8e9c8480-95cc-11e9-8350-38f7f86ba76d.png
description: 实用的小工具 lazydocker
date: 2019-07-14 10:00:00 +0800
featured: true
hidden: true
rating: null
---

## Lazydocker
>  The lazier way to manage everything docker - [jesseduffield/lazydocker](http://https://github.com/jesseduffield/lazydocker)

这是一个非常好用的小工具，但是在使用过程中发现 log 过长时效果不是很好。

![gif](/assets/images/2019-07-14-lazydocker/lazydocker-1.gif)

阅读官方 [README](http://https://github.com/jesseduffield/lazydocker/blob/master/docs/Config.md) 后发现是可以配置的，配置文件路径如下：  

```plain-text
Locations:
- OSX: `~/Library/Application Support/jesseduffield/lazydocker/config.yml`
- Linux: `~/.config/jesseduffield/lazydocker/config.yml`
- Windows: `C:\\Users\\<User>\\AppData\\Roaming\\jesseduffield\\lazydocker\\config.yml` (I think)
```

但是这里有个坑了，在 `OSX` 下的路径应该为：  
`~/Library/Application\ Support/jesseduffield/lazydocker/config.yml`  
⚠️注意那个右斜杠！  

默认的配置如下，如果上面路径不存在配置文件可以复制进去：

{% raw %}
```yaml
gui:
  scrollHeight: 2
  theme:
    activeBorderColor:
    - green
    - bold
    inactiveBorderColor:
    - white
    optionsTextColor:
    - blue
  returnImmediately: false
  wrapMainPanel: false
reporting: undetermined
commandTemplates:
  dockerCompose: docker-compose
  restartService: '{{ .DockerCompose }} restart {{ .Service.Name }}'
  stopService: '{{ .DockerCompose }} stop {{ .Service.Name }}'
  serviceLogs: '{{ .DockerCompose }} logs --since=60m --follow {{ .Service.Name }}'
  viewServiceLogs: '{{ .DockerCompose }} logs --follow {{ .Service.Name }}'
  rebuildService: '{{ .DockerCompose }} up -d --build {{ .Service.Name }}'
  recreateService: '{{ .DockerCompose }} up -d --force-recreate {{ .Service.Name }}'
  viewContainerLogs: docker logs --timestamps --follow --since=60m {{ .Container.ID
    }}
  containerLogs: docker logs --timestamps --follow --since=60m {{ .Container.ID }}
  allLogs: '{{ .DockerCompose }} logs --tail=300 --follow'
  viewAlLogs: '{{ .DockerCompose }} logs'
  dockerComposeConfig: '{{ .DockerCompose }} config'
  checkDockerComposeConfig: '{{ .DockerCompose }} config --quiet'
  serviceTop: '{{ .DockerCompose }} top {{ .Service.Name }}'
customCommands:
  containers:
  - name: bash
    attach: true
    command: docker exec -it {{ .Container.ID }} /bin/sh
    serviceNames: []
oS:
  openCommand: open {{filename}}
  openLinkCommand: open {{link}}
update:
  method: never
stats:
  graphs:
  - caption: CPU (%)
    statPath: DerivedStats.CPUPercentage
    color: blue
  - caption: Memory (%)
    statPath: DerivedStats.MemoryPercentage
    color: green
```
{% endraw %}

将其中的 `wrapMainPanel` 设置为 `true`，log 过长的问题就可以解决了。    
我们来看看效果。  
![gif2](/assets/images/2019-07-14-lazydocker/lazydocker-2.gif)
