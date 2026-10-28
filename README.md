# desktop-pet

Windows 桌面宠物 / 小工具合集。全部基于原生 PowerShell + WinForms（GDI+）实现，**不需要安装任何运行环境**，双击即用。

## 项目结构

```
desktop-pet/
├── whale-pet/        桌面宠物（当前：鲸鱼娘女仆立绘版）
│   ├── GirlPet.ps1       主程序：加载立绘，点一下跳一下
│   ├── girl_alpha.png    透明背景立绘（AI 生成 + 自动抠白底）
│   ├── girl.png          原始立绘（白底）
│   ├── remove_bg.py      抠图脚本（四边泛洪填充，保留角色内部白色）
│   ├── WhalePet.ps1      早期版本：GDI+ 手绘小鲸鱼
│   ├── 启动小女生.vbs     静默启动器（隐藏控制台）
│   └── README.md         宠物的详细说明
└── desktop-tool/     桌面小工具箱（网页版）
    ├── index.html        便签 / 倒计时 / 剪贴板 / 待办 / 速算
    ├── app.js            逻辑与本地存储
    └── 启动小工具.bat     用 Edge --app 模式打开小窗
```

## 桌面宠物（whale-pet）

透明背景、无边框、置顶的桌面宠物，浮在所有窗口之上。

**功能**

- 点一下 → 跳起来 + 左右摆动 + 落地阴影
- 按住可拖动到屏幕任意位置
- 右键 → 退出
- 开机自启（把启动器的快捷方式放进 Startup 目录）

**启动**

双击 `whale-pet/启动小女生.vbs`。它通过 `wscript` 隐藏窗口调用 PowerShell，不会闪黑框。

**换形象**

只需要替换 `whale-pet/girl_alpha.png`（透明背景 PNG），程序无需改动。

**技术要点**

| 问题 | 解法 |
|---|---|
| 想要透明背景 | `BackColor` + `TransparencyKey` 设为同一个洋红色 |
| 无边框 / 置顶 | `FormBorderStyle='None'`、`TopMost=$true` |
| 不占任务栏 | `ShowInTaskbar=$false` |
| 脚本被策略拦截 | 启动器带 `-ExecutionPolicy Bypass` |
| 中文/emoji 乱码报语法错 | `.ps1` 必须保存为 **UTF-8 with BOM** |
| 生成的 PNG 白底不透明 | `remove_bg.py` 从四边泛洪填充抠图 |

## 桌面小工具（desktop-tool）

一个输入框式的效率小工具，用 Edge 的 `--app` 模式运行，像原生小程序。

- **便签**：随手记，本地保存
- **倒计时**：开始/暂停/重置，最后 10 秒变红
- **剪贴板**：自动记录复制内容，点击回填
- **待办**：添加、勾选、删除
- **速算**：四则运算 + 常用单位换算

双击 `desktop-tool/启动小工具.bat` 启动。

## 环境要求

- Windows 10 / 11
- PowerShell 5.1（系统自带）
- 运行桌面宠物无需额外依赖
- 仅在重新生成抠图时需要 Python + Pillow（`pip install pillow`）

## 说明

- 立绘由 AI 生成，抠图与程序逻辑为本地实现
- 所有数据（状态、便签等）仅保存在本机，不上传
