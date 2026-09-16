import SwiftUI

/// V11 手绘闪光。所有时间以秒计、距离以 pt 计，角度以度计。
enum RewardPopupV11Parameters {
    static let duration = 1.1
    static let reducedMotionDuration = 0.18
    static let closeDuration = 0.16
    static let buttonReadyTime = 0.68
    static let recommendedHapticTime = 0.28
    static let size = 415.0
    static let width = 321.0
    static let stripCount = 160
    static let depthXFactor = 0.10
    static let cardFrame = CGRect(x: 36.5, y: 219, width: 321, height: 415)
    static let particleCount = 0
    struct Keyframe { let time: Double; let value: Double }
    static let tracks: [String: [Keyframe]] = [
        "maskOpacity": [.init(time: 0, value: 0), .init(time: 0.12, value: 0.5)],
        "cardOpacity": [.init(time: 0, value: 0), .init(time: 0.04, value: 0), .init(time: 0.15, value: 1)],
        "cardX": [.init(time: 0, value: 0)],
        "cardY": [.init(time: 0, value: 56), .init(time: 0.04, value: 56), .init(time: 0.28, value: -24), .init(time: 0.68, value: 0)],
        "cardScale": [.init(time: 0, value: 0.56), .init(time: 0.04, value: 0.56), .init(time: 0.28, value: 1.1), .init(time: 0.68, value: 1)],
        "cardRotation": [.init(time: 0, value: 0)],
        "adhesion": [.init(time: 0, value: 1)],
        "curlAngle": [.init(time: 0, value: 0)],
        "shadowOpacity": [.init(time: 0, value: 0.18), .init(time: 0.68, value: 0)],
        "shadowBlur": [.init(time: 0, value: 22), .init(time: 0.68, value: 0)],
        "shadowY": [.init(time: 0, value: 16), .init(time: 0.68, value: 0)],
        "reveal": [.init(time: 0, value: 1)],
        "lineOpacity": [.init(time: 0, value: 0)],
        "glow": [.init(time: 0, value: 0)],
        "spark": [.init(time: 0, value: 0)],
        "buttonOpacity": [.init(time: 0, value: 0), .init(time: 0.36, value: 0), .init(time: 0.62, value: 1)],
        "buttonY": [.init(time: 0, value: 10), .init(time: 0.36, value: 10), .init(time: 0.68, value: 0)],
        "buttonScale": [.init(time: 0, value: 0.98), .init(time: 0.36, value: 0.98), .init(time: 0.68, value: 1)],
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
                return a.value + (b.value - a.value) * (linear ? p : (a.time >= 0.28 && b.time <= 0.68 && frames.count == 4 ? (1 - cos(Double.pi * p)) / 2 : easeOut(p)))
            }
        }
        return last.value
    }
    static func pose(at time: Double, reducedMotion: Bool = false) -> [String: Double] {
        let t = reducedMotion ? duration : min(duration, max(0, time))
        var values = Dictionary(uniqueKeysWithValues: tracks.map { key, frames in
            (key, sample(frames, at: t, linear: key == "adhesion" || key == "reveal"))
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
