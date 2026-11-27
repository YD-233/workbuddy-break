# WorkBuddy 提示词修改工具（Windows 版）

一个用于提取、修改、注入 WorkBuddy 系统提示词模板的工具。适用于 Windows 上的 WorkBuddy 5.x 桌面客户端。

无需安装任何依赖，只需要 Windows 自带的 PowerShell。

## 先看这里：为什么网上的旧教程没用

网上流传的教程（包括 GitHub 上的 WorkBuddy-Prompt-Patcher）都让你改安装目录下的 `app.asar.unpacked` 或 `templates/` 文件夹。**在 WorkBuddy 5.x 上这样做完全无效。**

原因：5.x 版本运行时读取的是**用户缓存目录**里的模板，不是安装目录里的副本。安装目录里的文件改了也不生效。

本工具直接操作真正生效的缓存目录：

```
%USERPROFILE%\.workbuddy\plugins\cache\workbuddy-builtin\
```

## 提示词是怎么拼出来的

WorkBuddy 的系统提示词由两部分拼装：

| 类型 | 路径 | 内容 |
| :--- | :--- | :--- |
| 主模板 | `welcomemode-<模式>\<版本>\prompt.tpl` | 身份句、安全策略、文件操作规则等 |
| 行为片段 | `interactionmode-<模式>\<版本>\fragments\*.md` | 循环流程、结果呈现、工具使用等 |

主模板通过 `{% include %}` 把行为片段拼进来。版本目录名形如 `5.11.3-wb.43806934.gecace0f7.h4094f2d5641e`，工具会自动扫描所有版本，不需要手动填写。

## 使用方法

### 方式一：双击运行（推荐）

双击 `run.bat`，按菜单数字选择操作：

```
[1] 提取模板
[2] 注入改动
[3] 恢复官方原版
[4] 查看状态
[0] 退出
```

### 方式二：命令行

在本文件夹打开 PowerShell，执行：

```powershell
.\wb-prompt.ps1 extract
.\wb-prompt.ps1 apply
.\wb-prompt.ps1 restore
.\wb-prompt.ps1 status
```

如果 PowerShell 提示"禁止运行脚本"，用这个方式绕过：

```powershell
powershell -ExecutionPolicy Bypass -File .\wb-prompt.ps1 extract
```

## 完整流程

```powershell
# 1. 提取：把当前生效的模板复制到桌面工作目录
.\wb-prompt.ps1 extract

# 2. 编辑：到桌面 WorkBuddy-Prompts-Workspace 目录里改文件
#    主模板改 prompt.tpl，行为块改 fragments\*.md

# 3. 注入：把改动写回缓存（首次会自动备份官方原版）
.\wb-prompt.ps1 apply

# 4. 完全退出 WorkBuddy 再打开，新建一个对话
```

**关键提醒**：必须新建对话。已经打开的对话在创建时就固化了提示词，重启也不会刷新。

工作目录位置：

```
%USERPROFILE%\Desktop\WorkBuddy-Prompts-Workspace\
```

## 命令说明

| 命令 | 作用 |
| :--- | :--- |
| `extract` | 把缓存里所有模板提取到桌面工作目录，保留目录结构 |
| `apply` | 把工作目录的文件写回缓存；首次运行自动建立官方备份 |
| `restore` | 从备份一键恢复官方原版 |
| `status` | 查看缓存位置、文件数量、备份状态、改动差异 |

## 备份与恢复

- 第一次 `apply` 时会在缓存根目录创建 `.wb-prompt-original\`，保存官方原版
- 改坏了随时运行 `restore` 恢复
- WorkBuddy 升级后缓存会被替换成新版本，需要重新 `extract` 和 `apply`

## 修改模板的注意事项

主模板使用 Jinja2 语法，有两类标记：

- `{% if %}...{% endif %}` 是条件控制，`{{ modelName }}` 是变量，都会在渲染时被执行掉，不会原样发给模型
- 想固定写死某句话，就直接写纯文本，不要用这两类标记
- 改动时保持 `{% if %}` 和 `{% endif %}` 数量配对，否则模板渲染会失败
- `{% include %}` 是行为片段的拼装入口，删掉会导致对应块消失

改完可以用 `status` 看有多少文件跟缓存不一致，确认改动范围。

## 前置条件

- Windows 7 及以上（含 Windows 10/11）
- 装了 PowerShell（Windows 自带，无需额外安装）
- 已安装并**至少启动过一次** WorkBuddy（这样缓存目录才会生成）

## 常见问题

**提示找不到缓存目录**：先启动一次 WorkBuddy 再运行工具。如果还不行，检查 `%USERPROFILE%\.workbuddy\plugins\cache\workbuddy-builtin\` 是否存在。

**注入后没生效**：确认已经完全退出 WorkBuddy（包括托盘进程）再重开，并且新建了对话，不是在旧对话里继续聊。

**改完又变回官方版**：WorkBuddy 升级会替换缓存目录，重新运行 `extract` 和 `apply` 即可。
