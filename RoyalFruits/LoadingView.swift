import SwiftUI

struct LoadingView: View {
    @EnvironmentObject private var store: GameStore
    @State private var pulse = false

    var body: some View {
        ZStack {
            CasinoBackdrop(image: "CasinoHall", dim: 0.38)
            VStack {
                Color.clear.frame(height: 8)
                Spacer(minLength: 8)
                VStack(spacing: 36) {
                    BrandMark(titleSize: 38, subtitleSize: 12, titleTracking: 3.04, subtitleTracking: 3.36)
                    ZStack {
                        Circle()
                            .fill(Color(red: 59 / 255, green: 7 / 255, blue: 16 / 255).opacity(0.8))
                        Image("BadgeRing")
                            .resizable()
                            .scaledToFit()
                            .padding(13)
                        Text("🍒")
                            .font(.system(size: 64))
                            .scaleEffect(pulse ? 1.06 : 0.96)
                    }
                    .frame(width: 154, height: 154)
                    .overlay(Circle().stroke(Royal.antique, lineWidth: 2))
                    .shadow(color: Royal.gold.opacity(0.4), radius: 16)
                    .shadow(color: Royal.crimson.opacity(0.4), radius: 22)

                    VStack(spacing: 10) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(red: 21 / 255, green: 17 / 255, blue: 28 / 255))
                                Capsule()
                                    .fill(LinearGradient(colors: [Royal.crimson, Royal.gold], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: max(8, (geo.size.width - 4) * store.loadProgress))
                                    .shadow(color: Royal.crimson.opacity(0.4), radius: 10)
                                    .padding(2)
                            }
                            .overlay(Capsule().stroke(Royal.bronze, lineWidth: 1))
                        }
                        .frame(height: 10)
                        Text("正在准备幸运滚轮… \(Int(store.loadProgress * 100))%")
                            .font(Royal.bold(14))
                            .foregroundStyle(Royal.cream)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("好运即将开始")
                            .font(.system(size: 11))
                            .foregroundStyle(Royal.muted)
                    }
                    .padding(.horizontal, 4)
                }
                Spacer(minLength: 8)
                HomeIndicator().padding(.bottom, 10)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulse = true }
            Task { await store.bootstrap() }
        }
    }
}
