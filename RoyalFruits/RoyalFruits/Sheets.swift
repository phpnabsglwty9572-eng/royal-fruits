import SwiftUI

struct SettingsSheet: View {
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Royal.void.ignoresSafeArea()
                VStack(spacing: 16) {
                    toggle("背景音乐", isOn: $store.musicEnabled)
                    toggle("游戏音效", isOn: $store.soundEnabled)
                    toggle("震动反馈", isOn: $store.hapticEnabled)
                    Button("重置本地金币") {
                        store.resetProgress()
                        store.audio.click()
                    }
                    .font(Royal.bold(16))
                    .foregroundStyle(Royal.gold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Royal.banner, in: RoundedRectangle(cornerRadius: 16))
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }.foregroundStyle(Royal.gold)
                }
            }
            .onChange(of: store.musicEnabled) { _, _ in store.applyAudioFlags() }
            .onChange(of: store.soundEnabled) { _, _ in store.applyAudioFlags() }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }

    private func toggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .tint(Royal.crimson)
            .foregroundStyle(Royal.cream)
            .padding()
            .background(Royal.panel, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct PrivacySheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Royal.void.ignoresSafeArea()
                ScrollView {
                    Text("皇家水果为单机小游戏。金币、下注与奖池仅保存在本机，不联网、不上传账号。音效与背景音乐为原创合成素材，用于营造赌场霓虹氛围。")
                        .font(.system(size: 15))
                        .foregroundStyle(Royal.muted)
                        .padding(20)
                }
            }
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }.foregroundStyle(Royal.gold)
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }
}

struct RulesSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Royal.void.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 12) {
                    Text("中奖线仅计算中间一行。三枚相同符号即按倍率结算。")
                        .foregroundStyle(Royal.cream)
                    Text("7️⃣ ×10    🍒 ×8    🍉 ×6    🍇 ×5    🍋 ×4")
                        .foregroundStyle(Royal.gold)
                    Text("自动旋转会连续开转，直到点停或余额不足。")
                        .foregroundStyle(Royal.muted)
                    Spacer()
                }
                .font(Royal.bold(15))
                .padding(20)
            }
            .navigationTitle("规则")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }.foregroundStyle(Royal.gold)
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }
}
