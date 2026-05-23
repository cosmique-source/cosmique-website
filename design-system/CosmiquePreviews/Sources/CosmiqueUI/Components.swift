// Cosmique — SwiftUI component layer. The mirror of css/components.css.
// Tokens (Tokens.swift) are values; this file turns them into reusable type,
// modifiers, and small components so SwiftUI screens match the web.
import SwiftUI

// MARK: - Typography

public extension Cosmique {
    enum TextRole {
        case h1, h2, h3, body, small, kicker, mono
    }

    /// Base font for a role (size + weight from the tokens).
    static func font(_ role: TextRole) -> Font {
        switch role {
        case .h1:     return .system(size: Size.h1, weight: .bold)
        case .h2:     return .system(size: Size.h2, weight: .bold)
        case .h3:     return .system(size: Size.h3, weight: .bold)
        case .body:   return .system(size: Size.body, weight: .regular)
        case .small:  return .system(size: Size.small, weight: .regular)
        case .kicker: return .system(size: Size.kicker, weight: .medium)
        case .mono:   return .system(size: Size.small, weight: .regular, design: .monospaced)
        }
    }
}

public extension Text {
    /// Apply a Cosmique text role (font + letter-spacing) to a Text.
    func cosmique(_ role: Cosmique.TextRole) -> Text {
        switch role {
        case .h1:     return font(Cosmique.font(.h1)).tracking(-1.0)
        case .h2:     return font(Cosmique.font(.h2)).tracking(-0.3)
        case .h3:     return font(Cosmique.font(.h3)).tracking(-0.2)
        case .body:   return font(Cosmique.font(.body))
        case .small:  return font(Cosmique.font(.small))
        case .kicker: return font(Cosmique.font(.kicker)).tracking(2.6)
        case .mono:   return font(Cosmique.font(.mono))
        }
    }
}

// MARK: - Kicker label (brick dot + uppercase tracked label)

public struct KickerLabel: View {
    private let text: String
    public init(_ text: String) { self.text = text }
    public var body: some View {
        HStack(spacing: 12) {
            Circle().fill(Cosmique.Color.accent).frame(width: 6, height: 6)
            Text(text.uppercased())
                .cosmique(.kicker)
                .foregroundStyle(Cosmique.Color.muted)
        }
    }
}

// MARK: - Chip / pill

public struct Pill: View {
    private let text: String
    private let accent: Bool
    public init(_ text: String, accent: Bool = false) {
        self.text = text; self.accent = accent
    }
    public var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(accent ? Cosmique.Color.accent : Cosmique.Color.muted)
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .overlay(
                RoundedRectangle(cornerRadius: Cosmique.Radius.sm)
                    .strokeBorder(accent ? Cosmique.Color.accent : Cosmique.Color.hair)
            )
    }
}

// MARK: - Card surface

public extension View {
    /// A hairline-bordered card surface on the card token, like .card in CSS.
    func cosmiqueCard(padding: CGFloat = Cosmique.Space.md) -> some View {
        self
            .padding(padding)
            .background(Cosmique.Color.card)
            .clipShape(RoundedRectangle(cornerRadius: Cosmique.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Cosmique.Radius.md)
                    .strokeBorder(Cosmique.Color.hair)
            )
    }

    /// Fill the available space on the paper background — handy for full screens.
    func cosmiqueScreen() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Cosmique.Color.paper)
    }
}

// MARK: - Primary button

public struct CosmiquePrimaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: Cosmique.Size.small, weight: .medium))
            .foregroundStyle(Cosmique.Color.paper)
            .padding(.horizontal, Cosmique.Space.md)
            .padding(.vertical, Cosmique.Space.sm)
            .background(configuration.isPressed ? Cosmique.Color.accent : Cosmique.Color.ink)
            .clipShape(RoundedRectangle(cornerRadius: Cosmique.Radius.sm))
    }
}

public extension ButtonStyle where Self == CosmiquePrimaryButtonStyle {
    static var cosmiquePrimary: CosmiquePrimaryButtonStyle { .init() }
}
