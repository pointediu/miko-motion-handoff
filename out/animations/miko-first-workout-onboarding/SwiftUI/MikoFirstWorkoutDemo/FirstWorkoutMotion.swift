import SwiftUI
import AVFoundation
import CoreText

/// Durations in seconds; the website's matching JSON uses milliseconds.
enum FirstWorkoutMotion {
    static let invitationHold = 0.9
    static let cardDuration = 0.52
    static let pageDuration = 0.68
    static let exitDuration = 0.24
    static let sharedCatDuration = 0.76
    static let stampContact = 0.22
    static let guideDelay = 0.13
    static let guideGap = 0.042
    static let mouthPeriod = 0.19
    static let introDelay = 0.65
    static let introGap = 0.082
    static let subtitleGap = 0.072
    static let linePause = 0.22
    static let lines = [["计划出炉～", "敢不敢和我做个约定！"], ["现在，和Miko轻轻动 1分钟", "找找感觉吧！"], ["选择当下就能练的姿势吧", "随时随地轻轻开始~"]]
    static func characterTime(_ page: Int, _ line: Int, _ index: Int) -> Double {
        if page == 1 { return line == 0 ? introDelay + Double(index) * introGap : introDelay + Double(lines[1][0].count) * introGap + linePause + Double(index) * subtitleGap }
        return guideDelay + Double((line == 0 ? 0 : lines[page][0].count + 1) + index) * guideGap
    }
    static func copyDuration(_ page: Int) -> Double {
        characterTime(page, 1, lines[page][1].count) + (page == 1 ? 0.22 : 0.13)
    }
    static func ease(_ seconds: Double) -> Animation {
        .timingCurve(0.4, 0, 0.2, 1, duration: seconds)
    }
}

enum WorkoutPosture: String, CaseIterable, Identifiable {
    case standing, sitting, lying
    var id: String { rawValue }
    var title: String { switch self { case .standing: "我正站着"; case .sitting: "我正坐着"; case .lying: "我正躺着" } }
    var titleAsset: String { switch self { case .standing: "text-1489-189965"; case .sitting: "text-1489-189971"; case .lying: "text-1489-189977" } }
    var subtitleAsset: String { switch self { case .standing: "text-1489-189966"; case .sitting: "text-1489-189972"; case .lying: "text-1489-189978" } }
    var iconAsset: String { switch self { case .standing: "imgArmSwingAround1"; case .sitting: "imgSeatedForwardBend1"; case .lying: "imgGluteBridge1" } }
    var compactAsset: String { switch self { case .standing: "text-1489-189966"; case .sitting: "text-1540-183147"; case .lying: "text-1540-183151" } }
}

@MainActor final class WorkoutVideo: ObservableObject {
    let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?
    init(bundle: Bundle = .main) {
        if let url = bundle.url(forResource: "workout-woman", withExtension: "mp4") {
            looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        }
        player.isMuted = true
    }
    func play() { player.play() }
    func pause() { player.pause() }
    func reset() { player.pause(); player.seek(to: .zero) }
}

/// Register once so embedding FirstWorkoutView also preserves the design font.
enum FirstWorkoutTypography {
    static let ready: Void = {
        if let url = Bundle.main.url(forResource: "MikoFont", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }()
}
