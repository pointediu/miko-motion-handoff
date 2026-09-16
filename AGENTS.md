# 动效交付页面维护

用户最新要求：严格按其提供的 `animation-handoff-standalone.html` 一比一复刻，多余功能删除。

- 当前网站为 `dist/index.html`，以用户原 HTML 为基底，包含全部内嵌页面与素材。2026-09-15 经用户明确要求，追加「21天活动 → 领奖弹窗」（id: fiko-21day-reward-popup）；原界面与 28 个示例未改。
- 当前交付严格保留原 HTML 的布局、样式、文案、分组、动画、调试控件和行为。未经后续明确要求，不新增主题/版本管理、搜索筛选、Codex 面板、文件下载区或其他功能。
- 不再使用先前的 library.json、library-ui.js 或 sync-library.cjs 流程；它们已从当前交付目录移出并保存在工作区备份。
- 先前生成的奖励弹窗 v1–v5 工程仍保存在 outputs 的各自项目目录中。本网站只显示原文件包含的内容。
- 后续如需改动，基于此单文件维护。若仅要求复制原版，完成后验证文件哈希一致即可，不改原文件。
- 当前继续本地交付，不自动部署。明确要求发布时再执行部署。
- 用户要求后续直接更新当前本地页面；仅在用户明确要求时再生成或更新交付压缩包。

## 新增领奖弹窗

- 原型节点 `37:28417`。独立文件位于 `dist/animations/fiko-21day-reward-popup/index.html`，同目录有参数 JSON、Swift 参数与 README。
- 单文件主入口在原 animations 数组后追加 `standalonePreviews["fiko-21day-reward-popup"] = ...` 和 `animations.push(...)`；activity21 的 animationIds 追加对应 id。更新此动效时同步独立预览、内嵌预览和参数。
- 总时长 1500ms、彩纸12片。现有页面右侧渲染新条目自带的 sections/spec，无需增加功能面板。
- 原 HTML 的基线 SHA-256：2a570139093328849af8c70bd1a1ba4370b519db0b106c074ba6f2344232f734。移除新增脚本片段及导航id后应恢复该哈希。

## 领奖弹窗 V2 贴纸贴合

- 用户已确认第一版视觉，第一版目录与内嵌内容保持不变。
- 第二版 id 为 `fiko-21day-reward-popup-v2`，在「21天活动」中与第一版并列。保留前段弹窗入场，奖品改为倾斜靠近、上缘接触、从上往下贴合，0 片彩纸，1500ms 停止。
- 源文件位于 `work/reward37-v2/`。`parameters.json` 为 V2 轨道源，`motion-template.js` 负责卷曲采样，`build.py` 同步独立页和主入口，`insertion.txt` 保存新增脚本片段。
- SwiftUI 文件及关键帧图在对应 dist/animations 目录；Swift Canvas 内部分条裁剪关闭抗锯齿，避免切片接缝。Web 实际画面仍需用户确认。
- 验证第一版及原宿主内容未改变时，从主入口移除 V2 insertion.txt 与导航 id 后，应匹配 `work/reward37-v2/baseline-hashes.json`。

## 领奖弹窗 V3 / V4

- 用户要求再新增两版，保留 V1 / V2：`fiko-21day-reward-popup-v3`（淡入缩放）、`fiko-21day-reward-popup-v4`（弹跳展开）。都位于「21天活动」。
- 新两版图片没有独立动画，只随父容器显现。V3 完整弹窗 fade + scale，文字与按钮错开；V4 白色短条物理弹簧上冲回落，然后展开到原稿尺寸。V4 参考 60fps 的 Duolingo copy link toast，上冲回落来自参考，展开方案为新设计。
- 源文件位于 `work/reward37-v3v4/`，参数 JSON、motion-template.js 和 parameters-template.swift 由 build.py 同步至两版独立页、内嵌页和 Swift 参数。总时长均 1500ms。
- 各版的 insertion.txt 保存新增主入口片段。验证旧版保留时，从主入口移除 V3 / V4 片段及导航 id，再对照该工作目录的 baseline-hashes.json。
- 原生关键帧图由 SwiftUI 离屏逐帧渲染，用于核对时序和布局；不是实际浏览器截图。当前只改本地页面，不生成新压缩包。
- 2026-09-16：V4 开场改为 196 × 68pt、圆角 20pt，760ms 开始展开；达标文案通过 toastY 连续移至原稿位置，原 heading 图层隐藏。按钮 1120–1480ms 淡入轻抬并单次小幅回落。只更新 V4 时使用 `python3 work/reward37-v3v4/build.py 4`，避免重写 V3。

## 线上发布

- 2026-09-16 用户明确要求部署，访问范围为有链接的人都能查看。复用现有 Sites project_id。
- `dist/` 继续作为本机离线单文件版本；该目录不进入发布源仓库。
- `python3 build-web.py` 从当前离线版生成 `out/`，保留全部 32 个动效、导航和参数面板。仅将内嵌预览改成同源 iframe 页面、将 base64 素材提取为去重文件；调试参数仍通过查询参数和 postMessage 同步。
- `.openai/hosting.json` 的 static.directory 为 `out`。`out/` 是完整、可直接发布且受 Git 管理的静态源文件，不依赖构建工具运行；后续本地修改后先重新生成 out，再提交发布。
