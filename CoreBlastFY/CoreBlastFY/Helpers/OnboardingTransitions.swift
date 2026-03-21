//
//  OnboardingTransitions.swift
//  Sixpack Blueprint
//
//  Created by Assistant on 12/23/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import SwiftUI

// MARK: - Custom Transitions

struct SlideAndFadeTransition: ViewModifier {
    let isActive: Bool
    let edge: Edge
    
    func body(content: Content) -> some View {
        content
            .offset(x: offsetX, y: offsetY)
            .opacity(isActive ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isActive)
    }
    
    private var offsetX: CGFloat {
        guard !isActive else { return 0 }
        switch edge {
        case .leading: return -50
        case .trailing: return 50
        default: return 0
        }
    }
    
    private var offsetY: CGFloat {
        guard !isActive else { return 0 }
        switch edge {
        case .top: return -50
        case .bottom: return 50
        default: return 0
        }
    }
}

struct ScaleAndRotateTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1 : 0.8)
            .rotationEffect(.degrees(isActive ? 0 : 10))
            .opacity(isActive ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isActive)
    }
}

struct CardFlipTransition: ViewModifier {
    let isFlipped: Bool
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
    }
}

// MARK: - Page Transition Manager

struct OnboardingPageTransition: ViewModifier {
    let currentStep: Int
    let stepIndex: Int
    let direction: TransitionDirection
    
    enum TransitionDirection {
        case forward, backward
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(x: offsetX)
            .scaleEffect(isVisible ? 1 : 0.95)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
    }
    
    private var isVisible: Bool {
        currentStep == stepIndex
    }
    
    private var offsetX: CGFloat {
        if currentStep == stepIndex {
            return 0
        } else if currentStep < stepIndex {
            return UIScreen.main.bounds.width
        } else {
            return -UIScreen.main.bounds.width
        }
    }
}

// MARK: - Animated Progress Indicator

//struct AnimatedProgressIndicator: View {
//    let currentStep: Int
//    let totalSteps: Int
//    @State private var animateProgress = false
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .leading) {
//                // Background track
//                RoundedRectangle(cornerRadius: 2)
//                    .fill(Color.white.opacity(0.2))
//                    .frame(height: 4)
//                
//                // Progress fill
//                RoundedRectangle(cornerRadius: 2)
//                    .fill(
//                        LinearGradient(
//                            gradient: Gradient(colors: [Color.goatBlue, Color.cyan]),
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                    )
//                    .frame(width: progressWidth(in: geometry.size.width), height: 4)
//                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
//                
//                // Glowing dot at the end
//                if currentStep < totalSteps {
//                    Circle()
//                        .fill(Color.white)
//                        .frame(width: 8, height: 8)
//                        .glowEffect(color: .cyan, radius: 4)
//                        .offset(x: progressWidth(in: geometry.size.width) - 4)
//                        .pulseAnimation(isPulsing: animateProgress)
//                }
//            }
//        }
//        .frame(height: 4)
//        .padding(.horizontal, 40)
//        .onAppear {
//            animateProgress = true
//        }
//        .onChange(of: currentStep) { _ in
//            HapticFeedbackManager.shared.progressUpdate()
//        }
//    }
//    
//    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
//        let progress = CGFloat(currentStep + 1) / CGFloat(totalSteps)
//        return totalWidth * progress
//    }
//}

// MARK: - Animated Option Card

//struct AnimatedOptionCard: View {
//    let text: String
//    let isSelected: Bool
//    let index: Int
//    let action: () -> Void
//    
//    @State private var isPressed = false
//    @State private var showContent = false
//    
//    var body: some View {
//        Button(action: {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                isPressed = true
//            }
//            
//            // Use stronger rhythmic selection haptics
//            HapticFeedbackManager.shared.rhythmicSelection()
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                isPressed = false
//                action()
//            }
//        }) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(
//                        LinearGradient(
//                            gradient: Gradient(colors: [
//                                Color.gray.opacity(isSelected ? 0.5 : 0.3),
//                                Color.gray.opacity(isSelected ? 0.4 : 0.25)
//                            ]),
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(
//                                isSelected ? Color.goatBlue : Color.clear,
//                                lineWidth: 2
//                            )
//                    )
//                
//                HStack {
//                    Text(text)
//                        .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
//                        .foregroundColor(.white)
//                    
//                    Spacer()
//                    
//                    if isSelected {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(.goatBlue)
//                            .transition(.scale.combined(with: .opacity))
//                    }
//                }
//                .padding(.horizontal, 20)
//            }
//            .frame(height: 56)
//            .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.02 : 1.0))
//            .opacity(showContent ? 1 : 0)
//            .offset(y: showContent ? 0 : 20)
//        }
//        .onAppear {
//            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08)) {
//                showContent = true
//            }
//        }
//    }
//}

// MARK: - Celebration View

struct CelebrationView: View {
    @State private var showParticles = false
    @State private var scaleIcon = false
    @State private var rotateIcon = false
    
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    
    var body: some View {
        ZStack {
            // Particles
            if showParticles {
                ParticleEffect()
                    .allowsHitTesting(false)
            }
            
            VStack(spacing: 30) {
                // Animated Icon
                ZStack {
                    // Pulsing rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(iconColor.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                            .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                            .scaleEffect(scaleIcon ? 1.2 : 1.0)
                            .opacity(scaleIcon ? 0 : 1)
                            .animation(
                                .easeOut(duration: 1.5)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: scaleIcon
                            )
                    }
                    
                    // Main icon circle
                    Circle()
                        .fill(iconColor.opacity(0.8))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: iconName)
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        )
                        .scaleEffect(scaleIcon ? 1.1 : 1.0)
                        .rotationEffect(.degrees(rotateIcon ? 360 : 0))
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.6),
                            value: scaleIcon
                        )
                        .animation(
                            .easeInOut(duration: 1.0),
                            value: rotateIcon
                        )
                }
                
                // Text
                VStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                .fadeInAnimation(delay: 0.3)
            }
        }
        .onAppear {
            scaleIcon = true
            rotateIcon = true
            showParticles = true
            HapticFeedbackManager.shared.celebrationPattern()
        }
    }
}

// MARK: - View Extensions

extension View {
    func onboardingPageTransition(currentStep: Int, stepIndex: Int) -> some View {
        self.modifier(OnboardingPageTransition(
            currentStep: currentStep,
            stepIndex: stepIndex,
            direction: .forward
        ))
    }
    
    func slideAndFade(isActive: Bool, from edge: Edge = .trailing) -> some View {
        self.modifier(SlideAndFadeTransition(isActive: isActive, edge: edge))
    }
    
    func scaleAndRotate(isActive: Bool) -> some View {
        self.modifier(ScaleAndRotateTransition(isActive: isActive))
    }
    
    func cardFlip(isFlipped: Bool) -> some View {
        self.modifier(CardFlipTransition(isFlipped: isFlipped))
    }
}
