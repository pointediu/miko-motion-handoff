import SwiftUI

/// V2 贴纸贴合。所有时间以秒计、距离以 pt 计，角度以度计。
enum RewardPopupStickerParameters {
    static let duration = 1.5
    static let reducedMotionDuration = 0.18
    static let closeDuration = 0.16
    static let buttonReadyTime = 1.08
    static let recommendedHapticTime = 1.32
    static let size = 180.0
    static let stripCount = 60
    static let depthXFactor = 0.11
    static let prizeFrame = CGRect(x: 107.283203125, y: 345, width: 180, height: 180)
    static let particleCount = 0
    struct Keyframe { let time: Double; let value: Double }
    static let tracks: [String: [Keyframe]] = [
        "maskOpacity": [.init(time: 0, value: 0), .init(time: 0.18, value: 0.5)],
        "cardOpacity": [.init(time: 0, value: 0), .init(time: 0.2, value: 1)],
        "cardScale": [.init(time: 0, value: 0.94), .init(time: 0.26, value: 1.018), .init(time: 0.42, value: 1)],
        "cardY": [.init(time: 0, value: 18), .init(time: 0.36, value: 0)],
        "headingOpacity": [.init(time: 0, value: 0), .init(time: 0.12, value: 0), .init(time: 0.32, value: 1)],
        "titleOpacity": [.init(time: 0, value: 0), .init(time: 0.18, value: 0), .init(time: 0.4, value: 1)],
        "prizeOpacity": [.init(time: 0, value: 0), .init(time: 0.3, value: 0), .init(time: 0.45, value: 1)],
        "prizeScale": [.init(time: 0, value: 1.12), .init(time: 0.36, value: 1.12), .init(time: 0.6, value: 1)],
        "prizeY": [.init(time: 0, value: -18), .init(time: 0.36, value: -18), .init(time: 0.6, value: 0)],
        "prizeRotation": [.init(time: 0, value: -12), .init(time: 0.36, value: -12), .init(time: 0.6, value: 0)],
        "buttonOpacity": [.init(time: 0, value: 0), .init(time: 1.08, value: 0), .init(time: 1.38, value: 1)],
        "buttonY": [.init(time: 0, value: 8), .init(time: 1.08, value: 8), .init(time: 1.4, value: 0)],
        "closeOpacity": [.init(time: 0, value: 0), .init(time: 0.32, value: 0), .init(time: 0.52, value: 1)],
        "prizeX": [.init(time: 0, value: -40), .init(time: 0.36, value: -40), .init(time: 0.6, value: 0)],
        "adhesion": [.init(time: 0, value: 0), .init(time: 0.6, value: 0), .init(time: 0.72, value: 0.04), .init(time: 1.16, value: 0.84), .init(time: 1.32, value: 1)],
        "curlAngle": [.init(time: 0, value: 88), .init(time: 0.72, value: 88), .init(time: 1.16, value: 70), .init(time: 1.32, value: 0)],
        "shadowOpacity": [.init(time: 0, value: 0.22), .init(time: 0.6, value: 0.22), .init(time: 1.16, value: 0.1), .init(time: 1.32, value: 0)],
        "shadowBlur": [.init(time: 0, value: 10), .init(time: 0.6, value: 10), .init(time: 1.16, value: 3), .init(time: 1.32, value: 0)],
        "shadowY": [.init(time: 0, value: 14), .init(time: 0.6, value: 14), .init(time: 1.16, value: 4), .init(time: 1.32, value: 0)],
    ]
    static func clamp(_ p: Double) -> Double { min(1, max(0, p)) }
    static func easeOut(_ p: Double) -> Double { 1 - pow(1 - clamp(p), 3) }
    static func sample(_ frames: [Keyframe], at time: Double, linear: Bool = false) -> Double {
        guard let first = frames.first, let last = frames.last else { return 0 }
        if time <= first.time { return first.value }
        for index in 1..<frames.count {
            let a = frames[index - 1], b = frames[index]
            if time <= b.time {
                let p = clamp((time - a.time) / (b.time - a.time))
                return a.value + (b.value - a.value) * (linear ? p : easeOut(p))
            }
        }
        return last.value
    }
    static func pose(at time: Double, reducedMotion: Bool = false) -> [String: Double] {
        let t = reducedMotion ? duration : min(duration, max(0, time))
        var values = Dictionary(uniqueKeysWithValues: tracks.map { key, frames in
            (key, sample(frames, at: t, linear: key == "adhesion"))
        })
        if reducedMotion {
            let fade = clamp(time / reducedMotionDuration)
            values["cardOpacity"] = fade
            values["maskOpacity"] = 0.5 * fade
        }
        return values
    }
    struct Projection { let x: Double; let y: Double; let lift: Double }
    static func project(_ y: Double, pose p: [String: Double]) -> Projection {
        let front = size * (p["adhesion"] ?? 1)
        let angle = (p["curlAngle"] ?? 0) * Double.pi / 180
        guard y > front, angle >= 0.000001, front < size else {
            return Projection(x: 0, y: y, lift: 0)
        }
        let radius = (size - front) / angle
        let theta = (y - front) / radius
        let lift = radius * (1 - cos(theta))
        return Projection(x: lift * depthXFactor, y: front + radius * sin(theta), lift: lift)
    }
    struct Strip {
        let sourceY: Double; let sourceHeight: Double
        let x: Double; let y: Double; let height: Double; let lift: Double
    }
    static func strips(at time: Double, reducedMotion: Bool = false) -> [Strip] {
        let p = pose(at: time, reducedMotion: reducedMotion)
        let step = size / Double(stripCount)
        return (0..<stripCount).map { index in
            let y = Double(index) * step
            let a = project(y, pose: p), b = project(y + step, pose: p)
            return Strip(sourceY: y, sourceHeight: step, x: (a.x + b.x) / 2,
                         y: a.y, height: b.y - a.y, lift: (a.lift + b.lift) / 2)
        }
    }
}
