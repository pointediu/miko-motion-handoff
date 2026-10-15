# 首练流程 SwiftUI 演示

用 Xcode 打开 MikoFirstWorkoutDemo.xcodeproj，选择 iOS 17+ 模拟器运行。

- FirstWorkoutView.swift：计划、邀请、姿势选择与首页状态；卡片展开不加入导航历史。
- FirstWorkoutMotion.swift：秒制时序参数与循环视频播放器。
- Assets.xcassets：原稿图片、文字和色值；workout-woman.mp4 为用户提供的视频。
- 接入时复制上述资源与两个实现文件，使用 FirstWorkoutView()。
- 演示按393×852画布等比缩放，头部文字与首页使用项目已有STBaoYuan-SC字体子集，保留原字形并支持逐字动画；其他文字保留原稿素材。
- 计划盖章后进入邀请页，文字完整呈现后停留900ms自动进入姿势选择。
- 三种姿势均可展开，使用同一条用户视频；末页“去试试”和“现在不方便”仅展示，无点击行为。
- 文字、说话与页面过渡复用OB2期迭代的规范；Figma原节点提供布局。选择与展开是同页状态，返回均直达指定首页。网页使用同套参数模拟，不在浏览器执行SwiftUI。
