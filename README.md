# workbuddy-break

针对 **WorkBuddy** 的渗透测试 / 破甲（Jailbreak）系统提示词工具。

A red-team system prompt tool for WorkBuddy — jailbreak / armor-piercing research artifact.

## 简介

本仓库是一套用于 WorkBuddy 的自定义系统提示词与一键注入脚本，用于 AI 安全研究与红队评估。使 Agent 在渗透测试等敏感场景中不触发拒绝行为。

## 特色

- 一键注入，双击即用，无需手动查找或修改任何文件
- 自动备份原版提示词，随时可一键还原
- 支持所有版本目录，WorkBuddy 升级后重新注入即可
- 预设提示词放在 `presets\prompt.tpl`，可直接修改成自己的版本

## 使用

### Windows

下载本项目全部文件到同一文件夹，双击 `run.bat`，选择 `[1] One-click inject preset prompt`。

完成后**完全退出 WorkBuddy**，重新打开并**新建一个对话**即可生效。

如需还原，双击 `run.bat` 选择 `[4] Restore official`。

> 如果 PowerShell 提示禁止运行脚本，`run.bat` 已自动处理，无需额外操作。

## 免责声明

本项目仅用于**授权环境**下的 AI 安全研究、红队评估与提示工程教学。请勿将其用于任何违反服务条款或法律法规的实际操作。使用者自行承担一切后果。
