---
title: 强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具
cover: https://img.090227.xyz/file/ae62475a131f3734a201c.png
swiper_index: 10
top_group_index: 10
background: '#fff'
date: 2025-03-23 12:00:37
updated:
tags:
categories:
keywords:
description:
top:
top_img:
comments:
toc:
toc_number:
toc_style_simple:
copyright:
copyright_author:
copyright_author_href:
copyright_url:
copyright_info:
mathjax:
katex:
aplayer:
highlight_shrink:
aside:
ai:
---

<div class="video-container">
https://youtu.be/D5KJ_xxOijI
</div>

<style>
.video-container {
    position: relative;
    width: 100%;
    padding-top: 56.25%; /* 16:9 aspect ratio (height/width = 9/16 * 100%) */
}

.video-container iframe {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
}
</style>



## 前言

Sub-Store！这是一款高级订阅管理工具

主要用于管理和优化各类在线订阅的内容，它提供了高度定制化的功能

方便用户对自建节点、订阅链接等进行全面的控制和优化。比如订阅的合并、过滤、去重、更新等，节点的排序、分类、emoi旗帜添加等。

## 视频演示

[![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/22.png)](https://youtu.be/D5KJ_xxOijI)

## 准备工作

1、VPS 一台，重置好主流的操作系统（演示为 Debian 12，VPS 来自 [搬瓦工 CN2GT](https://v2rayssr.com/bwgvps/) ，机房 DC3）

2、域名一个，托管到 Cloudflare，并解析到 VPS（若是不会，请看：[保姆级节点搭建！VPS、域名、CF、VLESS小白教程！](https://v2rayssr.com/teach-vless.html)）

## 项目地址

前端：[GitHub 地址](https://github.com/sub-store-org/Sub-Store-Front-End)

后端：[GitHub 地址](https://github.com/sub-store-org/Sub-Store)

以下是没有宝塔面板的搭建方式，若是有宝塔面板，会方便很多

### 更新系统

1. apt update -y   #Debian 命令

### 安装所需组件

1. apt install unzip curl wget git sudo -y   #Debian 命令

### 安装 FNM 版本管理器

1. curl -fsSL https://fnm.vercel.app/install | bash

按照回显的图示，运行命令保存生效

1. source /root/.bashrc  #请按照你的回显提示命令进行输入，我这边路径是 /root

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/1.png)

### FNM 安装 Node

1. fnm install v20.18.0
2. node -v  # 回显返回版本号即为安装成功

### 安装 PNPM 软件包管理器

1. curl -fsSL https://get.pnpm.io/install.sh | sh -

按照回显的图示，运行命令

1. source /root/.bashrc

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/2.png)

### 安装 Sub-Store

#### 创建文件夹并拉取项目

1. mkdir -p /root/sub-store  #在 root 目录下面创建 sub-store 文件夹
2. cd sub-store   #进入 sub-store 文件夹

#### 拉取项目并解压

1. # 拉取后端项目
2. curl -fsSL https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js -o sub-store.bundle.js

4. # 拉取前端项目
5. curl -fsSL https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip -o dist.zip

解压前端文件，并改名为 frontend，而后删除源压缩文件

1. unzip dist.zip && mv dist frontend && rm dist.zip

#### 创建系统服务

pm2 的启动方式会有 BUG,所以我们采用服务进程的方式来启动

进入 VPS 目录 `/etc/systemd/system/`，在里面创建一个文件 `sub-store.service`，写入以下服务信息

1. [Unit]
2. Description=Sub-Store
3. After=network-online.target
4. Wants=network-online.target systemd-networkd-wait-online.service

6. [Service]
7. LimitNOFILE=32767
8. Type=simple
9. Environment="SUB_STORE_FRONTEND_BACKEND_PATH=/9GgGyhWFEguXZBT3oHPY"
10. Environment="SUB_STORE_BACKEND_CRON=0 0 * * *"
11. Environment="SUB_STORE_FRONTEND_PATH=/root/sub-store/frontend"
12. Environment="SUB_STORE_FRONTEND_HOST=0.0.0.0"
13. Environment="SUB_STORE_FRONTEND_PORT=3001"
14. Environment="SUB_STORE_DATA_BASE_PATH=/root/sub-store"
15. Environment="SUB_STORE_BACKEND_API_HOST=127.0.0.1"
16. Environment="SUB_STORE_BACKEND_API_PORT=3000"
17. ExecStart=/root/.local/share/fnm/fnm exec --using v20.18.0 node /root/sub-store/sub-store.bundle.js
18. User=root
19. Group=root
20. Restart=on-failure
21. RestartSec=5s
22. ExecStartPre=/bin/sh -c ulimit -n 51200
23. StandardOutput=journal
24. StandardError=journal

26. [Install]
27. WantedBy=multi-user.target

上面服务代码中的 `9GgGyhWFEguXZBT3oHPY` 为API请求密钥，请自行修改，推荐自动生成地址：[点击访问](https://1password.com/zh-cn/password-generator)

后端服务相关命令

1. systemctl start sub-store.service     #启动服务
2. systemctl enable sub-store.service    #设置为开机自启
3. systemctl status sub-store.service    #查看服务状态
4. systemctl stop sub-store.service      #停止服务
5. systemctl restart sub-store.service   #重启服务

正常情况下，运行服务状态，应该类似下图：（ `active:running` ）

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/3.png)

若是出现错误，你也是可以通过下面的命令来查看日志，来排除相关的错误

1. # 个命令用于实时查看 sub-store 服务的最新 100 行日志，并继续跟踪后续的日志输出。
2. journalctl -f -u sub-store -o cat -n 100

至此，sub-store 服务搭建完毕，若是不想绑定域名，你目前可以通过如下的IP+API的方式进行请求（当然，还是强烈的建议使用域名，并开启 CDN 的小云朵，用于隐藏真实 IP）

若是确定不使用域名，到这里就结束了。以下的内容可以不用再看！

1. # 9GgGyhWFEguXZBT3oHPY 为你的 API 请求密钥

3. http://IP:3001/?api=http://IP:3001/9GgGyhWFEguXZBT3oHPY

### 解析域名申请证书

我们解析域名，类型 `A` ，名称：`随意` ，内容：`VPS IP` ，代理状态：`开启`，TTL：`自动`

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/41.png)

然后，如下图所示，我们创建一个免费，有效期为 15 年的证书

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/42.png)

记录自己的 证书 以及 密钥文件！

证书文件保存为 `/root/cert/ssl.pem` （方便接下来的 Nginx 的配置，不建议改名字）

密钥文件保存为 `/root/cert/ssl.key`

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/4.png)

### 安装配置 Nginx

安装 Nginx 服务

1. apt install nginx -y

访问 http://VPSIP，可以到达 Nginx 的欢迎页面，证明 Nginx 安装成功

来到 VPS 的 `Nginx` 配置目录：`/etc/nginx/sites-enabled/`

在文件夹下面创建 `sub-store.conf` 文件，而后写入如下反代配置：

注意：需要修改 `sub.myss.us` 为你自己刚才解析的域名

1. server {
2.   listen 443 ssl http2;
3.   listen [::]:443 ssl http2;
4.   server_name sub.myss.us;

6.   ssl_certificate /root/cert/ssl.pem;
7.   ssl_certificate_key /root/cert/ssl.key;

9.   location / {
10.     proxy_pass http://127.0.0.1:3001;
11.     proxy_set_header Host $host;
12.     proxy_set_header X-Real-IP $remote_addr;
13.     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
14.   }

16. }

确认无误以后，保存，并使用如下命令生效：

1. nginx -s reload   # 重载Nginx配置

3. nginx -t          # 查看配置是否正确

重载 Nginx 服务，若是不报错，Nginx 反代成功，目前可以访问如下网址（自行替换域名）到达订阅页面

1. https://sub.myss.us/?api=https://sub.myss.us/9GgGyhWFEguXZBT3oHPY

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/5.png)

### Sub-Store 服务更新

1. systemctl stop sub-store.service  # 停止服务
2. cd sub-store            # 进入 sub-store 文件夹
3. # 更新项目脚本
4. curl -fsSL https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js -o sub-store.bundle.js
5. systemctl daemon-reload      # 重载服务
6. systemctl start sub-store.service  # 启动服务
7. systemctl status sub-store.service  # 查看服务状态

具体的Sub-Store的使用方法，可以查看这期视频

[![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/01/2-1.png)](https://youtu.be/ty5mI3bp6lk)

## Sub-Store 服务搭建（二）

以下是宝塔面板的搭建方式，会方便很多

### 安装Node管理器

我们来到 宝塔面板 – 网站 – Node项目，安装 Node 版本管理器。

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/111.png)

安装完毕之后，点击 `添加Node项目`，点击 `只显示LTS版本`，点击 `更新版本列表`

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/12.png)

我们选择最新的 `V20.18.0` 稳定版安装。

### 创建 Node 项目

我们来到宝塔面板的文件管理器，在 `wwwroot` 文件夹下面创建一个文件夹 `SubStore`

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/1212.png)

进入 `SubStore` 文件夹，在里面创建 `package.json` 文件，并写入以下信息：

其中 `v20.18.0` 是刚才安装的Node的版本号，需要和刚才你安装的版本一致！ `9GgGyhWFEguXZBT3oHPY` ，为你的 API 密钥， `3321` 为端口，可以自行更改，但是后面的反代信息需要随之变动

1. {
2.   "name": "sub-store",
3.   "version": "1.0.0",
4.   "description": "Sub-Store project",
5.   "main": "sub-store.bundle.js",
6.   "scripts": {
7.     "start": "SUB_STORE_FRONTEND_BACKEND_PATH=/9GgGyhWFEguXZBT3oHPY SUB_STORE_BACKEND_CRON='0 0 * * *' SUB_STORE_FRONTEND_PATH=/www/wwwroot/SubStore/dist SUB_STORE_FRONTEND_HOST=0.0.0.0 SUB_STORE_FRONTEND_PORT=3321 SUB_STORE_DATA_BASE_PATH=/www/wwwroot/SubStore SUB_STORE_BACKEND_API_HOST=127.0.0.1 SUB_STORE_BACKEND_API_PORT=3300 /www/server/nodejs/v20.18.0/bin/node /www/wwwroot/SubStore/sub-store.bundle.js"
8.   }
9. }

点击 `上传/下载` – `URL链接下载`，填入下载链接

1. https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js

如图所示：

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/1222.png)

同样的方式，下载前端文件代码

1. https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip

解压 `dist.zip` 到当前目录

再次来到宝塔面板 – 网站 – Node项目，点击 `添加Node项目`

选择项目目录（也就是我们刚刚创建的文件夹），填入项目端口 `3321` 并放行，其他默认，点击确定！

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/12121222.png)

若是配置没有问题，会成功启动

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/222.png)

我们点击项目，进入到项目信息，勾选 `跟随系统服务启动`

不出意外，我们访问 `http://IP:3321/?api=http://IP:3321/9GgGyhWFEguXZBT3oHPY` 会成功的看见我们搭建的服务。现在，我们进行反代！

### 设置反代并部署 SSL 证书

域名的解析刚才已经完成，域名的证书刚才也是申请完成。现在，我们部署反代。

点击宝塔面板 – 网站 – PHP项目 – 添加站点

填入刚刚解析的域名，其他保持默认，完毕之后来到站点管理 – SSL – 当前证书，填入刚才的证书和密钥，开启 强制 HTTP。

来到反向代理 – 添加反向代理，代理名称 `SubStore`，目标URL `http://127.0.0.1:3321`

![强大的节点管理工具：Sub-Store！多机场订阅、自建节点的节点整理工具！VPS、宝塔面板部署教程](https://v2rayssr.com/wp-content/uploads/2024/10/332.png)

至此，搭建完毕，访问：`https://sub.myss.us/?api=https://sub.myss.us/9GgGyhWFEguXZBT3oHPY` 可以到达订阅界面！

### 宝塔面板更新

和刚才的服务搭建是一样的，我们只需要停止服务，然后删除 `sub-store.bundle.js` 文件，重新下载，部署即可！

## 附：节点整理脚本

杂乱的节点排序无章的，可以试试如下脚本，让你的节点赏心悦目，具体使用可以观看 [本期视频](https://youtu.be/D5KJ_xxOijI)

1. https://raw.githubusercontent.com/Keywos/rule/main/rename.js

## 后记

至于 Sub-Store 的详细使用，篇幅有限，可以观看本期的视频演示。

总体来说，Sub-Store 订阅管理工具，是一个不可多得的订阅工具，它不但可以整理节点，添加 emoji 图标等，还可以把单个或是多个机场订阅混合上自己的节点，一起订阅在自己的客户端软件中。值得推荐！