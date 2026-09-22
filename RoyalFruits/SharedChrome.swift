import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        ZStack {
            switch store.route {
            case .loading: LoadingView()
            case .home: HomeView()
            case .game: GameView()
            }
        }
        .animation(.easeInOut(duration: 0.45), value: store.route)
        .sheet(isPresented: $store.showSettings) { SettingsSheet() }
        .sheet(isPresented: $store.showPrivacy) { PrivacySheet() }
        .sheet(isPresented: $store.showRules) { RulesSheet() }
    }
}

struct CasinoBackdrop: View {
    var image: String
    var dim: Double

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Royal.void
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                Royal.overlay.opacity(dim)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct BrandMark: View {
    var titleSize: CGFloat
    var subtitleSize: CGFloat
    var titleTracking: CGFloat
    var subtitleTracking: CGFloat

    var body: some View {
        VStack(spacing: 2) {
            Text("皇家水果")
                .font(Royal.black(titleSize))
                .foregroundStyle(Royal.gold)
                .tracking(titleTracking)
                .shadow(color: Royal.gold.opacity(0.4), radius: 8)
            Text("LUCKY CLUB")
                .font(Royal.extra(subtitleSize))
                .foregroundStyle(Royal.crimson)
                .tracking(subtitleTracking)
        }
    }
}

struct GoldCircleButton: View {
    var system: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Royal.wine)
                Image(systemName: system)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Royal.goldSoft)
            }
            .frame(width: 46, height: 46)
            .clipShape(Circle())
            .overlay(Circle().stroke(Royal.gold, lineWidth: 3))
            .shadow(color: Color(red: 1, green: 176 / 255, blue: 0).opacity(0.65), radius: 5, y: 4)
            .overlay(
                Circle().stroke(Color(red: 1, green: 242 / 255, blue: 176 / 255).opacity(0.35), lineWidth: 3)
                    .blur(radius: 0.3)
                    .offset(y: 1)
                    .mask(Circle())
            )
        }
        .buttonStyle(PressScale())
    }
}

struct SpinCapsule: View {
    var title = "SPIN"
    var glowing = false

    var body: some View {
        ZStack {
            Capsule().fill(Royal.wine)
            if glowing {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Royal.gold.opacity(0.35), .clear, Royal.crimson.opacity(0.35)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .blur(radius: 8)
            }
            Text(title)
                .font(Royal.black(30))
                .foregroundStyle(Royal.goldSoft)
        }
        .frame(width: 190, height: 92)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Royal.gold, lineWidth: 3)
        )
        .shadow(color: Color(red: 1, green: 176 / 255, blue: 0).opacity(0.65), radius: 5, y: 4)
        .overlay(
            Capsule()
                .stroke(Color(red: 1, green: 242 / 255, blue: 176 / 255).opacity(0.35), lineWidth: 4)
                .offset(y: 2)
                .blur(radius: 1)
                .mask(Capsule())
        )
    }
}

struct HomeIndicator: View {
    var body: some View {
        Capsule()
            .fill(.white.opacity(0.8))
            .frame(width: 132, height: 5)
    }
}
