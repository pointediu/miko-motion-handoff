import SwiftUI
import AVFoundation
import UIKit

/// Interactive design demo. The artwork scales together from its 393 × 852pt
/// design canvas. Navigation and content are state-driven; no account data changes.
struct FirstWorkoutView: View {
    enum Screen: Int, CaseIterable { case plan, invitation, selection, home }
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var video = WorkoutVideo()
    @State private var screen = Screen.plan
    @State private var selected: WorkoutPosture?
    @State private var expanded = false
    @State private var busy = false
    @State private var stampY: CGFloat = 0
    @State private var stampOpacity = 1.0
    @State private var markOpacity = 0.5
    @State private var paperY: CGFloat = 0
    @State private var sequence: Task<Void, Never>?
    @State private var resumeVideo = false
    init() {
        _ = FirstWorkoutTypography.ready
    }

    @State private var pageOpacity = 1.0
    @State private var pageY: CGFloat = 0
    @State private var headerElapsed = 0.0
    @State private var speaking = false
    @State private var catX: CGFloat = 18.4
    @State private var catY: CGFloat = 130.6
    @State private var catScaleX: CGFloat = 1
    @State private var catScaleY: CGFloat = 1
    @State private var catOpacity = 1.0
    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / 393, proxy.size.height / 852)
            ZStack(alignment: .topLeading) {
                background
                Group {
                    switch screen {
                    case .plan: plan
                    case .invitation: invitation
                    case .selection: selection
                    case .home: homePage
                    }
                }.opacity(pageOpacity).offset(y: pageY)
                TalkingCat(speaking: speaking && scenePhase == .active && !reduceMotion)
                    .frame(width: 78, height: 57)
                    .scaleEffect(x: catScaleX, y: catScaleY, anchor: .topLeading)
                    .opacity(catOpacity).offset(x: catX, y: catY).allowsHitTesting(false)
                if screen != .invitation && screen != .home {
                Button(action: back) {
                    Image("imgArrowBack").resizable().frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                        .background(Color("MikoBG0"), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.black.opacity(0.05)))
                }.buttonStyle(OBPressStyle(kind: .icon)).accessibilityLabel(screen == .selection ? "返回首页" : "返回上一步").offset(x: 16, y: 58)
                }
            }
            .frame(width: 393, height: 852, alignment: .topLeading)
            .clipped()
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: 393 * scale, height: 852 * scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .background(Color("MikoSurface"))
        .preferredColorScheme(.light)
        .task { replay() }
        .onDisappear { sequence?.cancel(); video.pause() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { if resumeVideo && expanded && !reduceMotion { video.play() } }
            else { resumeVideo = video.player.rate > 0; video.pause() }
        }
        .onChange(of: reduceMotion) { _, _ in video.pause(); speaking = false }

    }
    private func art(_ name: String, _ width: CGFloat, _ height: CGFloat, label: String = "") -> some View {
        Image(name).resizable().frame(width: width, height: height)
            .accessibilityLabel(label).accessibilityHidden(label.isEmpty)
    }
    private var background: some View {
        ZStack {
            Color("MikoSurface")
            if screen == .plan {
                art("imgImage1525", 602, 852).opacity(0.2)
            } else {
                Canvas { context, _ in
                    let dot = context.resolve(Image("imgEllipse3536"))
                    for row in 0..<64 { for col in 0..<29 {
                        context.draw(dot, in: CGRect(x: CGFloat(-7 + col * 15), y: CGFloat(-40 + row * 15), width: 2, height: 2))
                    } }
                }
            }
            if screen != .home { LinearGradient(colors: [Color("MikoSurface"), Color("MikoSurface").opacity(0.13)], startPoint: .top, endPoint: .bottom) }
        }.frame(width: 393, height: 852).clipped().allowsHitTesting(false)
    }
    private var plan: some View {
        ZStack(alignment: .topLeading) {
            OBTypedHeading(page: 0, elapsed: headerElapsed).offset(x: 111, y: 133)
            ZStack(alignment: .topLeading) {
                art("imgAdobeStock3572876411", 349.08, 547).offset(y: 2)
                art("text-1433-37977", 287, 160, label: "阿蛋的运动计划，每天5分钟，在家练一练").offset(x: 32, y: 35)
                VStack(spacing: 0) {
                    planRow("text-1433-37951").rotationEffect(.degrees(-1))
                    planRow("text-1433-37959").opacity(0.8).rotationEffect(.degrees(1.35))
                    planRow("text-1433-37967").opacity(0.5).rotationEffect(.degrees(-0.67))
                }.offset(x: 34, y: 217)
            }.frame(width: 350, height: 550).offset(x: 22, y: 196 + paperY)
            art("imgMoreHorizontal", 20, 20).offset(x: 187, y: 639)
            art("imgImage1661", 105.505, 83.152, label: "我一定会做到的").opacity(markOpacity).offset(x: 142.954, y: 595.576)
            Button(action: startStamp) {
                art("img1040G3G832375E9E2Ms06I2Lh519Egs99Ejlgii01", 185.654, 214.967)
            }.buttonStyle(OBPressStyle(kind: .cat)).disabled(busy).accessibilityLabel("盖个章，确认计划")
                .opacity(stampOpacity).offset(x: 104, y: 669 + stampY)
        }.frame(width: 393, height: 852, alignment: .topLeading)
    }
    private func planRow(_ title: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                art(title, 123, 23)
                art("text-1433-37953", 129, 21)
            }
            Spacer()
            art("img161", 48, 48)
        }.padding(.leading, 16).padding(.trailing, 12)
            .frame(width: 280, height: 82)
            .background(Color("MikoSurface"), in: RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color("MikoBorder"), lineWidth: 0.5))
    }
    private var invitation: some View {
        OBTypedHeading(page: 1, elapsed: headerElapsed)
            .frame(width: 281, height: 64).offset(x: 56.5, y: 308)
            .frame(width: 393, height: 852, alignment: .topLeading)
    }
    private var selection: some View {
        ZStack(alignment: .topLeading) {
            OBTypedHeading(page: 2, elapsed: headerElapsed).offset(x: 108.4, y: 122.1)
            VStack(spacing: 10) {
                ForEach(WorkoutPosture.allCases) { posture in postureCard(posture) }
            }.frame(width: 280).offset(x: 57, y: expanded ? 226 : 269)
            art("text-1540-183126", 60, 28, label: "去试试")
                .frame(width: 329, height: 60)
                .background(selected == nil ? Color("MikoDisabled") : .black, in: RoundedRectangle(cornerRadius: 26))
                .offset(x: 32, y: 708)
            art("text-1489-189935", 80, 24, label: "现在不方便")
                .offset(x: 157, y: 778)

        }.frame(width: 393, height: 852, alignment: .topLeading)
    }
    private func postureCard(_ posture: WorkoutPosture) -> some View {
        let isOpen = expanded && selected == posture
        let compact = expanded && selected != posture
        return Button { choose(posture) } label: {
            VStack(alignment: .leading, spacing: isOpen ? 10 : 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        art(posture.titleAsset, 64, 24)
                        if isOpen { art(posture == .standing ? "text-1540-183138" : posture.subtitleAsset, posture == .standing ? 102 : 110, posture == .standing ? 18 : 20) }
                        else if !compact { art(posture.subtitleAsset, 110, 20) }
                    }
                    Spacer(minLength: 0)
                    if isOpen { art("text-1540-183139", 26, 18) }
                    else if compact {
                        if posture == .standing {
                            Image(posture.compactAsset).resizable().frame(width: 110 * 6 / 7, height: 20 * 6 / 7)
                                .frame(width: 48, height: 18, alignment: .leading).clipped().accessibilityLabel("伸个懒腰")
                        } else { art(posture.compactAsset, 48, 18) }
                    }
                    else { art(posture.iconAsset, 80, 80) }
                }
                if isOpen {
                    PlayerSurface(player: video.player)
                        .frame(width: 220, height: 220)
                        .background(.white)
                        .transition(.opacity)
                }
            }
            .padding(.leading, isOpen ? 30 : 29)
            .padding(.trailing, isOpen ? 30 : (compact ? 29 : 17))
            .frame(width: 280, height: isOpen ? 312 : (compact ? 58 : 114))
            .background(.white, in: RoundedRectangle(cornerRadius: 32))
            .overlay(RoundedRectangle(cornerRadius: 32).stroke(selected == posture ? .black : Color("MikoBorder"), lineWidth: selected == posture ? 2 : 1))
            .contentShape(RoundedRectangle(cornerRadius: 32))
        }.buttonStyle(OBPressStyle(kind: .card)).accessibilityLabel(posture.title)
            .accessibilityValue(selected == posture ? "已选择" : "未选择")
            .disabled(busy)
    }
    private func cancel() {
        sequence?.cancel(); sequence = nil; video.pause(); busy = false; speaking = false
        headerElapsed = 100; pageOpacity = 1; pageY = 0
    }
    private func catPosition(_ next: Screen) {
        catX = next == .invitation ? 124.62 : 18.4
        catY = next == .invitation ? 404.63 : (next == .plan ? 130.6 : 120.6)
        catScaleX = next == .invitation ? 1.92015 : 1
        catScaleY = next == .invitation ? 1.925 : 1
    }
    private func reset() {
        screen = .plan; selected = nil; expanded = false; busy = false
        stampY = 0; stampOpacity = 1; markOpacity = 0.5; paperY = 0; video.reset()
        pageOpacity = 1; pageY = 0; catOpacity = 1; catPosition(.plan); headerElapsed = 0
    }
    private func typeHeader() async throws {
        guard screen != .home else { return }
        if reduceMotion { headerElapsed = 100; speaking = false; return }
        let page = screen.rawValue
        let total = FirstWorkoutMotion.copyDuration(page)
        headerElapsed = 0
        while headerElapsed < total {
            try Task.checkCancellation()
            speaking = headerElapsed >= (page == 1 ? 0.47 : 0)
            try await delay(0.02); headerElapsed += 0.02
        }
        speaking = false
    }
    private func move(to next: Screen, backwards: Bool = false) async throws {
        video.pause(); speaking = false; busy = true
        let toInvitation = screen == .plan && next == .invitation
        let shared = toInvitation || (screen == .invitation && next == .selection)
        // Preserve this TalkingCat instance and begin its move with the outgoing page.
        if toInvitation {
            withAnimation(FirstWorkoutMotion.ease(reduceMotion ? 0.12 : FirstWorkoutMotion.sharedCatDuration)) {
                catPosition(next); catOpacity = 1
            }
        }
        let exit = reduceMotion ? 0.12 : (shared && !toInvitation ? 0.18 : FirstWorkoutMotion.exitDuration)
        withAnimation(FirstWorkoutMotion.ease(exit)) {
            pageOpacity = 0; pageY = reduceMotion ? 0 : (backwards ? 20 : -20)
            if !shared { catOpacity = 0 }
        }
        try await delay(exit)
        screen = next; headerElapsed = 0; pageY = reduceMotion ? 0 : (backwards ? -40 : 40)
        if next == .plan { stampY = 0; stampOpacity = 1; markOpacity = 0.5; paperY = 0; selected = nil; expanded = false }
        if !shared { catPosition(next); if next == .invitation && !reduceMotion { catY += 40 } }
        try await delay(0.02)
        withAnimation(FirstWorkoutMotion.ease(reduceMotion ? 0.12 : FirstWorkoutMotion.pageDuration)) { pageOpacity = 1; pageY = 0 }
        if !toInvitation {
            withAnimation(FirstWorkoutMotion.ease(reduceMotion ? 0.12 : (shared ? FirstWorkoutMotion.sharedCatDuration : FirstWorkoutMotion.pageDuration))) {
                catPosition(next); catOpacity = next == .home ? 0 : 1
            }
        }
        if shared && !toInvitation { try await delay(reduceMotion ? 0.12 : 0.8) }
        busy = false
        try await typeHeader()
    }
    /// Pause sequence time in the background rather than skipping states.
    private func delay(_ seconds: Double) async throws {
        var remaining = seconds
        while remaining > 0 {
            try Task.checkCancellation()
            try await Task.sleep(for: .milliseconds(20))
            if scenePhase == .active { remaining -= 0.02 }
        }
    }
    private func replay() { cancel(); reset(); sequence = Task { do { try await typeHeader() } catch {} } }
    private func startStamp() {
        guard !busy else { return }; cancel()
        sequence = Task { do { try await stampSequence() } catch {} }
    }
    private func stampSequence() async throws {
        busy = true
        withAnimation(FirstWorkoutMotion.ease(reduceMotion ? 0 : 0.22)) { stampY = reduceMotion ? 0 : -64 }
        try await delay(reduceMotion ? 0.12 : 0.22)
        withAnimation(FirstWorkoutMotion.ease(0.14)) { markOpacity = 1; paperY = reduceMotion ? 0 : 3 }
        try await delay(0.07)
        withAnimation(FirstWorkoutMotion.ease(reduceMotion ? 0.1 : 0.31)) { stampY = reduceMotion ? 0 : 12; stampOpacity = 0; paperY = 0 }
        try await delay(0.67)
        try await move(to: .invitation)
        try await delay(FirstWorkoutMotion.invitationHold)
        try await move(to: .selection)
    }
    private func expandPosture(_ posture: WorkoutPosture) async {
        busy = true; video.reset()
        withAnimation(FirstWorkoutMotion.ease(reduceMotion ? 0.1 : 0.52)) { selected = posture; expanded = true }
        do { try await delay(reduceMotion ? 0.1 : 0.52) } catch { return }
        busy = false
        if !reduceMotion && scenePhase == .active { video.play() }
    }
    private func choose(_ posture: WorkoutPosture) {
        guard !busy else { return }
        if expanded && selected == posture {
            video.player.rate > 0 ? video.pause() : video.play(); return
        }
        cancel()
        sequence = Task { await expandPosture(posture) }
    }
    private func back() {
        guard screen != .home else { return }; cancel()
        if screen == .selection {
            // Expansion belongs to selection, not to the navigation stack.
            sequence = Task { try? await move(to: .home, backwards: true) }
        } else if screen == .invitation {
            sequence = Task { try? await move(to: .plan, backwards: true) }
        } else { reset(); sequence = Task { try? await typeHeader() } }
    }

}

private struct PlayerSurface: UIViewRepresentable {
    var player: AVQueuePlayer
    final class PlayerView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView(); view.playerLayer.videoGravity = .resizeAspect
        view.playerLayer.player = player; view.isUserInteractionEnabled = false; return view
    }
    func updateUIView(_ view: PlayerView, context: Context) { view.playerLayer.player = player }
    static func dismantleUIView(_ view: PlayerView, coordinator: ()) { view.playerLayer.player = nil }
}

private extension FirstWorkoutView {
    var homePage: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: [.clear, Color("MikoSurface")], startPoint: .top, endPoint: .bottom).frame(width: 393, height: 311)
            HStack {
                art("home-imgGroup2090053774", 69.472, 22, label: "Miko")
                Spacer()
                art("home-imgFrame2090052795", 40, 40, label: "用户头像").clipShape(RoundedRectangle(cornerRadius: 16))
            }.frame(width: 358, height: 40).offset(x: 18, y: 52)
            homeGreeting.offset(x: 17, y: 108)
            homeWeek.offset(x: 21.5, y: 194)
            homePlan.offset(y: 297.405)
            HStack(spacing: 10) {
                art("home-imgPolygon1", 14, 14).rotationEffect(.degrees(89.53))
                Text("开始训练").font(.custom("STBaoYuan-SC", size: 20))
            }.foregroundStyle(.white).frame(width: 220, height: 60)
                .background(.black, in: RoundedRectangle(cornerRadius: 26)).offset(x: 86.5, y: 726)
        }.frame(width: 393, height: 852, alignment: .topLeading)
    }
    var homeGreeting: some View {
        ZStack(alignment: .topLeading) {
            art("home-imgGroup2090052802", 75.325, 16.74).offset(x: 3.91, y: 56.32)
            art("img202605121649591", 78, 57).offset(x: 1, y: 11)
            croppedArt("home-imgImage1540", width: 269.356, height: 75.371, sx: 1.2267, sy: 1.4646, x: -0.2267, y: -0.2182).offset(x: 84.322, y: 5)
            Text("还没有动起来吗？躺平不如动起来！\n今日运动计划已准备！")
                .font(.custom("STBaoYuan-SC", size: 14).bold()).foregroundStyle(.black.opacity(0.8))
                .lineSpacing(3).frame(width: 226, height: 40, alignment: .topLeading).offset(x: 106, y: 20)
        }.frame(width: 358, height: 80, alignment: .topLeading)
    }
    var homeWeek: some View {
        HStack(spacing: 0) {
            ForEach(Array(["一", "二", "三", "四", "今", "六", "日"].enumerated()), id: \.offset) { i, day in
                VStack(spacing: 0) {
                    Text(day).font(.custom("STBaoYuan-SC", size: 12).bold()).foregroundStyle(i == 4 ? .white : .black)
                        .frame(width: 40, height: 26).background(i == 4 ? .black : .clear, in: Capsule()).frame(width: 50, height: 50)
                    ZStack {
                        if i == 1 { art("home-imgImage1614", 34.103, 34.872).grayscale(1) }
                        else if i == 0 || i == 4 || i == 6 {
                            art(i == 0 ? "home-imgFrame2090053716" : (i == 4 ? "home-imgFrame2090053717" : "home-imgFrame2090053718"), 50, 50)
                        }
                    }.frame(width: 50, height: 50)
                }
            }
        }.frame(width: 350, height: 100)
    }
    var homePlan: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                (Text("0").font(.custom("STBaoYuan-SC", size: 28)) + Text("/100 kcal").font(.custom("STBaoYuan-SC", size: 14)).foregroundColor(Color("MikoDisabled")))
                Spacer()
                ZStack(alignment: .topLeading) {
                    croppedArt("home-img202605121926322", width: 212.623, height: 33.222, sx: 1, sy: 1.6769, x: 0, y: -0.267).offset(x: -6, y: -2)
                    art("home-imgVector7897", 61.31, 11.14).offset(x: 8.5, y: 11)
                }.frame(width: 200, height: 32).clipped()
            }.frame(height: 36).padding(.horizontal, 24).padding(.top, 20)
            HStack {
                Text("久坐身体开机 · 5分钟").font(.custom("STBaoYuan-SC", size: 20))
                Spacer()
                art("home-imgMoreHorizontal", 24, 24).frame(width: 40, height: 40)
                    .background(Color("MikoSurface"), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.black.opacity(0.05)))
            }.frame(height: 50).padding(.horizontal, 24).padding(.top, 17)
            VStack(spacing: 10) {
                ForEach(0..<4) { i in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(["俯卧撑", "深蹲", "弓步蹲", "俯卧撑"][i]).font(.custom("STBaoYuan-SC", size: 20))
                            Text("10次x5组").font(.custom("STBaoYuan-SC", size: 14)).foregroundStyle(.black.opacity(0.45))
                        }
                        Spacer()
                        ZStack {
                            if i == 1 { art("home-img227", 96, 96) }
                            else { croppedArt("home-imgImage1670", width: 64, height: i == 2 ? 76 : 72, sx: i == 2 ? 3.62 : 3.4724, sy: 2.2863, x: i == 2 ? -1.3352 : -2.3023, y: -0.6241) }
                        }.frame(width: 82, height: 82).shadow(color: .black.opacity(0.08), radius: 4, y: 4)
                    }.padding(.horizontal, 24).frame(width: 361, height: 106)
                        .background(Color("MikoBlue"), in: RoundedRectangle(cornerRadius: 32))
                        .overlay(RoundedRectangle(cornerRadius: 32).stroke(.black.opacity(0.05)))
                }
            }.padding(.top, 6)
        }.frame(width: 393, height: 558, alignment: .top)
            .background(.white, in: RoundedRectangle(cornerRadius: 32))
            .overlay(RoundedRectangle(cornerRadius: 32).stroke(.black.opacity(0.05))).clipped()
    }
    func croppedArt(_ name: String, width: CGFloat, height: CGFloat, sx: CGFloat, sy: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Image(name).resizable().frame(width: width * sx, height: height * sy)
            .offset(x: width * x, y: height * y)
            .frame(width: width, height: height, alignment: .topLeading).clipped().accessibilityHidden(true)
    }
}

/// Same per-character timing and restrained keyword movement as OB2.
private struct OBTypedHeading: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.scenePhase) var phase
    var page: Int
    var elapsed: Double
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion || phase != .active)) { timeline in
            VStack(alignment: page == 1 ? .center : .leading, spacing: 0) {
                ForEach(0..<2) { line in
                    let text = FirstWorkoutMotion.lines[page][line]
                    let size: CGFloat = page == 1 ? 24 : (page == 0 ? (line == 0 ? 16 : 20) : (line == 0 ? 20 : 16))
                    let lineHeight: CGFloat = page == 1 ? 32 : (size == 20 ? 28 : 24)
                    HStack(spacing: 0) {
                        ForEach(Array(text.enumerated()), id: \.offset) { index, char in
                            let visible = reduceMotion || elapsed >= FirstWorkoutMotion.characterTime(page, line, index)
                            let isKey = page == 0 ? (line == 1 && index >= 7 && index < 9) : (page == 1 ? (line == 0 && index >= 8) : (line == 1 && index >= 4 && index < 8))
                            let t = timeline.date.timeIntervalSinceReferenceDate / 0.96 + Double(index) * 0.2 / 0.96
                            let wave = sin(t * .pi * 2)
                            Text(String(char)).font(.custom("STBaoYuan-SC", size: size)).fixedSize()
                                .rotationEffect(.degrees(isKey && visible && !reduceMotion ? wave * 0.42 : 0))
                                .offset(x: isKey && visible && !reduceMotion ? wave * 0.9 : 0, y: visible ? (isKey && !reduceMotion ? -wave * 0.7 : 0) : 4)
                                .opacity(visible ? 1 : 0)
                                .animation(.timingCurve(0.25, 0.1, 0.25, 1, duration: reduceMotion ? 0.12 : (page == 1 ? (line == 0 ? 0.18 : 0.17) : 0.13)), value: visible)
                        }
                    }.frame(height: lineHeight)
                }
            }.frame(width: page == 1 ? 281 : (page == 0 ? 200 : 220), alignment: page == 1 ? .center : .leading)
        }.accessibilityElement(children: .ignore).accessibilityLabel(FirstWorkoutMotion.lines[page].joined(separator: "，"))
    }
}
private struct TalkingCat: View {
    var speaking: Bool
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.095, paused: !speaking)) { context in
            let open = Int(context.date.timeIntervalSinceReferenceDate / 0.095) % 2 == 1
            ZStack(alignment: .topLeading) {
                Image("img202605121649591").resizable().scaledToFit().frame(width: 78, height: 57)
                if speaking {
                    Ellipse().fill(.white).frame(width: 19, height: 15).position(x: 78 * 0.485, y: 57 * 0.73)
                    Capsule().fill(.black).frame(width: open ? 9 : 10, height: open ? 10 : 2.88).position(x: 78 * 0.485, y: 57 * 0.73)
                }
            }
        }
    }
}
private struct OBPressStyle: ButtonStyle {
    enum Kind { case standard, icon, card, cat }
    var kind: Kind = .standard
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var scale: CGFloat { kind == .icon ? 0.93 : kind == .card ? 0.972 : 0.965 }
    private var y: CGFloat { kind == .card ? 2 : kind == .standard ? 1.5 : 1 }
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed && !reduceMotion ? scale : 1)
            .offset(y: configuration.isPressed && !reduceMotion ? y : 0)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(configuration.isPressed ? .timingCurve(0.2, 0, 0.2, 1, duration: 0.09) : FirstWorkoutMotion.ease(0.32), value: configuration.isPressed)
    }
}
