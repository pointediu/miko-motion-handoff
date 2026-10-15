import SwiftUI

/// Figma 1540:179029 → 1522:173078, with detail sheet 1544:131642.
/// Local demonstration only. Continue training is intentionally presentation-only.
struct HomeAddView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var phase
    @State private var added = false
    @State private var adding = false
    @State private var busy = false
    @State private var sheetMounted = false
    @State private var sheetVisible = false
    @State private var recommendationVisible = true
    @State private var cardVisible = [false, false]
    @State private var buttonVisible = false
    @State private var buttonScale: CGFloat = 0.88
    @State private var buttonY: CGFloat = 10
    @State private var copyCount = 0
    @State private var copyGeneration = 0
    @State private var copyTask: Task<Void, Never>?
    @State private var actionTask: Task<Void, Never>?
    init() { _ = HomeAddMotion.registerFont }
    private let initialCopy = "还没有动起来吗？躺平不如动起来！\n今日运动计划已准备！"
    private let addedCopy = "快点练吧，我等的花儿都谢了。"
    private var copy: String { added ? addedCopy : initialCopy }
    private var speaking: Bool { copyCount < copy.count && phase == .active && !reduceMotion }
    private func font(_ size: CGFloat) -> Font { .custom("STBaoYuan-SC", size: size) }
    private func art(_ name: String, _ width: CGFloat, _ height: CGFloat) -> some View { Image(name).resizable().frame(width: width, height: height).accessibilityHidden(true) }
    private func animate(_ duration: Double) -> Animation { reduceMotion ? .linear(duration: 0.1) : HomeAddMotion.ease(duration) }
    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / 393, proxy.size.height / 852)
            ZStack(alignment: .topLeading) {
                Color(red: 250/255, green: 250/255, blue: 250/255)
                Canvas { context, _ in
                    for row in 0..<24 { for col in 0..<27 {
                        context.fill(Path(ellipseIn: CGRect(x: CGFloat(col * 15 + 6), y: CGFloat(row * 15 + 6), width: 1.5, height: 1.5)), with: .color(.black.opacity(0.1)))
                    } }
                }.frame(width: 393, height: 344)
                LinearGradient(colors: [.white.opacity(0), Color(white: 250/255)], startPoint: .top, endPoint: .bottom).frame(width: 393, height: 311)
                home.accessibilityHidden(sheetMounted).allowsHitTesting(!sheetMounted)
                status
                if sheetMounted {
                    Color.black.opacity(sheetVisible ? 0.32 : 0).contentShape(Rectangle()).onTapGesture { interact { await closeSheet() } }
                        .animation(sheetVisible ? animate(HomeAddMotion.scrimIn) : nil, value: sheetVisible)
                    sheet.offset(y: reduceMotion ? 53 : (sheetVisible ? 53 : 852)).opacity(reduceMotion && !sheetVisible ? 0 : 1)
                        .animation(animate(sheetVisible ? HomeAddMotion.sheetIn : HomeAddMotion.sheetOut), value: sheetVisible)
                }
                Capsule().fill(.black).frame(width: 144, height: 5).offset(x: 124.5, y: 839).allowsHitTesting(false)
            }.frame(width: 393, height: 852, alignment: .topLeading).clipped()
                .scaleEffect(scale, anchor: .topLeading).frame(width: scale * 393, height: scale * 852)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.ignoresSafeArea().preferredColorScheme(.light)
            .task { start() }
            .onDisappear { copyTask?.cancel(); actionTask?.cancel() }
            .onChange(of: reduceMotion) { _, _ in copyTask?.cancel(); copyCount = copy.count }
    }
    private var status: some View {
        ZStack(alignment: .topLeading) {
            Text("9:41").font(.system(size: 15, weight: .semibold)).frame(width: 56.6, height: 20).offset(x: 22, y: 13)
            art("imgCellularConnection", 17.1, 10.7).offset(x: 308.1, y: 17.67)
            art("imgWifi", 16.1, 11).offset(x: 331.18, y: 17.33)
            art("imgBattery", 25.5, 11.33).offset(x: 352.48, y: 17.33)
        }.frame(width: 393, height: 44, alignment: .topLeading).allowsHitTesting(false)
    }
    private var home: some View {
        ZStack(alignment: .topLeading) {
            art("home-imgGroup2090053774", 69.472, 22).offset(x: 19, y: 61)
            art("avatar", 40, 40).clipShape(RoundedRectangle(cornerRadius: 16)).offset(x: 336, y: 52)
            greeting.offset(x: 17, y: 108)
            week.offset(x: added ? 21.5 : 16, y: 194)
            plan.offset(y: 298)
            if added {
                HStack(spacing: 10) { art("home-imgPolygon1", 18, 16).rotationEffect(.degrees(89.53)); Text("继续训练").font(font(20)) }
                    .foregroundStyle(.white).frame(width: 220, height: 60).background(.black, in: RoundedRectangle(cornerRadius: 26))
                    .opacity(buttonVisible ? 1 : 0).scaleEffect(reduceMotion ? 1 : buttonScale)
                    .offset(x: 86.5, y: 726 + (reduceMotion ? 0 : buttonY))
                    .accessibilityLabel("继续训练，仅展示")
            }
        }.frame(width: 393, height: 852, alignment: .topLeading)
    }
    private var greeting: some View {
        ZStack(alignment: .topLeading) {
            if added { art("bubble-after", 278, 80).offset(x: 80) }
            else { art("home-imgImage1540", 330.43, 110.39).offset(x: -61.07, y: -16.45).frame(width: 269.356, height: 75.371, alignment: .topLeading).clipped().offset(x: 84.322, y: 5) }
            art(added ? "cat-after" : "img202605121649591", added ? 80 : 78, added ? 80 : 57).offset(x: added ? 0 : 1, y: added ? 0 : 11)
            if speaking {
                TimelineView(.animation(minimumInterval: 0.095, paused: !speaking)) { context in
                    let open = Int(context.date.timeIntervalSinceReferenceDate / 0.095) % 2 == 0
                    ZStack { Ellipse().fill(.white).frame(width: 19, height: 15); Capsule().fill(.black).frame(width: open ? 9 : 10, height: open ? 10 : 4) }
                }.frame(width: 19, height: 15).offset(x: 29.3, y: added ? 34 : 45)
            }
            Text(String(copy.prefix(copyCount))).font(added ? font(14) : font(14).bold()).foregroundStyle(.black.opacity(0.8)).lineSpacing(2)
                .frame(width: 226, height: added ? 20 : 40, alignment: .topLeading).offset(x: 106, y: added ? 30 : 20)
                .accessibilityLabel(copy)
        }.frame(width: 358, height: 80, alignment: .topLeading)
    }
    private var week: some View {
        HStack(spacing: 0) {
            ForEach(Array(["一", "二", "三", "四", "今", "六", "日"].enumerated()), id: \.offset) { index, label in
                let active = index == (added ? 4 : 3)
                VStack(spacing: 17.4) {
                    Text(label).font(font(12).bold()).foregroundStyle(active ? .white : .black).frame(width: 40, height: 26)
                        .background(active ? Color.black : (index == 4 ? Color.black.opacity(0.04) : .clear), in: Capsule()).padding(.top, 9)
                    ZStack {
                        if [1, 3].contains(index) || (added && index == 4) { art("home-imgImage1614", 34.1, 34.87).opacity(added ? 0.45 : 1) }
                        else if [0, 4, 6].contains(index) { Circle().fill(.black.opacity(0.3)).frame(width: 4, height: 4) }
                    }.frame(height: 35)
                    Spacer(minLength: 0)
                }.frame(width: (added ? 350 : 361) / 7, height: 98)
            }
        }.frame(width: added ? 350 : 361, height: 98)
    }
    // Anchor both states to the initial layout so existing content never shifts on insertion.
    private var plan: some View {
        ZStack(alignment: .topLeading) {
            UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32).fill(.white)
                .overlay(UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32).stroke(.black.opacity(0.05)))
            HStack(alignment: .firstTextBaseline, spacing: 0) { Text("30").font(font(28)); Text("/30 kcal").font(font(14)).foregroundStyle(.black.opacity(0.4)) }.offset(x: 24, y: 21)
            art("meter", 212.623, 33.222).offset(x: 156, y: 21)
            art("reward", 64, 57).offset(x: 312.65, y: 8.6)
            HStack { Text("今日训练").font(font(20)); Spacer(); art("more", 24, 24).frame(width: 40, height: 40).background(Color(white: 0.98), in: RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(.black.opacity(0.05))) }.frame(width: 345, height: 50).offset(x: 24, y: 73)
            ScrollView {
                VStack(spacing: 10) {
                    exercise(title: "深蹲", duration: "10次x5组", image: nil)
                    exercise(title: "弓步蹲", duration: "10次x5组", image: nil)
                    if added {
                        ForEach(0..<2) { index in
                            let action = HomeAction.recommendations[index]
                            exercise(title: action.title, duration: action.duration, image: action.image)
                                .opacity(cardVisible[index] ? 1 : 0)
                                .offset(y: reduceMotion || cardVisible[index] ? 0 : -6)
                        }
                    } else { recommendation.opacity(recommendationVisible ? 1 : 0).scaleEffect(reduceMotion || recommendationVisible ? 1 : 0.98).offset(y: reduceMotion || recommendationVisible ? 0 : -8) }
                }.padding(.bottom, added ? 105 : 35)
            }.scrollIndicators(.hidden).frame(width: 361, height: 425).offset(x: 16, y: 129)
        }.frame(width: 393, height: 554, alignment: .topLeading).clipped()
    }
    private func exercise(title: String, duration: String, image: String?) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) { Text(title).font(font(20)); Text(duration).font(font(14)).foregroundStyle(.black.opacity(0.45)) }
            Spacer(minLength: 0)
            if let image { art(image, 82, 82).shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 2) }
            else { Color.clear.frame(width: 82, height: 82) }
        }.padding(.horizontal, 24).frame(width: 361, height: 106)
            .background(Color(red: 241/255, green: 247/255, blue: 1))
            .overlay(alignment: .topTrailing) {
                if image == nil { art("completed-stamp", 361.8, 344.2).offset(y: -119.5).frame(width: 123, height: 112, alignment: .topLeading).clipped().opacity(0.1).rotationEffect(.degrees(-15)).offset(x: 20, y: 16) }
            }.clipShape(RoundedRectangle(cornerRadius: 32)).overlay(RoundedRectangle(cornerRadius: 32).stroke(.black.opacity(0.05)))
    }
    private var recommendation: some View {
        ZStack(alignment: .topLeading) {
            Button { interact { await openSheet() } } label: {
                VStack(alignment: .leading, spacing: 0) {
                    Text("更多训练").font(font(20)).foregroundStyle(Color(white: 0.13))
                    HStack(spacing: 14) { Text("僵硬退退退"); Text("8个动作") }.font(font(14)).foregroundStyle(.black.opacity(0.45)).padding(.top, 8)
                    HStack(spacing: 6) { ForEach(1..<4) { art("thumb-\($0)", 56, 56) }; art("more", 21, 21).opacity(0.13).padding(.leading, 7) }.padding(.top, 12)
                }.frame(width: 313, height: 124, alignment: .topLeading).padding(.horizontal, 24).padding(.vertical, 16)
                    .background(Color(white: 0.98), in: RoundedRectangle(cornerRadius: 32))
                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(.black.opacity(0.05)))
            }.buttonStyle(HomeAddPress(kind: .card)).accessibilityLabel("更多训练，查看动作列表").disabled(busy)
            Button { interact { await addExercises() } } label: {
                HStack(spacing: 4) { art("plus", 16, 16); Text("添加").font(font(14)) }.foregroundStyle(.white).frame(width: 76, height: 36).background(.black, in: RoundedRectangle(cornerRadius: 16))
            }.buttonStyle(HomeAddPress()).disabled(busy).offset(x: 261, y: 25.59)
        }.frame(width: 361, height: 156)
    }
    private var sheet: some View {
        ZStack(alignment: .topLeading) {
            UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32).fill(.white)
            Text("更多训练").font(font(16)).frame(width: 393, height: 48).offset(y: 12)
            Button { interact { await closeSheet() } } label: { art("close", 24, 24).frame(width: 40, height: 40).background(Color(white: 0.98), in: RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(.black.opacity(0.05))) }.buttonStyle(HomeAddPress(kind: .icon)).disabled(busy).accessibilityLabel("关闭更多训练").offset(x: 16, y: 16)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("坐着动一动").font(font(24)).frame(height: 32)
                        HStack(spacing: 10) { ForEach(["5分钟", "30kcal", "8个动作"], id: \.self) { Text($0).font(font(12)).padding(.horizontal, 8).frame(height: 24).background(Color(white: 0.98), in: RoundedRectangle(cornerRadius: 10)) } }.padding(.top, 2)
                        Text("通过坐姿下的轻量活动，帮助舒展肩颈、背部和上肢颈、背部和上肢").font(font(14)).foregroundStyle(Color(white: 0.13).opacity(0.4)).lineSpacing(6).frame(height: 48, alignment: .topLeading)
                    }
                    VStack(spacing: 10) { ForEach(HomeAction.recommendations) { exercise(title: $0.title, duration: $0.duration, image: $0.image) } }
                }.padding(.bottom, 34)
            }.scrollIndicators(.hidden).frame(width: 361, height: 727).offset(x: 16, y: 72)
        }.frame(width: 393, height: 799, alignment: .topLeading).clipped().accessibilityAddTraits(.isModal)
    }
    @MainActor private func delay(_ seconds: Double) async throws {
        var remaining = seconds
        while remaining > 0 { try Task.checkCancellation(); try await Task.sleep(for: .milliseconds(20)); if phase == .active { remaining -= 0.02 } }
    }
    @MainActor private func typeCopy() async {
        copyGeneration += 1
        let generation = copyGeneration
        let length = copy.count
        copyCount = 0
        if reduceMotion { copyCount = copy.count; return }
        do { try await delay(HomeAddMotion.characterDelay); for i in 1...length { try Task.checkCancellation(); guard generation == copyGeneration else { return }; copyCount = i; try await delay(HomeAddMotion.characterGap) } } catch {}
    }
    @MainActor private func start() {
        copyTask?.cancel()
        copyTask = Task { await typeCopy() }
    }
    @MainActor private func interact(_ action: @escaping @MainActor () async -> Void) { guard !busy else { return }; actionTask = Task { await action() } }
    @MainActor private func openSheet() async {
        guard !busy && !sheetMounted && !added else { return }; busy = true; sheetMounted = true
        do { try await delay(0.02); sheetVisible = true; try await delay(reduceMotion ? 0.1 : HomeAddMotion.sheetIn) } catch {}
        busy = false
    }
    @MainActor private func closeSheet() async {
        guard !busy && sheetMounted else { return }; busy = true; sheetVisible = false
        try? await delay(reduceMotion ? 0.1 : HomeAddMotion.sheetOut); sheetMounted = false; busy = false
    }
    @MainActor private func addExercises() async {
        guard !busy && !added && !sheetMounted else { return }; busy = true; adding = true
        withAnimation(animate(HomeAddMotion.recommendationOut)) { recommendationVisible = false }
        try? await delay(reduceMotion ? 0.1 : HomeAddMotion.recommendationOut)
        added = true; copyTask?.cancel(); copyTask = Task { await typeCopy() }
        try? await delay(0.02)
        for i in 0..<2 { withAnimation((reduceMotion ? Animation.linear(duration: 0.1) : HomeAddMotion.cardEase).delay(reduceMotion ? 0 : Double(i) * HomeAddMotion.cardStagger)) { cardVisible[i] = true } }
        try? await delay(reduceMotion ? 0 : HomeAddMotion.buttonDelay)
        withAnimation(animate(reduceMotion ? 0.1 : 0.245)) { buttonVisible = true; buttonScale = reduceMotion ? 1 : 1.035; buttonY = reduceMotion ? 0 : -2 }
        try? await delay(reduceMotion ? 0.1 : 0.245)
        withAnimation(animate(0.115)) { buttonScale = 1; buttonY = 0 }
        try? await delay(reduceMotion ? 0 : 0.115); adding = false; busy = false
    }
}
