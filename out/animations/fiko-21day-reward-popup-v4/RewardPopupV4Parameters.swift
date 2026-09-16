import Foundation

/// V4 的统一时间采样。单位为秒、pt；图片没有独立动画轨道。
enum RewardPopupV4Parameters {
    static let duration = 1.5
    static let buttonReadyTime = 1.22
    static let hasSpring = true
    static let mass = 1.0, stiffness = 360.0, damping = 25.0
    struct Keyframe { let time: Double; let value: Double }
    static let tracks: [String: [Keyframe]] = [
        "maskOpacity": [.init(time: 0, value: 0), .init(time: 0.16, value: 0.18), .init(time: 0.76, value: 0.18), .init(time: 1.06, value: 0.5)],
        "cardOpacity": [.init(time: 0, value: 0), .init(time: 0.1, value: 1)],
        "cardScale": [.init(time: 0, value: 1)],
        "cardY": [.init(time: 0, value: 0)],
        "shellWidth": [.init(time: 0, value: 196), .init(time: 0.76, value: 196), .init(time: 1.04, value: 321)],
        "shellHeight": [.init(time: 0, value: 68), .init(time: 0.76, value: 68), .init(time: 1.14, value: 415)],
        "shellRadius": [.init(time: 0, value: 20), .init(time: 0.76, value: 20), .init(time: 1.14, value: 32)],
        "contentOpacity": [.init(time: 0, value: 0), .init(time: 0.96, value: 0), .init(time: 1.1, value: 1)],
        "toastOpacity": [.init(time: 0, value: 0), .init(time: 0.1, value: 1)],
        "headingOpacity": [.init(time: 0, value: 0)],
        "headingY": [.init(time: 0, value: 0)],
        "titleOpacity": [.init(time: 0, value: 0), .init(time: 1.06, value: 0), .init(time: 1.22, value: 1)],
        "titleY": [.init(time: 0, value: 6), .init(time: 1.06, value: 6), .init(time: 1.22, value: 0)],
        "buttonOpacity": [.init(time: 0, value: 0), .init(time: 1.12, value: 0), .init(time: 1.32, value: 1)],
        "buttonY": [.init(time: 0, value: 12), .init(time: 1.12, value: 12), .init(time: 1.32, value: -1.5), .init(time: 1.48, value: 0)],
        "buttonScale": [.init(time: 0, value: 0.97), .init(time: 1.12, value: 0.97), .init(time: 1.32, value: 1.02), .init(time: 1.48, value: 1)],
        "closeOpacity": [.init(time: 0, value: 0), .init(time: 1.02, value: 0), .init(time: 1.18, value: 1)],
        "toastY": [.init(time: 0, value: 0), .init(time: 0.76, value: 0), .init(time: 1.14, value: -163.5)],
    ]
    static func clamp(_ p: Double) -> Double { min(1, max(0, p)) }
    static func ease(_ p: Double) -> Double { 1 - pow(1 - clamp(p), 3) }
    static func easeInOut(_ progress: Double) -> Double {
        let p = clamp(progress)
        return p < 0.5 ? 4 * p * p * p : 1 - pow(-2 * p + 2, 3) / 2
    }
    static func sample(_ frames: [Keyframe], at time: Double, inOut: Bool = false) -> Double {
        guard let first = frames.first, let last = frames.last else { return 0 }
        if time <= first.time { return first.value }
        for index in 1..<frames.count {
            let a = frames[index - 1], b = frames[index]
            if time <= b.time {
                let p = (time - a.time) / (b.time - a.time)
                return a.value + (b.value - a.value) * (inOut ? easeInOut(p) : ease(p))
            }
        }
        return last.value
    }
    static func springProgress(at time: Double) -> Double {
        if time <= 0 { return 0 }; if time >= 0.52 { return 1 }
        let omega = sqrt(stiffness / mass), decay = damping / (2 * mass)
        let wd = sqrt(omega * omega - decay * decay)
        func response(_ t: Double) -> Double {
            1 - exp(-decay * t) * (cos(wd * t) + decay / wd * sin(wd * t))
        }
        return response(time) / response(0.52)
    }
    static func pose(at time: Double, reducedMotion: Bool = false) -> [String: Double] {
        let t = min(duration, max(0, time)), rendered = reducedMotion ? duration : t
        var p = Dictionary(uniqueKeysWithValues: tracks.map { key, value in
            (key, sample(value, at: rendered, inOut: hasSpring && ["shellWidth", "shellHeight", "shellRadius", "toastY"].contains(key)))
        })
        if hasSpring && !reducedMotion { p["cardY"] = 530 * (1 - springProgress(at: t)) }
        if reducedMotion { p["cardOpacity"] = clamp(t / 0.18); p["maskOpacity"] = 0.5 * clamp(t / 0.18) }
        return p
    }
}
