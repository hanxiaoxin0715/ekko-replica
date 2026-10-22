# Ekko Lite — 灵动岛复刻（期 1）

照 Ekko Studio iOS 端的 `StudioTaskLiveActivity.appex` 复刻的实时活动实现。
纯本地更新，不需要付费开发者账号，不需要 Mac 在手边。

## 这一期做了什么

- `StudioTaskAttributes` —— 照它原来的结构复刻的 ActivityAttributes
- 灵动岛**四个区域全部自定义**（expanded / compactLeading / compactTrailing / minimal）
- 锁屏视图（进度条 + 状态胶囊 + token 用量 + 上下行流量）
- `Button(intent:)` 配 `LiveActivityIntent` —— 灵动岛上点「批准」不打开 App 直接执行
- `.keylineTint` / `.activityBackgroundTint` / `.activitySystemActionForegroundColor` 配色
- `context.isStale` → 显示「进度暂未同步」
- GitHub Actions 云端编译出未签名 ipa

## 目录结构

```
ekko-replica/
├── project.yml                       XcodeGen 工程定义
├── Shared/
│   ├── StudioTaskAttributes.swift    App 和扩展共用（不用 App Group）
│   └── AppConfig.swift               服务端地址配置
├── App/
│   ├── EkkoLiteApp.swift
│   ├── ContentView.swift             操作面板
│   └── LiveActivityManager.swift     启动 / 更新 / 结束
├── Widget/
│   ├── StudioTaskWidgetBundle.swift
│   ├── StudioTaskLiveActivity.swift  灵动岛 + 锁屏视图
│   └── ApproveTaskIntent.swift       灵动岛按钮的 Intent
└── .github/workflows/build.yml       云端编译
```

---

# 怎么装到自己手机上

## 第 1 步：推到 GitHub

在 GitHub 建一个**公开**仓库（私有仓库 Actions 有分钟数限制，公开免费无限），然后：

```bash
cd "C:\Users\Administrator\WorkBuddy AI\2026-10-22-02-57-06\ekko-replica"
git init
git add .
git commit -m "init: Ekko Lite 灵动岛复刻"
git branch -M main
git remote add origin https://github.com/你的用户名/ekko-replica.git
git push -u origin main
```

推上去后会自动触发 Actions。也可以在仓库页面 `Actions` → `Build unsigned IPA` → `Run workflow` 手动跑。

## 第 2 步：下载编译好的 ipa

Actions 跑完（约 3-5 分钟）→ 点进那次运行 → 页面底部 `Artifacts` → 下载 `EkkoLite-unsigned-ipa.zip` → 解压得到 `EkkoLite-unsigned.ipa`。

## 第 3 步：Windows 上签名并安装

1. 装 **iTunes**（Apple 官网版或 Microsoft Store 版都行，主要是要它的 Apple 设备驱动）
2. 下载 **Sideloadly**（sideloadly.io），装好
3. 数据线连 iPhone，手机上点「信任」
4. 把 `EkkoLite-unsigned.ipa` 拖进 Sideloadly 窗口
5. `Apple ID` 填你自己的 Apple ID（免费账号即可）
6. 点 `Start`，会让你输密码 + 双重验证码
7. 等它签完并安装

## 第 4 步：手机上信任证书

装完直接点图标会提示「不受信任的开发者」，必须先做两步：

1. **设置 → 通用 → VPN与设备管理 → 开发者 APP** → 点你的 Apple ID → **信任**
2. **设置 → 隐私与安全性 → 开发者模式** → 打开 → **重启手机**（iOS 16+ 必须开，很多人卡在这一步）

重启后就能正常打开 Ekko Lite 了。

## 第 5 步：打开实时活动开关

`设置 → Ekko Lite → 实时活动` 确认是开的，然后回 App 点「启动实时活动」，退到桌面看灵动岛。

---

# 需要注意的

| 项 | 说明 |
|---|---|
| **7 天过期** | 免费签名 7 天后打不开，用 Sideloadly 重签一次即可，App 内数据不丢 |
| **最多 3 个** | 免费账号同时只能装 3 个自签 App |
| **bundleId 会被改** | Sideloadly 会自动加随机后缀避免冲突，这是正常的 |
| **远程推送不行** | Ekko 那套 `remote_start` + APNs 需要付费开发者账号（$99/年）。本地更新不受影响 |
| **不能跨设备分享** | 只签了你自己的设备，别人装不了 |

# 改配置

`Shared/AppConfig.swift`：

```swift
static let serverBaseURL = "http://192.168.1.10:8648"   // 你的 Ekko 服务端地址
static let approvePath = "/api/demo/approve"            // 批准按钮请求的路径
```

App 和 Widget 扩展都编译这个文件，所以改一处两边生效，不需要 App Group。

# 下一期

| 期 | 内容 |
|---|---|
| 期 2 | 会话列表 + 聊天流（Markdown / 代码高亮 / 流式输出） |
| 期 3 | 模型与 Profile 配置、会话管理 |
| 期 4 | 终端、MCP、技能、工作流画布 |

服务端不用自己写：`EKKOLearnAI/hermes-studio` 是开源的，
`npm i -g ekko-studio && ekko-studio web start` 或 Docker 一条命令就有完整后端。
