import SwiftUI

struct GameView: View {
    @EnvironmentObject private var store: GameStore
    @State private var shine = false
    @State private var linePulse = false

    var body: some View {
        ZStack {
            CasinoBackdrop(image: "CasinoTable", dim: 0.24)
            VStack(spacing: 14) {
                header
                walletBar
                machine
                betRow
                Spacer(minLength: 0)
                bottomDock
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 14)

            if store.showWinBurst {
                WinBurstOverlay(amount: store.lastWin)
                    .transition(.scale.combined(with: .opacity))
                    .onTapGesture { withAnimation { store.showWinBurst = false } }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                shine = true
                linePulse = true
            }
        }
    }

    private var header: some View {
        HStack {
            GoldCircleButton(system: "house.fill") {
                store.autoPlay = false
                store.audio.click()
                withAnimation { store.route = .home }
            }
            Spacer()
            BrandMark(titleSize: 18, subtitleSize: 9, titleTracking: 1.8, subtitleTracking: 2.16)
            Spacer()
            GoldCircleButton(system: "gearshape.fill") {
                store.audio.click()
                store.showSettings = true
            }
        }
        .frame(height: 48)
    }

    private var walletBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("余额").font(Royal.semi(11)).tracking(0.88).foregroundStyle(Royal.muted)
                Text("¥ \(store.coins.formatted())").font(Royal.extra(20)).foregroundStyle(Royal.cream)
            }
            Spacer()
            Rectangle().fill(Royal.bronze).frame(width: 1, height: 42)
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                Text("累积奖池").font(Royal.semi(11)).tracking(0.88).foregroundStyle(Royal.muted)
                Text("¥ \(store.jackpot.formatted())").font(Royal.extra(20)).foregroundStyle(Royal.gold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Royal.panel, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Royal.bronze))
        .shadow(color: .black.opacity(0.6), radius: 8, y: 5)
    }

    private var machine: some View {
        VStack(spacing: 10) {
            HStack {
                Text("中奖线  01 / 05").font(Royal.bold(12)).foregroundStyle(Royal.cream)
                Spacer()
                Text("幸运倍率  × \(store.paylineHit ? max(store.grid[1][0].lineMultiplier, 10) : 10)")
                    .font(Royal.black(13))
                    .foregroundStyle(Royal.gold)
            }
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(Royal.banner, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            ZStack {
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { col in
                        reel(col)
                    }
                }
                .padding(5)
                .blur(radius: store.reelBlur)

                Rectangle()
                    .fill(Royal.crimson)
                    .frame(height: 3)
                    .shadow(color: Royal.crimson.opacity(linePulse ? 0.85 : 0.35), radius: linePulse ? 10 : 4)
                    .padding(.horizontal, 6)
                    .offset(y: 2)

                HStack {
                    Image("PaylineCap")
                        .resizable()
                        .frame(width: 12, height: 12)
                    Spacer()
                }
                .padding(.leading, 1)
            }
            .frame(height: 264)
            .background(Royal.reelWood, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Royal.gold, lineWidth: 2))

            Text(store.banner)
                .font(Royal.extra(14))
                .foregroundStyle(store.paylineHit ? Royal.winGreen : Royal.muted)
                .frame(maxWidth: .infinity)
                .scaleEffect(store.paylineHit ? 1.04 : 1)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: store.paylineHit)
        }
        .padding(10)
        .background(Royal.panelDeep, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Royal.antique, lineWidth: 2))
        .shadow(color: .black.opacity(0.6), radius: 8, y: 5)
        .shadow(color: Royal.crimson.opacity(0.4), radius: 12)
    }

    private func reel(_ col: Int) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { row in
                Text(store.grid[row][col].glyph)
                    .font(.system(size: 48))
                    .frame(maxWidth: .infinity)
                    .frame(height: 84)
                    .background(Royal.reelCream)
                    .overlay(alignment: .bottom) {
                        if row < 2 { Rectangle().fill(Royal.reelLine).frame(height: 1) }
                    }
                    .scaleEffect(store.paylineHit && row == 1 ? 1.08 : 1)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .background(Color(red: 244 / 255, green: 231 / 255, blue: 215 / 255), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var betRow: some View {
        HStack {
            VStack(spacing: 5) {
                Button {
                    store.toggleAuto()
                } label: {
                    ZStack {
                        Circle().fill(Royal.panelDeep)
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(store.autoPlay ? Royal.crimson : Royal.gold)
                    }
                    .frame(width: 46, height: 46)
                    .overlay(Circle().stroke(store.autoPlay ? Royal.crimson : Royal.bronze))
                }
                .buttonStyle(PressScale())
                Text("自动旋转").font(Royal.semi(11)).foregroundStyle(Royal.muted)
            }
            Spacer()
            HStack(spacing: 14) {
                roundMini("−") { store.decreaseBet() }
                VStack(spacing: 0) {
                    Text("下注").font(.system(size: 10)).foregroundStyle(Royal.muted)
                    Text("¥ \(store.bet)").font(Royal.extra(18)).foregroundStyle(Royal.gold)
                }
                .frame(minWidth: 49)
                roundMini("+") { store.increaseBet() }
            }
            .padding(.horizontal, 9)
            .frame(height: 50)
            .background(Royal.panel, in: Capsule())
            .overlay(Capsule().stroke(Royal.bronze))
            Spacer()
            VStack(spacing: 5) {
                Button { store.audio.click(); store.showRules = true } label: {
                    ZStack {
                        Circle().fill(Royal.panelDeep)
                        Text("i").font(Royal.bold(20)).foregroundStyle(Royal.gold)
                    }
                    .frame(width: 46, height: 46)
                    .overlay(Circle().stroke(Royal.bronze))
                }
                .buttonStyle(PressScale())
                Text("规则").font(Royal.semi(11)).foregroundStyle(Royal.muted)
            }
        }
        .frame(height: 58)
    }

    private func roundMini(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Royal.extra(22))
                .foregroundStyle(Royal.cream)
                .frame(width: 34, height: 34)
                .background(Royal.minusFill, in: Circle())
        }
        .buttonStyle(PressScale())
    }

    private var bottomDock: some View {
        VStack {
            Button {
                Task { await store.spin() }
            } label: {
                SpinCapsule(title: store.isSpinning ? "GO" : "SPIN", glowing: shine || store.isSpinning)
                    .opacity(store.canSpin || store.isSpinning ? 1 : 0.55)
            }
            .buttonStyle(PressScale())
            .disabled(store.isSpinning)
            Spacer()
            HomeIndicator()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                .fill(.white.opacity(0.10))
        )
        .overlay(alignment: .top) {
            Rectangle().fill(Royal.gold).frame(height: 1)
        }
    }
}

struct WinBurstOverlay: View {
    var amount: Int
    @State private var burst = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            ForEach(0..<14, id: \.self) { i in
                Circle()
                    .fill(i.isMultiple(of: 2) ? Royal.gold : Royal.crimson)
                    .frame(width: burst ? 10 : 4, height: burst ? 10 : 4)
                    .offset(
                        x: burst ? cos(Double(i) / 14 * .pi * 2) * 120 : 0,
                        y: burst ? sin(Double(i) / 14 * .pi * 2) * 90 : 0
                    )
                    .opacity(burst ? 0.15 : 0.9)
            }
            VStack(spacing: 8) {
                Text("YOU WIN")
                    .font(Royal.black(22))
                    .foregroundStyle(Royal.gold)
                Text("+\(amount.formatted())")
                    .font(Royal.black(36))
                    .foregroundStyle(Color(red: 155 / 255, green: 247 / 255, blue: 1))
                Text("轻触继续")
                    .font(Royal.bold(12))
                    .foregroundStyle(Royal.muted)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 22)
            .background(Royal.panelDeep, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(red: 155 / 255, green: 247 / 255, blue: 1), lineWidth: 3))
            .shadow(color: Royal.gold.opacity(0.5), radius: 18)
            .scaleEffect(burst ? 1 : 0.82)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { burst = true }
        }
    }
}
