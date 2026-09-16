import SwiftUI

/// 21 天活动 · 领奖弹窗。时间单位为秒，距离单位为 pt。
/// 对应 Figma 37:28417。仅参数和采样函数，不含业务导航或完整 View。
enum RewardPopupParameters {
    static let duration: Double = 1.5
    static let reducedMotionDuration: Double = 0.18
    static let closeDuration: Double = 0.16
    static let recommendedHapticTime: Double = 0.48
    static let canvasSize = CGSize(width: 393, height: 852)
    static let cardFrame = CGRect(x: 36.5, y: 219, width: 321, height: 415)
    static let cardCornerRadius: CGFloat = 32
    static let prizeFrame = CGRect(x: 107.283203125, y: 345, width: 180, height: 180)
    static let buttonFrame = CGRect(x: 88, y: 554, width: 220, height: 60)
    static let particleCount = 12

    struct Keyframe { let time: Double; let value: Double }
    static let tracks: [String: [Keyframe]] = [
        "maskOpacity": [.init(time: 0, value: 0), .init(time: 0.18, value: 0.5)],
        "cardOpacity": [.init(time: 0, value: 0), .init(time: 0.2, value: 1)],
        "cardScale": [.init(time: 0, value: 0.94), .init(time: 0.26, value: 1.018), .init(time: 0.42, value: 1)],
        "cardY": [.init(time: 0, value: 18), .init(time: 0.36, value: 0)],
        "headingOpacity": [.init(time: 0, value: 0), .init(time: 0.12, value: 0), .init(time: 0.32, value: 1)],
        "titleOpacity": [.init(time: 0, value: 0), .init(time: 0.18, value: 0), .init(time: 0.4, value: 1)],
        "prizeOpacity": [.init(time: 0, value: 0), .init(time: 0.18, value: 0), .init(time: 0.3, value: 1)],
        "prizeScale": [.init(time: 0, value: 0.56), .init(time: 0.18, value: 0.56), .init(time: 0.48, value: 1.1), .init(time: 0.65, value: 0.985), .init(time: 0.8, value: 1)],
        "prizeY": [.init(time: 0, value: 16), .init(time: 0.18, value: 16), .init(time: 0.48, value: -7), .init(time: 0.78, value: 0)],
        "prizeRotation": [.init(time: 0, value: -8), .init(time: 0.18, value: -8), .init(time: 0.48, value: 2.5), .init(time: 0.76, value: 0)],
        "buttonOpacity": [.init(time: 0, value: 0), .init(time: 0.5, value: 0), .init(time: 0.78, value: 1)],
        "buttonY": [.init(time: 0, value: 8), .init(time: 0.5, value: 8), .init(time: 0.8, value: 0)],
        "closeOpacity": [.init(time: 0, value: 0), .init(time: 0.32, value: 0), .init(time: 0.52, value: 1)],
    ]
    static func clamp(_ p: Double) -> Double { min(1, max(0, p)) }
    static func easeOut(_ p: Double) -> Double { 1 - pow(1 - clamp(p), 3) }
    static func animation(duration: Double) -> Animation {
        .timingCurve(1.0 / 3, 1, 2.0 / 3, 1, duration: duration)
    }
    static func sample(_ frames: [Keyframe], at time: Double) -> Double {
        guard let first = frames.first, let last = frames.last else { return 0 }
        if time <= first.time { return first.value }
        for index in 1..<frames.count {
            let a = frames[index - 1], b = frames[index]
            if time <= b.time {
                let progress = easeOut((time - a.time) / (b.time - a.time))
                return a.value + (b.value - a.value) * progress
            }
        }
        return last.value
    }
    /// TimelineView 的 elapsed 秒数；后台暂停时不要累加时间。
    static func pose(at time: Double, reducedMotion: Bool = false) -> [String: Double] {
        var values = tracks.mapValues { sample($0, at: reducedMotion ? duration : time) }
        if reducedMotion {
            let fade = clamp(time / reducedMotionDuration)
            values["cardOpacity"] = fade
            values["maskOpacity"] = 0.5 * fade
        }
        return values
    }
    struct Particle {
        let center: CGPoint
        let width: CGFloat
        let height: CGFloat
        let rotationDegrees: Double
        let scaleX: CGFloat
        let opacity: Double
        /// 按 colors 数组顺序读取对应品牌颜色。
        let colorIndex: Int
    }
    static let colors = ["#9EC6FF", "#BBD9FF", "#F4DDA7", "#F5CBC1"]
    /// Canvas 内绘制 12 个小矩形；以统一 elapsed 驱动，1.5 秒后返回空数组。
    static func particles(at time: Double, reducedMotion: Bool = false) -> [Particle] {
        guard !reducedMotion else { return [] }
        return (0..<particleCount).compactMap { index in
            let progress = (time - 0.36 - Double(index % 3) * 0.03) / 1.08
            guard progress > 0, progress < 1 else { return nil }
            let angle = (Double(index) * 137.508 - 115) * Double.pi / 180
            let radius = 38 + easeOut(progress) * (88 + Double(index % 4) * 19)
            let x = 197.283203125 + cos(angle) * radius
            let y = 435 + sin(angle) * radius + 70 * progress * progress
            let fade = clamp(progress / 0.08) * (1 - clamp((progress - 0.62) / 0.38))
            return Particle(center: CGPoint(x: x, y: y),
                            width: CGFloat(4 + Double(index % 3) * 1.2),
                            height: CGFloat(7 + Double(index % 3) * 1.5),
                            rotationDegrees: Double(index * 29) + (index % 2 == 0 ? 1 : -1) * 210 * progress,
                            scaleX: CGFloat(0.55 + 0.45 * abs(cos(progress * Double.pi * 2))),
                            opacity: fade, colorIndex: index % colors.count)
        }
    }
}
