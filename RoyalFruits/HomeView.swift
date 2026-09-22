import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: GameStore
    @State private var bob = false

    var body: some View {
        ZStack {
            CasinoBackdrop(image: "CasinoHall", dim: 0.42)
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        GoldCircleButton(system: "house.fill") { store.audio.click() }
                        Spacer(minLength: 0)
                        GoldCircleButton(system: "gearshape.fill") {
                            store.audio.click()
                            store.showSettings = true
                        }
                    }
                    BrandMark(titleSize: 20, subtitleSize: 9, titleTracking: 1.6, subtitleTracking: 2.16)
                        .allowsHitTesting(false)
                }
                .frame(height: 52)
                .padding(.top, 12)

                Spacer(minLength: 12)

                VStack(spacing: 16) {
                    Text("今晚，手气正旺")
                        .font(Royal.black(26))
                        .foregroundStyle(Royal.cream)
                        .multilineTextAlignment(.center)
                    Text("转动幸运滚轮，解锁属于你的皇家大奖")
                        .font(.system(size: 14))
                        .foregroundStyle(Royal.muted)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                    HStack(spacing: 16) {
                        Text("🍒").font(.system(size: 40))
                        Text("7️⃣").font(.system(size: 40))
                        Text("🍋").font(.system(size: 40))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 33 / 255, green: 20 / 255, blue: 31 / 255).opacity(0.8), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Royal.antique, lineWidth: 2))
                    .offset(y: bob ? -4 : 4)
                }
                .padding(.horizontal, 4)

                Spacer(minLength: 12)

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
                    HStack(spacing: 12) {
                        secondary("gearshape.fill", "设置") { store.showSettings = true }
                        secondary("diamond.fill", "隐私政策") { store.showPrivacy = true }
                    }
                }
                .padding(16)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Royal.gold.opacity(0.2)))

                HomeIndicator()
                    .padding(.top, 10)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
