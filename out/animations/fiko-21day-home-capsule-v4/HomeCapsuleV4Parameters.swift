import SwiftUI

/// Figma 61:20694 → 61:18617. Time is seconds; distances are points.
/// Place the variable-width view in a trailing-aligned container; right edge stays fixed.
/// Sample from the current Pose when reversing to avoid a visual jump.
enum HomeCapsuleV4Parameters {
    static let expandDuration = 0.52
    static let collapseDuration = 0.36
    static let reducedDuration = 0.12
    static let initialHold = 0.6
    static let expandedHold = 2.2
    static let badgeFrame = CGRect(x: 52, y: 3, width: 79, height: 30)
    static let labelFrame = CGRect(x: 63, y: 7, width: 58, height: 22)
    static let badgeCornerRadius = 12.0
    static let badgeFill = Color(red: 228.0/255, green: 239.0/255, blue: 1).opacity(0.8)
    static let outerFill = Color.white
    static let outerStroke = Color.black.opacity(0.08)
    static let labelBlendMode: BlendMode = .multiply
    static let height = 36.0
    static let cornerRadius = 14.0
    static let rightInset = 61.0
    static let top = 54.0
    static let hitHeight = 44.0

    struct Pose {
        var countX, badgeOpacity, badgeWidth: Double
        var width, plateWidth, flameX: Double
        var countOpacity, countY, labelOpacity, labelX: Double
    }
    static func rest(expanded: Bool) -> Pose {
        Pose(countX: expanded ? 30 : 34, badgeOpacity: expanded ? 1 : 0, badgeWidth: expanded ? 79 : 0, width: expanded ? 134 : 60, plateWidth: 0,
             flameX: expanded ? 6 : 8, countOpacity: 1,
             countY: 0, labelOpacity: expanded ? 1 : 0,
             labelX: expanded ? 0 : 8)
    }
    static func clamp(_ value: Double) -> Double { min(1, max(0, value)) }
    static func ease(_ progress: Double) -> Double { 1 - pow(1 - clamp(progress), 3) }
    static func mix(_ a: Double, _ b: Double, _ p: Double) -> Double { a + (b - a) * p }
    static func sample(from: Pose, expanded: Bool, elapsed t: Double,
                       reducedMotion: Bool = false) -> Pose {
        var p = from
        let target = rest(expanded: expanded)
        if reducedMotion {
            p = target
            p.badgeOpacity = mix(from.badgeOpacity, target.badgeOpacity, clamp(t / reducedDuration))
            p.countOpacity = mix(from.countOpacity, target.countOpacity, clamp(t / reducedDuration))
            p.labelOpacity = mix(from.labelOpacity, target.labelOpacity, clamp(t / reducedDuration))
            return p
        }
        if expanded {
            let peak = 134 + 3 * clamp((134 - from.width) / 74)
            p.width = t < 0.38 ? mix(from.width, peak, ease(t / 0.38)) : mix(peak, 134, ease((t - 0.38) / 0.14))
            p.plateWidth = 0
            p.flameX = mix(from.flameX, 6, ease(t / 0.3))
            p.countX = mix(from.countX, 30, ease(t / 0.3))
            p.badgeOpacity = mix(from.badgeOpacity, 1, ease((t - 0.13) / 0.21))
            p.badgeWidth = mix(from.badgeWidth, 79, ease((t - 0.08) / 0.3))
            p.labelOpacity = mix(from.labelOpacity, 1, ease((t - 0.15) / 0.19))
            p.labelX = mix(from.labelX, 0, ease((t - 0.13) / 0.21))
        } else {
            p.width = mix(from.width, 60, ease(t / 0.36))
            p.plateWidth = 0
            p.flameX = mix(from.flameX, 8, ease(t / 0.3))
            p.labelOpacity = mix(from.labelOpacity, 0, ease(t / 0.1))
            p.labelX = mix(from.labelX, 8, ease(t / 0.12))
            p.countX = mix(from.countX, 34, ease(t / 0.3))
            p.badgeOpacity = mix(from.badgeOpacity, 0, ease(t / 0.12))
            p.badgeWidth = mix(from.badgeWidth, 0, ease(t / 0.28))
        }
        let progress = (p.width - 60) / 74
        let visible = clamp(progress)
        p.badgeWidth = 79 * progress
        p.badgeOpacity = visible
        p.labelOpacity = visible
        p.labelX = 8 * (1 - visible)
        p.countX = 34 - 4 * visible
        p.flameX = 8 - 2 * visible
        return p
    }
}
