import SwiftUI

enum Royal {
    static let void = Color(red: 9 / 255, green: 6 / 255, blue: 11 / 255)
    static let gold = Color(red: 255 / 255, green: 211 / 255, blue: 106 / 255)
    static let goldSoft = Color(red: 255 / 255, green: 241 / 255, blue: 184 / 255)
    static let crimson = Color(red: 255 / 255, green: 51 / 255, blue: 77 / 255)
    static let wine = Color(red: 141 / 255, green: 12 / 255, blue: 19 / 255)
    static let cream = Color(red: 255 / 255, green: 248 / 255, blue: 232 / 255)
    static let muted = Color(red: 201 / 255, green: 185 / 255, blue: 172 / 255)
    static let bronze = Color(red: 110 / 255, green: 73 / 255, blue: 53 / 255)
    static let antique = Color(red: 169 / 255, green: 106 / 255, blue: 22 / 255)
    static let reelCream = Color(red: 255 / 255, green: 249 / 255, blue: 239 / 255)
    static let reelWood = Color(red: 74 / 255, green: 43 / 255, blue: 32 / 255)
    static let reelLine = Color(red: 214 / 255, green: 185 / 255, blue: 138 / 255)
    static let panel = Color(red: 21 / 255, green: 17 / 255, blue: 28 / 255).opacity(0.80)
    static let panelDeep = Color(red: 33 / 255, green: 20 / 255, blue: 31 / 255).opacity(0.93)
    static let banner = Color(red: 59 / 255, green: 7 / 255, blue: 16 / 255)
    static let winGreen = Color(red: 100 / 255, green: 242 / 255, blue: 167 / 255)
    static let minusFill = Color(red: 74 / 255, green: 16 / 255, blue: 25 / 255)
    static let overlay = Color(red: 9 / 255, green: 4 / 255, blue: 10 / 255)

    static func black(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black)
    }

    static func extra(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy)
    }

    static func bold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold)
    }

    static func semi(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold)
    }
}

struct PressScale: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct GoldHalo: ViewModifier {
    var radius: CGFloat = 10
    func body(content: Content) -> some View {
        content
            .shadow(color: Royal.gold.opacity(0.45), radius: radius)
            .shadow(color: Color(red: 1, green: 176 / 255, blue: 0).opacity(0.55), radius: 5, y: 4)
    }
}
