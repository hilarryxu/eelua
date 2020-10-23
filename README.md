eelua
=====

用于 [EverEdit](http://www.everedit.net/) 编辑器的 lua 脚本插件引擎。

特性
-------------------

    1. 封装导出了 EverEdit 提供的一些接口
    2. 在菜单中显示特定目录下的脚本文件，点击选择后执行
    3. 注册快捷键命令，绑定快捷键后执行脚本
    4. 提供了一个 `dofile` 接口，可用于模式文件中调用执行 lua 脚本
    5. 其他更多功能陆续更新中...

系统要求
-------------------

使用 mingw 和 premake5 进行编译

- [mingw](http://www.mingw.org/)
- [premake5](https://github.com/premake/premake-core)

编译
----------------

```
premake5 gmake
make
```

安装
----------------

在发布页根据平台下载对应的 ezip 文件，直接拖到 EverEdit 编辑器提示安装即可。

```
EverEdit/
  everedit.exe
  lua51.dll
  plugin/
    eelua.dll
  eelua/
    eelua_init.lua  # 启动初始化脚本
    eeluarc.lua  # 用户自定义配置脚本
    plugins/  # 自定义插件脚本
    scripts/  # 显示在 “扩展” -> “插件” -> “lua scripts” 下的脚本文件
```

需要 c 环境编译的 `eelua.dll` 无改动不需要更新，也就是说后续只需自行更新 eelua 脚本目录。

使用
----------------

可以参考 scripts 目录下示例，接口文档正在更新中，也可以查看源码了解接口使用。

TODO
----------------

License
----------------

eelua is made available under the terms of MIT license. See the LICENSE file that accompanies this distribution for the full text of the license.
