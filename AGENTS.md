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
- `python3 build-web.py` 从当前离线版生成 `out/`，保留全部 33 个动效、导航和参数面板。仅将内嵌预览改成同源 iframe 页面、将 base64 素材提取为去重文件；调试参数仍通过查询参数和 postMessage 同步。
- `.openai/hosting.json` 的 static.directory 为 `out`。`out/` 是完整、可直接发布且受 Git 管理的静态源文件，不依赖构建工具运行；后续本地修改后先重新生成 out，再提交发布。

## GitHub Pages 发布

- 用户要求创建 `pointediu/miko-motion-handoff` 并配置 push 后自动上线。`.github/workflows/pages.yml` 将 main 分支的 out/ 发布至 GitHub Pages。
- build-web.py 的资源路径现为相对路径，兼容 Pages 的仓库子目录及原 Sites 根目录。
- GitHub 是后续主要发布目标；保留 Sites 已发布页面，除非用户要求同步，不自动更新 Sites。

## 领奖弹窗 V5 整张贴纸

- 用户要求整张弹窗像贴纸一样出现；新增 `fiko-21day-reward-popup-v5`，保留 V1–V4。
- 源文件 `work/reward37-v5/build.py`、`renderer.js`、`parameters.json`；从工作区根目录运行 build.py，再运行项目 build-web.py。
- 整张弹窗以同一张纹理卷曲：480ms 上缘接触，620–1380ms 贴平；1380ms 切回原稿真实按钮，1500ms 结束。总共 160 条带，无独立内容动画和彩纸。
- Swift 参数提供同源轨道、pose 与 strips / project；减少动态效果时 180ms 淡入终态。
- 后续发布到已配置的 GitHub Pages。

## 最新约定：先本地评审

- 用户已明确要求：只改本地、预览满意后再 push；没有新的发布指令不得提交推送或更新线上。
- 用户确认本轮只做列出的三版：V6 打印揭晓、V7 弹出礼花、V8 贴纸揭晓。整张弹窗合成一次静态位图，文字、奖品和按钮均无独立动画。
- 源文件 `work/reward37-v6v8/`；运行其 build.py 同步离线版，再运行本项目 build-web.py 同步本地轻量预览。
- 本地预览：python3 -m http.server 8765 --bind 127.0.0.1 --directory out；仅服务本机。

## 首页右上角胶囊

- 两态原型 `61:20694` / `61:22778`；新条目 `fiko-21day-home-capsule` 位于 21天活动。
- 源文件 `work/capsule61/`；build.py 同步 HTML、JSON、Swift 参数及列表，之后运行 build-web.py。
- 胶囊固定右边缘 x 332pt、顶部 y 54pt；宽 60→116→113pt，展开 520ms、收起 360ms。头像保持 x 340 / y 54。
- 首次演示：600ms 未展开、520ms 展开、2200ms 停留、360ms 收起；点击中断演示并从当前 pose 反向。
- 背景与素材为 Figma 导出；布局来自原稿，时序为新设计。只改本地，不提交推送。

## 胶囊展开态对比（62 页）

- 新增 `fiko-21day-home-capsule-v2`（用户方案一：62:28991，109pt 分体胶囊）及 `fiko-21day-home-capsule-v3`（用户方案二：62:24853，103pt 一体浅蓝胶囊）。原胶囊保留。
- 源文件 `work/capsule62/build.py` 复用 `work/capsule61/` 的时序模板，导出独立页、嵌入页、JSON 和 Swift 参数。
- 方案一文字 x42，左侧 36pt 白色底座；方案二文字 x35，无独立底座，整体黑色 8% 描边。两版火苗使用各自原稿素材。
- skin 在 220ms 内控制火苗交叉淡入；一体版底座 opacity=1-skin。宽度均多展开 3pt 后归位，520ms 展开，360ms 收起。
- 仍只保存在本地，待用户明确要求才发布。

- 胶囊颜色已按最新 Figma 修正：两版展开填充 #F1F7FF、1pt 黑色 8% 描边；分体版白色底座及火苗图层白色填充；一体版不再向白色边框渐变。

## 胶囊方案三：保留天数

- 展开态 61:18617 / 61:20685，新条目 `fiko-21day-home-capsule-v4`，界面名称「方案三 · 保留天数」。
- 来源 `work/capsule-retain-count/build.py`；60→137→134pt，展开520ms、收起360ms；火苗与27全程保留。
- 白色外壳、黑色8%描边；右侧浅蓝内嵌底 x52/y3/79×30/r12，颜色 rgba(228,239,255,.8)，标题x63/y7/58×22。
- 仅本地，保留其他版本；Swift参数与JSON同步。

## 领奖弹窗 V9 / V10

- 新增 V9「轻弹 · 蓝光白星」、V10「盖章 · 蓝光白星」，源文件 work/reward37-v9v10/。保留旧方案，只更新本地。
- 两版均 800ms 落定，之后同一套淡蓝光晕与 8 颗白星显现，2000ms 开始收尾，2800ms 全部消失；无矩形描边，无礼花。
- V9 整图缩放 0.56→1.075→0.985→1，放慢并稍增幅；V10 整图 1.18 倍、上移65pt、−5° 接近，460ms 压到0.975倍后微回弹贴稳。
- 当前只修改本地文件；没有发布指令时不提交或 push。

- V9/V10 最新修改：查看奖品按钮从合成图片中排除，独立 DOM 图层于1200–1680ms淡入、Y16→−2→0、scale0.94→1.025→1。cardSettledMs=800 与 buttonReadyMs=1680 分离，避免延迟整图落定。蓝光/白星峰值0.75、10颗白星，无描边。减少动态效果下180ms直接呈现全部终态。仅本地。

## 用户删除条目

- 已从本地列表、内嵌页、独立预览和参数目录移除：fiko-21day-home-capsule（展开与收起）、fiko-21day-home-capsule-v3（方案二）、fiko-21day-reward-popup-v3、fiko-21day-reward-popup-v6。
- 其他版本保持原编号；工作区历史源文件保留用于追溯，后续不得重新加入上述删除条目。V6–V8 构建器仅生成 V7/V8。只改本地，不 push。

- 用户追加删除领奖弹窗 V5 / V7：已移除本地条目与预览参数目录；保留其他版本。V5 Swift 基础模板迁至 work/reward37-v5/parameters-template.swift，后续 V8/V9/V10 构建不依赖已删除交付目录。仅本地，不 push。

## 待确认动效命名

- 用户确认按「模块 · 效果特点」命名，去掉界面上的 V 编号与方案编号。8 个待确认条目的正式展示名保存在 catalog-names.json。
- build-web.py 先运行 normalize-catalog.py，同步离线列表、嵌入预览、独立页标题、README 和增量 insertion 记录，避免后续动效构建恢复旧名。内部 id、路径与 Swift 类型保留以免破坏引用。
- 首页胶囊：分体展开、保留天数；领奖弹窗：奖品轻弹礼花、奖品贴纸贴合、短条弹跳展开、贴纸揭晓、轻弹星光、盖章星光。仅本地，未推送。

## 领奖弹窗 · 手绘闪光

- 新增 fiko-21day-reward-popup-v11，来源 work/reward37-v11/，参考用户指定 Dribbble 27222091。沿用轻弹星光的入场与按钮节奏。
- 800ms 后描出4个不规则开放圆环和8条短射线；白色圆头线配蓝紫微光，各笔画错开28ms、260ms画完，外移最多5pt，2800ms全部淡出。无矩形描边或实心星星。
- handDrawn JSON提供参数，renderer.js提供固定路径与按弧长描线；仅本地，不 push。
