//
//  CyberpunkTheme.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 05. 05..
//

import SwiftUI

enum CyberpunkTheme {
    static let background = Color(red: 0.02, green: 0.02, blue: 0.03)
    static let panelFill = Color.white.opacity(0.05)
    static let panelStroke = Color.white.opacity(0.14)
    static let cyan = Color(red: 0.0, green: 0.95, blue: 1.0)
    static let magenta = Color(red: 1.0, green: 0.0, blue: 1.0)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)

    // Table styling colors for leaderboard
    static let rowBackgroundPrimary = Color.white.opacity(0.05)
    static let rowBackgroundSecondary = Color.white.opacity(0.08)
    static let tableHeaderFill = Color.white.opacity(0.08)
    static let tableRowHoverHighlight = Color.white.opacity(0.12)

    static var backdropGradient: LinearGradient {
        LinearGradient(
            colors: [Color.black.opacity(0.96), background, Color.black.opacity(0.98)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct CyberBackdrop: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CyberpunkTheme.backdropGradient

                RadialGradient(
                    colors: [CyberpunkTheme.cyan.opacity(0.20), .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: max(proxy.size.width, proxy.size.height) * 0.9
                )

                RadialGradient(
                    colors: [CyberpunkTheme.magenta.opacity(0.14), .clear],
                    center: .bottomTrailing,
                    startRadius: 0,
                    endRadius: max(proxy.size.width, proxy.size.height) * 0.85
                )

                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    Canvas { context, size in
                        drawGrid(in: context, size: size, phase: timeline.date.timeIntervalSinceReferenceDate)
                    }
                    .blendMode(.screen)
                    .opacity(0.45)
                }

                LinearGradient(
                    colors: [Color.black.opacity(0.05), Color.black.opacity(0.42)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        }
    }

    private func drawGrid(in context: GraphicsContext, size: CGSize, phase: TimeInterval) {
        let horizontalSpacing: CGFloat = 42
        let verticalSpacing: CGFloat = 56
        let horizontalShift = CGFloat(phase * 18).truncatingRemainder(dividingBy: horizontalSpacing)
        let verticalShift = CGFloat(phase * 10).truncatingRemainder(dividingBy: verticalSpacing)

        var horizontal = Path()
        var y = -horizontalShift
        while y <= size.height + horizontalSpacing {
            horizontal.move(to: CGPoint(x: 0, y: y))
            horizontal.addLine(to: CGPoint(x: size.width, y: y))
            y += horizontalSpacing
        }

        var vertical = Path()
        var x = -verticalShift
        while x <= size.width + verticalSpacing {
            vertical.move(to: CGPoint(x: x, y: 0))
            vertical.addLine(to: CGPoint(x: x, y: size.height))
            x += verticalSpacing
        }

        context.stroke(
            horizontal,
            with: .color(CyberpunkTheme.cyan.opacity(0.10)),
            lineWidth: 0.8
        )
        context.stroke(
            vertical,
            with: .color(CyberpunkTheme.magenta.opacity(0.075)),
            lineWidth: 0.8
        )
    }
}

struct CyberPanel: ViewModifier {
    var accent: Color = CyberpunkTheme.cyan
    var fillOpacity: Double = 0.08
    var scale: CGFloat = 1.0
    var contentPadding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(contentPadding * scale)
            .background(
                RoundedRectangle(cornerRadius: 18 * scale, style: .continuous)
                    .fill(CyberpunkTheme.panelFill.opacity(fillOpacity / 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18 * scale, style: .continuous)
                            .stroke(accent.opacity(0.55), lineWidth: 1.2 * scale)
                    )
                    .shadow(color: accent.opacity(0.18), radius: 14 * scale, x: 0, y: 0)
                    .shadow(color: .black.opacity(0.35), radius: 18 * scale, x: 0, y: 10 * scale)
            )
    }
}

extension View {
    func cyberPanel(accent: Color = CyberpunkTheme.cyan, fillOpacity: Double = 0.08, scale: CGFloat = 1.0, contentPadding: CGFloat = 16) -> some View {
        modifier(CyberPanel(accent: accent, fillOpacity: fillOpacity, scale: scale, contentPadding: contentPadding))
    }
}

struct NeonButtonStyle: ButtonStyle {
    var accent: Color = CyberpunkTheme.cyan
    var fillOpacity: Double = 0.12
    var cornerRadius: CGFloat = 14
    var fillsWidth: Bool = false
    var scale: CGFloat = 1.0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(CyberpunkTheme.textPrimary)
            .padding(.horizontal, 16 * scale)
            .padding(.vertical, 12 * scale)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius * scale, style: .continuous)
                    .fill(Color.white.opacity(fillOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius * scale, style: .continuous)
                            .stroke(accent.opacity(configuration.isPressed ? 1.0 : 0.8), lineWidth: 1.4 * scale)
                    )
            )
            .shadow(color: accent.opacity(configuration.isPressed ? 0.50 : 0.30), radius: configuration.isPressed ? 18 * scale : 12 * scale)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

struct CompactNeonButtonStyle: ButtonStyle {
    var accent: Color = CyberpunkTheme.cyan
    var isIconOnly: Bool = false
    var isPulsing: Bool = false
    var scale: CGFloat = 1.0

    func makeBody(configuration: Configuration) -> some View {
        TimelineView(.animation(minimumInterval: 0.05)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.0)
            let pulsePhase = sin(elapsed * .pi)
            
            configuration.label
                .foregroundStyle(accent.opacity(configuration.isPressed ? 1.0 : 0.9))
                .padding(.horizontal, (isIconOnly ? 8 : 12) * scale)
                .padding(.vertical, 8 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 12 * scale, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12 * scale, style: .continuous)
                                .stroke(accent.opacity(configuration.isPressed ? 0.9 : 0.7), lineWidth: 1.2 * scale)
                        )
                )
                .shadow(
                    color: accent.opacity(configuration.isPressed ? 0.35 : (isPulsing ? 0.15 + pulsePhase * 0.2 : 0.15)),
                    radius: configuration.isPressed ? 10 * scale : (isPulsing ? (6 + pulsePhase * 4) * scale : 6 * scale)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
        }
    }
}
