//
//  AnimationExtensions.swift
//  Sixpack Blueprint
//
//  Created by Assistant on 12/23/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import SwiftUI

// MARK: - Animation Modifiers

extension View {
    func fadeInAnimation(delay: Double = 0) -> some View {
        self
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeOut(duration: 0.4).delay(delay), value: UUID())
    }
    
    func slideInAnimation(from edge: Edge = .trailing, delay: Double = 0) -> some View {
        self
            .transition(.asymmetric(
                insertion: .move(edge: edge).combined(with: .opacity),
                removal: .move(edge: edge.opposite).combined(with: .opacity)
            ))
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: UUID())
    }
    
    func bounceAnimation(amount: CGFloat = 1.1, duration: Double = 0.3) -> some View {
        self
            .scaleEffect(amount)
            .animation(.spring(response: duration, dampingFraction: 0.6), value: amount)
    }
    
    func pulseAnimation(isPulsing: Bool) -> some View {
        self
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.9 : 1.0)
            .animation(isPulsing ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: isPulsing)
    }
    
    func shimmerEffect(isAnimating: Bool) -> some View {
        self.overlay(
            GeometryReader { geometry in
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width * 0.3)
                .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                .animation(
                    isAnimating ? .linear(duration: 1.5).repeatForever(autoreverses: false) : .default,
                    value: isAnimating
                )
            }
            .allowsHitTesting(false)
        )
        .mask(self)
    }
    
    func staggeredAnimation(index: Int, totalCount: Int) -> some View {
        self
            .opacity(0)
            .offset(y: 20)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.8)
                .delay(Double(index) * 0.1),
                value: index
            )
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                    self.opacity(1).offset(y: 0)
                }
            }
    }
    
    func glowEffect(color: Color = .white, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: radius)
            .shadow(color: color.opacity(0.3), radius: radius * 2)
    }
    
    func parallaxEffect(offset: CGFloat, multiplier: CGFloat = 0.5) -> some View {
        self.offset(y: offset * multiplier)
    }
}

// MARK: - Edge Extension

extension Edge {
    var opposite: Edge {
        switch self {
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }
}

// MARK: - Button Style Modifiers

struct PressableButtonStyle: ButtonStyle {
    let hapticFeedback: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed && hapticFeedback {
                    HapticFeedbackManager.shared.buttonTap()
                }
            }
    }
}

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    HapticFeedbackManager.shared.buttonTap()
                }
            }
    }
}

extension View {
    func pressableButton(withHaptics: Bool = true) -> some View {
        self.buttonStyle(PressableButtonStyle(hapticFeedback: withHaptics))
    }
    
    func bounceButton() -> some View {
        self.buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Loading Animation Views

struct LoadingDots: View {
    @State private var animating = false
    let dotsCount = 3
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<dotsCount, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .opacity(animating ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

struct CircularProgressAnimation: View {
    @State private var isAnimating = false
    let lineWidth: CGFloat = 3
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [Color.goatBlue, Color.cyan]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Particle Effects

struct ParticleEffect: View {
    @State private var particles: [Particle] = []
    let particleCount = 20
    let colors: [Color] = [.yellow, .orange, .red, .pink, .purple]
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .animation(.easeOut(duration: particle.duration), value: particle.y)
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        for _ in 0..<particleCount {
            let particle = Particle(
                color: colors.randomElement() ?? .yellow,
                size: CGFloat.random(in: 4...12),
                x: CGFloat.random(in: -100...100),
                y: 0,
                opacity: 1.0,
                duration: Double.random(in: 1.0...2.0)
            )
            particles.append(particle)
            
            withAnimation(.easeOut(duration: particle.duration)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].y = CGFloat.random(in: -200 ... -100)
                    particles[index].opacity = 0
                }
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    let duration: Double
}

// MARK: - Success Checkmark Animation

struct SuccessCheckmark: View {
    @State private var animateCheckmark = false
    @State private var animateCircle = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green, lineWidth: 4)
                .frame(width: 60, height: 60)
                .scaleEffect(animateCircle ? 1.0 : 0.0)
                .opacity(animateCircle ? 1.0 : 0.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateCircle)
            
            Path { path in
                path.move(to: CGPoint(x: 15, y: 30))
                path.addLine(to: CGPoint(x: 25, y: 40))
                path.addLine(to: CGPoint(x: 45, y: 20))
            }
            .trim(from: 0, to: animateCheckmark ? 1 : 0)
            .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .animation(.easeOut(duration: 0.4).delay(0.2), value: animateCheckmark)
        }
        .onAppear {
            animateCircle = true
            animateCheckmark = true
            HapticFeedbackManager.shared.notification(.success)
        }
    }
}
