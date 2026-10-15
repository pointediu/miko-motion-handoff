import SwiftUI
import CoreText

enum HomeAddMotion {
    static let sheetIn = 0.52, sheetOut = 0.36, scrimIn = 0.28, scrimOut = 0.0
    static let recommendationOut = 0.22, cardIn = 0.52, cardStagger = 0.16
    static let buttonDelay = 0.70, buttonIn = 0.36
    static var cardEase: Animation { .timingCurve(0.22, 0.61, 0.36, 1, duration: cardIn) }
    static let characterDelay = 0.13, characterGap = 0.042, characterReveal = 0.13
    static func ease(_ duration: Double) -> Animation { .timingCurve(0.4, 0, 0.2, 1, duration: duration) }
    static let registerFont: Void = {
        if let url = Bundle.main.url(forResource: "MikoFont", withExtension: "ttf") { CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) }
    }()
}
struct HomeAddPress: ButtonStyle {
    enum Kind { case standard, icon, card }
    var kind: Kind = .standard
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var scale: CGFloat { kind == .icon ? 0.93 : kind == .card ? 0.972 : 0.965 }
    private var y: CGFloat { kind == .icon ? 1 : kind == .card ? 2 : 1.5 }
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed && !reduceMotion ? scale : 1)
            .offset(y: configuration.isPressed && !reduceMotion ? y : 0)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(configuration.isPressed ? .timingCurve(0.2, 0, 0.2, 1, duration: 0.09) : HomeAddMotion.ease(0.32), value: configuration.isPressed)
    }
}
struct HomeAction: Identifiable {
    var id: Int
    var title: String
    var duration: String
    var image: String
    static let recommendations = [HomeAction(id: 0, title: "开肩展背", duration: "30秒", image: "shoulder-open"), HomeAction(id: 1, title: "摸肩转肩", duration: "30秒", image: "shoulder-roll"), HomeAction(id: 2, title: "左右抱柴", duration: "40秒", image: "wood-chop"), HomeAction(id: 3, title: "左侧坐姿伸膝", duration: "40秒", image: "leg-kick"), HomeAction(id: 4, title: "左侧坐姿伸膝", duration: "40秒", image: "leg-kick"), HomeAction(id: 5, title: "左侧坐姿伸膝", duration: "40秒", image: "leg-kick")]
}
