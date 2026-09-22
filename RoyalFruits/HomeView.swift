import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: GameStore
    @State private var bob = false

    var body: some View {
        ZStack {
            CasinoBackdrop(image: "CasinoHall", dim: 0.42)
            VStack {
                HStack {
                    GoldCircleButton(system: "house.fill") { store.audio.click() }
                    Spacer()
                    BrandMark(titleSize: 20, subtitleSize: 9, titleTracking: 1.6, subtitleTracking: 2.16)
                    Spacer()
                    GoldCircleButton(system: "gearshape.fill") {
                        store.audio.click()
                        store.showSettings = true
                    }
                }
                .frame(height: 52)
                .padding(.top, 26)

                Spacer()

                VStack(spacing: 16) {
                    Text("今晚，手气正旺")
                        .font(Royal.black(26))
                        .foregroundStyle(Royal.cream)
                    Text("转动幸运滚轮，解锁属于你的皇家大奖")
                        .font(.system(size: 14))
                        .foregroundStyle(Royal.muted)
                        .multilineTextAlignment(.center)
                        .frame(width: 280)
                    HStack(spacing: 16) {
                        Text("🍒").font(.system(size: 44))
                        Text("7️⃣").font(.system(size: 44))
                        Text("🍋").font(.system(size: 44))
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 16)
                    .background(Color(red: 33 / 255, green: 20 / 255, blue: 31 / 255).opacity(0.8), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Royal.antique, lineWidth: 2))
                    .shadow(color: Royal.crimson.opacity(0.4), radius: 12)
                    .offset(y: bob ? -4 : 4)
                }

                Spacer()

                VStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Button {
                            store.audio.click()
                            withAnimation { store.route = .game }
                        } label: {
                            SpinCapsule(glowing: true)
                        }
                        .buttonStyle(PressScale())
                        Text("开始游戏")
                            .font(Royal.black(16))
                            .foregroundStyle(Royal.gold)
                    }
                    HStack(spacing: 16) {
                        secondary("gearshape.fill", "设置") { store.showSettings = true }
                        secondary("diamond.fill", "隐私政策") { store.showPrivacy = true }
                    }
                }
                .padding(16)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Royal.gold.opacity(0.2)))
                .background(.ultraThinMaterial.opacity(0.35), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                HomeIndicator().padding(.top, 8).padding(.bottom, 14)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { bob = true }
            store.audio.startMusic()
        }
    }

    private func secondary(_ icon: String, _ title: String, action: @escaping () -> Void) -> some View {
        Button {
            store.audio.click()
            action()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(Royal.gold)
                Text(title)
                    .font(Royal.bold(14))
                    .foregroundStyle(Royal.cream)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color(red: 23 / 255, green: 17 / 255, blue: 28 / 255).opacity(0.8), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Royal.bronze))
        }
        .buttonStyle(PressScale())
    }
}
