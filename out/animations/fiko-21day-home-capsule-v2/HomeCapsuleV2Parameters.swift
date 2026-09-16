import SwiftUI

/// Figma 61:20694 → 62:28991. Time is seconds; distances are points.
/// Place the variable-width view in a trailing-aligned container; right edge stays fixed.
/// Sample from the current Pose when reversing to avoid a visual jump.
enum HomeCapsuleV2Parameters {
    static let expandDuration = 0.52
    static let collapseDuration = 0.36
    static let reducedDuration = 0.12
    static let initialHold = 0.6
    static let expandedHold = 2.2
    static let expandedLabelX = 42.0
    static let hasSeparatePlate = true
    static let expandedFill = Color(red: 241.0/255, green: 247.0/255, blue: 1)
    static let borderColor = Color.black.opacity(0.08)
    static let borderWidth = 1.0
    static let height = 36.0
    static let cornerRadius = 14.0
    static let rightInset = 61.0
    static let top = 54.0
    static let hitHeight = 44.0

    struct Pose {
        var skin: Double
        var width, plateWidth, flameX: Double
        var countOpacity, countY, labelOpacity, labelX: Double
    }
    static func rest(expanded: Bool) -> Pose {
        Pose(skin: expanded ? 1 : 0, width: expanded ? 109 : 60, plateWidth: expanded ? 36 : 60,
             flameX: expanded ? 6 : 8, countOpacity: expanded ? 0 : 1,
             countY: expanded ? -4 : 0, labelOpacity: expanded ? 1 : 0,
             labelX: expanded ? 0 : 8)
    }
    static func clamp(_ value: Double) -> Double { min(1, max(0, value)) }
    static func ease(_ progress: Double) -> Double { 1 - pow(1 - clamp(progress), 3) }
    static func mix(_ a: Double, _ b: Double, _ p: Double) -> Double { a + (b - a) * p }
    static func sample(from: Pose, expanded: Bool, elapsed t: Double,
                       reducedMotion: Bool = false) -> Pose {
        var p = from
        let target = rest(expanded: expanded)
        p.skin = mix(from.skin, target.skin, ease(t / 0.22))
        if reducedMotion {
            p = target
            p.countOpacity = mix(from.countOpacity, target.countOpacity, clamp(t / reducedDuration))
            p.labelOpacity = mix(from.labelOpacity, target.labelOpacity, clamp(t / reducedDuration))
            return p
        }
        if expanded {
            let peak = 109 + 3 * clamp((109 - from.width) / 49)
            p.width = t < 0.38 ? mix(from.width, peak, ease(t / 0.38)) : mix(peak, 109, ease((t - 0.38) / 0.14))
            p.plateWidth = mix(from.plateWidth, 36, ease(t / 0.3))
            p.flameX = mix(from.flameX, 6, ease(t / 0.3))
            p.countOpacity = mix(from.countOpacity, 0, ease(t / 0.1))
            p.countY = mix(from.countY, -4, ease(t / 0.12))
            p.labelOpacity = mix(from.labelOpacity, 1, ease((t - 0.15) / 0.19))
            p.labelX = mix(from.labelX, 0, ease((t - 0.13) / 0.21))
        } else {
            p.width = mix(from.width, 60, ease(t / 0.36))
            p.plateWidth = mix(from.plateWidth, 60, ease(t / 0.3))
            p.flameX = mix(from.flameX, 8, ease(t / 0.3))
            p.labelOpacity = mix(from.labelOpacity, 0, ease(t / 0.1))
            p.labelX = mix(from.labelX, 8, ease(t / 0.12))
            p.countOpacity = mix(from.countOpacity, 1, ease((t - 0.16) / 0.16))
            p.countY = mix(from.countY, 0, ease((t - 0.14) / 0.18))
        }
        return p
    }
}
