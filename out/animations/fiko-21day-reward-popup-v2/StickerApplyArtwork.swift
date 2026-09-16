import SwiftUI

/// 将同目录 PrizeSticker.png 放入 Assets，命名 PrizeSticker。
/// 外层用统一 elapsed 驱动；背景与弹窗布局沿用已确认的第一版。
/// 该视图仅绘制 180 × 180pt 的奖品图层，不包含完整弹窗或业务导航。
struct StickerApplyArtwork: View {
    let elapsed: Double
    var image = Image("PrizeSticker")
    @Environment(\.accessibilityReduceMotion) private var reducedMotion

    var body: some View {
        let p = RewardPopupStickerParameters.pose(at: elapsed, reducedMotion: reducedMotion)
        Canvas { context, _ in
            let image = context.resolve(image)
            if reducedMotion || (p["adhesion"] ?? 1) >= 1 {
                context.draw(image, in: CGRect(x: 0, y: 0, width: 180, height: 180))
            } else {
                for strip in RewardPopupStickerParameters.strips(at: elapsed) {
                    var layer = context
                    let bounds = CGRect(x: strip.x, y: strip.y, width: 180, height: strip.height + 0.06)
                    layer.clip(to: Path(bounds), style: FillStyle(antialiased: false))
                    layer.translateBy(x: CGFloat(strip.x), y: CGFloat(strip.y))
                    layer.scaleBy(x: 1, y: CGFloat((strip.height + 0.06) / strip.sourceHeight))
                    layer.draw(image, in: CGRect(x: 0, y: -strip.sourceY, width: 180, height: 180))
                }
            }
        }
        .frame(width: 180, height: 180)
        .shadow(color: Color(red: 30.0 / 255, green: 49.0 / 255, blue: 76.0 / 255)
            .opacity(p["shadowOpacity"] ?? 0), radius: CGFloat(p["shadowBlur"] ?? 0),
            x: 0, y: CGFloat(p["shadowY"] ?? 0))
        .scaleEffect(CGFloat(p["prizeScale"] ?? 1))
        .rotationEffect(.degrees(p["prizeRotation"] ?? 0))
        .offset(x: CGFloat(p["prizeX"] ?? 0), y: CGFloat(p["prizeY"] ?? 0))
        .opacity(p["prizeOpacity"] ?? 1)
        .accessibilityLabel("Miko 实物贴纸")
    }
}
