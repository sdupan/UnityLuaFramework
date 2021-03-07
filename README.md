# Unity Lua Framework

## 简介

    Unity下基于Addressable Assets System和xLua的全lua编程框架。

    记录作者在学习Unity过程中常用的技术及插件，并形成框架体系，方便温故知新。

## 各平台库编译

    请下载 https://github.com/sdupan/XLua-Build  并自行编译各平台库

## 运行环境

    1、请在Unity2019.4及以上环境运行
    2、运行前，执行菜单：LuaGame/Publish Lua Scripts
    3、打包APK或ipa前，执行菜单：XLua/Generate Code

## 入口

* 场景：Assets/Scenes/GameEntry.unity

* C#脚本：Assets/Scripts/GameEntry.cs

* Lua脚本：Assets/LuaScripts/GameMain.lua

## 主要功能模块

* 资源管理：Addressable Assets System

    ★ Unity官方推出的一套强大的资源管理解决方案，在整个开发周期中，都能发挥其作用。

    ★ 能用同一套代码，实现编辑器、运行时环境下的资源加载、更新，且能自动管理和加载全部依赖项。

    ★ 能够方便实现增量更新、分包、边玩边下功能。

* Lua框架：[xLua](https://github.com/Tencent/xLua)

    ★ 支持热补丁修复，运行时下用Lua替换C#实现。

    ★ 能用同一套代码，实现编辑器、运行时环境下的资源加载、更新，且能自动管理和加载全部依赖项。

    ★ 编辑器下无需生成代码，开发更轻量。

* UI方案：[FairyGUI](https://www.fairygui.com/)

    ★ 功能上和效率上，都能满足所有大部分UI设计的需求。

    ★ 大部分UGUI需要用插件完成的功能，FairyGUI均已经内置，而且很多可以在编辑器零脚本完成。

    ★ FairyGUI也可以和UGUI混用，方便处理一些特殊需求。

* 网络通信：[LuaSocket](https://github.com/diegonehab/luasocket)

    ★ Lua的网络库，它提供 TCP、UDP、DNS、FTP、HTTP、SMTP、MIME 等多种网络协议的访问操作。

    ★ 一部分是用 C 写的核心，提供对 TCP 和 UDP 传输层的访问支持。另外一部分是用 Lua 写，负责应用功能的网络接口处理。

* 网络协议：[Protobuf](https://github.com/starwing/lua-protobuf)

    ★ protobuf是Google提供一个具有高效的协议数据交换格式工具库。

    ★ 此为protobuf在lua下的实现，支持5.1, 5.2, 5.3, 5.4和LuaJIT。

* 缓动动画：[DOTWeen](http://dotween.demigiant.com/)
    
    ★ 一款针对Unity的快速高效、类型安全的面向对象的补间动画引擎，并且对于C#用户做出了很多的优化

    ★ 兼顾速度与效率，一切都被缓存并重用，以避免无用的GC分配。

    ★ 智能感知和类型安全，所有代码都是完整的XML注释，并组织起来，以充分利用智能感知。

* 寻路：[A* PathFinding Project](https://www.arongranberg.com/astar/)

    ★ 一个强大且易于使用的统一寻路系统。非常适合TD、FPS和RTS游戏。

    ★ 支持网格、navmesh、点和六边形图形。

    ★ 文档详细且齐全，具备教科书式的教程和范例。

## 更多待添加

* AI：[Behavior Designer](https://opsive.com/assets/behavior-designer)

* 音乐音效：[Wwise](https://www.audiokinetic.com/zh/products/wwise/)

* UI管理

* 实体管理

* 场景管理

* 特效管理

* 配置管理


## 参考

* [tolua](https://github.com/topameng/tolua)

* [Nice-Lua](https://github.com/justin-sky/nice-lua)