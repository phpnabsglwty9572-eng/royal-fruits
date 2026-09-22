import SwiftUI

struct GameView: View {
    @EnvironmentObject private var store: GameStore
    @State private var shine = false
    @State private var linePulse = false

    var body: some View {
        ZStack {
            CasinoBackdrop(image: "CasinoTable", dim: 0.24)

            GeometryReader { geo in
                let reelWindow = min(264, max(198, geo.size.height * 0.31))
                VStack(spacing: 12) {
                    header
                    walletBar
                    machine(reelWindow: reelWindow)
                    betRow
                    spinButton
                    HomeIndicator
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }

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
        ZStack {
            HStack {
                GoldCircleButton(system: "house.fill") {
                    store.autoPlay = false
                    store.audio.click()
                    withAnimation { store.route = .home }
                }
                Spacer()
                GoldCircleButton(system: "gearshape.fill") {
                    store.audio.click()
                    store.showSettings = true
                }
            }
            BrandMark(titleSize: 18, subtitleSize: 9, titleTracking: 1.8, subtitleTracking: 2.16)
                .allowsHitTesting(false)
        }
        .frame(height: 48)
    }

    private var walletBar: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("余额").font(Royal.semi(11)).tracking(0.88).foregroundStyle(Royal.muted)
                Text("¥ \(store.coins.formatted())")
                    .font(Royal.extra(20))
                    .foregroundStyle(Royal.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle().fill(Royal.bronze).frame(width: 1, height: 42)

            VStack(alignment: .trailing, spacing: 2) {
                Text("累积奖池").font(Royal.semi(11)).tracking(0.88).foregroundStyle(Royal.muted)
                Text("¥ \(store.jackpot.formatted())")
                    .font(Royal.extra(20))
                    .foregroundStyle(Royal.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Royal.panel, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Royal.bronze))
    }

    private func machine(reelWindow: CGFloat) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("中奖线  01 / 05").font(Royal.bold(12)).foregroundStyle(Royal.cream)
                Spacer()
                Text("幸运倍率  × \(store.paylineHit ? store.grid[1][0].lineMultiplier : 10)")
                    .font(Royal.black(13))
                    .foregroundStyle(Royal.gold)
            }
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(Royal.banner, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            reelWindowView(height: reelWindow)

            Text(store.banner)
                .font(Royal.extra(14))
                .foregroundStyle(store.paylineHit ? Royal.winGreen : Royal.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
                .frame(height: 18)
        }
        .padding(10)
        .background(Royal.panelDeep, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Royal.antique, lineWidth: 2))
        .shadow(color: Royal.crimson.opacity(0.28), radius: 10)
    }

    private func reelWindowView(height: CGFloat) -> some View {
        let inset: CGFloat = 5
        let gap: CGFloat = 6
        let cellH = max(58, (height - inset * 2) / 3)

        return ZStack {
            HStack(spacing: gap) {
                ForEach(0..<3, id: \.self) { col in
                    VStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { row in
                            symbolCell(store.grid[row][col], row: row, height: cellH)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .background(
                        Color(red: 244 / 255, green: 231 / 255, blue: 215 / 255),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                }
            }
            .padding(inset)
            .blur(radius: store.reelBlur)

            Rectangle()
                .fill(Royal.crimson)
                .frame(height: 3)
                .shadow(color: Royal.crimson.opacity(linePulse ? 0.9 : 0.35), radius: linePulse ? 8 : 3)
                .padding(.horizontal, 8)

            HStack {
                Image("PaylineCap")
                    .resizable()
                    .frame(width: 12, height: 12)
                Spacer()
            }
            .padding(.leading, 2)
        }
        .frame(height: height)
        .clipped()
        .background(Royal.reelWood, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Royal.gold, lineWidth: 2))
    }

    private func symbolCell(_ symbol: SlotSymbol, row: Int, height: CGFloat) -> some View {
        let hit = store.paylineHit && row == 1
        return Text(symbol.glyph)
            .font(.system(size: min(44, height * 0.62)))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Royal.reelCream)
            .overlay(alignment: .bottom) {
                if row < 2 { Rectangle().fill(Royal.reelLine).frame(height: 1) }
            }
            .scaleEffect(hit ? 1.06 : 1)
            .animation(.spring(response: 0.32, dampingFraction: 0.72), value: hit)
    }

    private var betRow: some View {
        HStack(alignment: .top, spacing: 8) {
            sideControl(
                icon: "arrow.clockwise",
                title: "自动旋转",
                active: store.autoPlay
            ) { store.toggleAuto() }

            HStack(spacing: 12) {
                roundMini("−") { store.decreaseBet() }
                VStack(spacing: 0) {
                    Text("下注").font(.system(size: 10)).foregroundStyle(Royal.muted)
                    Text("¥ \(store.bet)")
                        .font(Royal.extra(18))
                        .foregroundStyle(Royal.gold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(minWidth: 52)
                roundMini("+") { store.increaseBet() }
            }
            .padding(.horizontal, 10)
            .frame(height: 50)
            .background(Royal.panel, in: Capsule())
            .overlay(Capsule().stroke(Royal.bronze))

            sideControl(icon: nil, title: "规则", glyph: "i") {
                store.audio.click()
                store.showRules = true
            }
        }
        .frame(height: 64)
    }

    private func sideControl(icon: String?, title: String, glyph: String? = nil, active: Bool = false, action: @escaping () -> Void) -> some View {
        VStack(spacing: 4) {
            Button(action: action) {
                ZStack {
                    Circle().fill(Royal.panelDeep)
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(active ? Royal.crimson : Royal.gold)
                    } else {
                        Text(glyph ?? "")
                            .font(Royal.bold(18))
                            .foregroundStyle(Royal.gold)
                    }
                }
                .frame(width: 46, height: 46)
                .overlay(Circle().stroke(active ? Royal.crimson : Royal.bronze))
            }
            .buttonStyle(PressScale())
            Text(title)
                .font(Royal.semi(11))
                .foregroundStyle(Royal.muted)
                .lineLimit(1)
        }
        .frame(width: 64)
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

    private var spinButton: some View {
        Button {
            Task { await store.spin() }
        } label: {
            SpinCapsule(title: store.isSpinning ? "GO" : "SPIN", glowing: shine || store.isSpinning)
                .opacity(store.canSpin || store.isSpinning ? 1 : 0.55)
        }
        .buttonStyle(PressScale())
        .disabled(store.isSpinning)
        .padding(.top, 4)
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
                        x: burst ? cos(Double(i) / 14 * .pi * 2) * 110 : 0,
                        y: burst ? sin(Double(i) / 14 * .pi * 2) * 80 : 0
                    )
                    .opacity(burst ? 0.12 : 0.85)
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
