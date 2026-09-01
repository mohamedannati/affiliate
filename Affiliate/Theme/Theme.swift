//
//  Theme.swift
//  Affiliate
//
//  Central design system: colors, gradients, typography and haptics.
//

import SwiftUI
import UIKit

// MARK: - Brand Colors

extension Color {
    /// Hex initialiser for a precise, consistent palette.
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    // Core palette
    static let brandBackground = Color(hex: 0x0B0E15)
    static let brandSurface = Color(hex: 0x121726)
    static let brandSurfaceElevated = Color(hex: 0x1A2132)

    // Accents
    static let brandGreen = Color(hex: 0x00D084)
    static let brandGreenDark = Color(hex: 0x009E63)
    static let brandGold = Color(hex: 0xF6C445)
    static let brandGoldSoft = Color(hex: 0xFFE08A)

    // Text
    static let brandText = Color.white
    static let brandTextSecondary = Color(hex: 0x9AA3B2)

    // Semantics
    static let brandDanger = Color(hex: 0xFF5A6E)
    static let brandDivider = Color.white.opacity(0.08)
}

// MARK: - ShapeStyle support
//
// SwiftUI resolves leading-dot color names (e.g. `.foregroundStyle(.brandText)`)
// against `ShapeStyle`, not `Color`. Mirroring the palette on ShapeStyle lets
// every brand color be used directly as a foreground/background style.

extension ShapeStyle where Self == Color {
    static var brandBackground: Color { Color.brandBackground }
    static var brandSurface: Color { Color.brandSurface }
    static var brandSurfaceElevated: Color { Color.brandSurfaceElevated }
    static var brandGreen: Color { Color.brandGreen }
    static var brandGreenDark: Color { Color.brandGreenDark }
    static var brandGold: Color { Color.brandGold }
    static var brandGoldSoft: Color { Color.brandGoldSoft }
    static var brandText: Color { Color.brandText }
    static var brandTextSecondary: Color { Color.brandTextSecondary }
    static var brandDanger: Color { Color.brandDanger }
    static var brandDivider: Color { Color.brandDivider }
}

// MARK: - Gradients

extension LinearGradient {
    static let brand = LinearGradient(
        colors: [Color.brandGreen, Color.brandGreenDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gold = LinearGradient(
        colors: [Color.brandGoldSoft, Color.brandGold, Color(hex: 0xD99A1F)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let surface = LinearGradient(
        colors: [Color.brandSurfaceElevated, Color.brandSurface],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography

extension Font {
    /// Rounded display font used for headings and buttons.
    static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// Monospaced font used for numbers and odds.
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Haptics

enum Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

// MARK: - View Helpers

/// Applies the standard card styling used across the app.
struct CardStyle: ViewModifier {
    var cornerRadius: CGFloat = 24
    var fill: Color = .brandSurface
    var padding: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.brandDivider, lineWidth: 1)
                    )
            )
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 24,
                   fill: Color = .brandSurface,
                   padding: CGFloat = 18) -> some View {
        modifier(CardStyle(cornerRadius: cornerRadius, fill: fill, padding: padding))
    }
}
