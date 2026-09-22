import SwiftUI
import UIKit

enum AppRoute {
    case loading, home, game
}

enum SlotSymbol: String, CaseIterable, Identifiable {
    case cherry, seven, lemon, watermelon, grape

    var id: String { rawValue }

    var glyph: String {
        switch self {
        case .cherry: "🍒"
        case .seven: "7️⃣"
        case .lemon: "🍋"
        case .watermelon: "🍉"
        case .grape: "🍇"
        }
    }

    var lineMultiplier: Int {
        switch self {
        case .seven: 10
        case .cherry: 8
        case .watermelon: 6
        case .grape: 5
        case .lemon: 4
        }
    }

    var title: String {
        switch self {
        case .seven: "幸运 7"
        case .cherry: "樱桃"
        case .watermelon: "西瓜"
        case .grape: "葡萄"
        case .lemon: "柠檬"
        }
    }

    static func randomSpin() -> SlotSymbol {
        let bag: [SlotSymbol] = [
            .cherry, .cherry, .lemon, .lemon, .grape, .watermelon, .seven
        ]
        return bag.randomElement() ?? .cherry
    }
}

@MainActor
final class GameStore: ObservableObject {
    @Published var route: AppRoute = .loading
    @Published var loadProgress: Double = 0
    @Published var coins: Int
    @Published var jackpot: Int
    @Published var bet: Int
    @Published var grid: [[SlotSymbol]]
    @Published var isSpinning = false
    @Published var autoPlay = false
    @Published var lastWin = 1_000
    @Published var banner = "三枚幸运 7 · 赢得 1,000"
    @Published var paylineHit = true
    @Published var showWinBurst = false
    @Published var showSettings = false
    @Published var showPrivacy = false
    @Published var showRules = false
    @Published var soundEnabled: Bool
    @Published var musicEnabled: Bool
    @Published var hapticEnabled: Bool
    @Published var reelBlur: CGFloat = 0

    let bets = [20, 50, 100, 200]
    private var autoTask: Task<Void, Never>?
    private let defaults = UserDefaults.standard
    let audio = SoundHub()

    init() {
        coins = defaults.object(forKey: "rf.coins") as? Int ?? 8_680
        jackpot = defaults.object(forKey: "rf.jackpot") as? Int ?? 188_888
        bet = defaults.object(forKey: "rf.bet") as? Int ?? 100
        soundEnabled = defaults.object(forKey: "rf.sound") as? Bool ?? true
        musicEnabled = defaults.object(forKey: "rf.music") as? Bool ?? true
        hapticEnabled = defaults.object(forKey: "rf.haptic") as? Bool ?? true
        grid = GameStore.mockGrid()
    }

    var canSpin: Bool { !isSpinning && coins >= bet }

    func persist() {
        defaults.set(coins, forKey: "rf.coins")
        defaults.set(jackpot, forKey: "rf.jackpot")
        defaults.set(bet, forKey: "rf.bet")
        defaults.set(soundEnabled, forKey: "rf.sound")
        defaults.set(musicEnabled, forKey: "rf.music")
        defaults.set(hapticEnabled, forKey: "rf.haptic")
    }

    func bootstrap() async {
        audio.soundEnabled = soundEnabled
        audio.musicEnabled = musicEnabled
        audio.startMusic()
        for step in 1...100 {
            loadProgress = Double(step) / 100
            try? await Task.sleep(nanoseconds: 22_000_000)
        }
        withAnimation(.easeInOut(duration: 0.45)) { route = .home }
    }

    func decreaseBet() {
        guard !isSpinning, let idx = bets.firstIndex(of: bet), idx > 0 else { return }
        bet = bets[idx - 1]
        persist()
        audio.click()
        haptic(.light)
    }

    func increaseBet() {
        guard !isSpinning, let idx = bets.firstIndex(of: bet), idx < bets.count - 1 else { return }
        bet = bets[idx + 1]
        persist()
        audio.click()
        haptic(.light)
    }

    func toggleAuto() {
        autoPlay.toggle()
        audio.click()
        haptic(.light)
        if autoPlay { Task { await spin() } } else { autoTask?.cancel() }
    }

    func resetProgress() {
        autoPlay = false
        autoTask?.cancel()
        coins = 8_680
        jackpot = 188_888
        bet = 100
        lastWin = 1_000
        banner = "三枚幸运 7 · 赢得 1,000"
        paylineHit = true
        grid = GameStore.mockGrid()
        persist()
    }

    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func spin() async {
        guard canSpin else {
            if coins < bet {
                autoPlay = false
                banner = "余额不足"
            }
            return
        }

        isSpinning = true
        paylineHit = false
        showWinBurst = false
        lastWin = 0
        coins -= bet
        jackpot += bet / 10
        persist()
        audio.spin()
        haptic(.rigid)
        withAnimation(.easeIn(duration: 0.12)) { reelBlur = 6 }

        for tick in 0..<22 {
            grid = GameStore.freshGrid()
            if tick % 2 == 0 { audio.tick() }
            try? await Task.sleep(nanoseconds: UInt64(28_000_000 + tick * 7_000_000))
        }

        withAnimation(.easeOut(duration: 0.2)) { reelBlur = 0 }
        grid = GameStore.freshGrid()
        audio.stopReel()

        let middle = [grid[1][0], grid[1][1], grid[1][2]]
        if middle[0] == middle[1], middle[1] == middle[2] {
            let payout = bet * middle[0].lineMultiplier
            paylineHit = true
            lastWin = payout
            coins += payout
            jackpot += payout / 20
            banner = "三枚\(middle[0].title) · 赢得 \(payout.formatted())"
            showWinBurst = true
            audio.win()
            haptic(.heavy)
        } else {
            banner = "再试一次，皇家大奖在等你"
            haptic(.light)
        }
        persist()
        isSpinning = false

        if autoPlay {
            autoTask?.cancel()
            autoTask = Task {
                try? await Task.sleep(nanoseconds: 900_000_000)
                guard !Task.isCancelled, autoPlay else { return }
                await spin()
            }
        }
    }

    func applyAudioFlags() {
        audio.soundEnabled = soundEnabled
        audio.musicEnabled = musicEnabled
        persist()
        if musicEnabled { audio.startMusic() } else { audio.stopMusic() }
    }

    private static func freshGrid() -> [[SlotSymbol]] {
        (0..<3).map { _ in (0..<3).map { _ in SlotSymbol.randomSpin() } }
    }

    static func mockGrid() -> [[SlotSymbol]] {
        [
            [.cherry, .watermelon, .lemon],
            [.seven, .seven, .seven],
            [.lemon, .grape, .cherry]
        ]
    }
}
