# SDL2 Controller Test

这个目录包含一个独立的 SDL2 手柄测试程序，面向 `ROCKNIX-RK3566` 的交叉编译工具链。

## 功能

- 自动识别并打开第一个 SDL2 `GameController`
- 显示双摇杆、双扳机、方向键和常用按键状态
- 支持标准震动测试
- 支持 trigger rumble 测试
- 支持热插拔

## 按键说明

- `A`: 弱震动
- `B`: 强震动
- `X`: 双马达同时震动
- `Y`: trigger rumble
- `START`: 开关循环震动 demo
- `BACK`: 停止全部震动
- `GUIDE`: 退出

程序也会把状态和测试结果输出到终端日志，方便你在目标机器上从 SSH 或本地终端启动后查看。

## 交叉编译

在仓库根目录执行：

```bash
./tools/sdl2-controller-test/build-rk3566.sh
```

如果需要，也可以把工具链路径作为第一个参数传入：

```bash
./tools/sdl2-controller-test/build-rk3566.sh /path/to/toolchain
```

编译产物默认输出到：

```text
tools/sdl2-controller-test/out/sdl2-controller-test-rk3566
```
