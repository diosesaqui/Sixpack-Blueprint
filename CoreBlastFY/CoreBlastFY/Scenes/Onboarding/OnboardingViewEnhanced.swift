//
//  OnboardingViewEnhanced.swift
//  Sixpack Blueprint
//
//  Rebuilt for 7-step lean funnel — pain first, paywall fast.
//

import SwiftUI
import StoreKit

// MARK: - Main Container

struct OnboardingViewEnhanced: View {
    @State private var currentStep = 0
    @State private var selectedStruggle = ""
    @State private var selectedGoal = ""
    @State private var selectedBodyType = ""
    @State private var selectedAge = ""
    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: showContent)

            Group {
                switch currentStep {
                case 0:
                    PainHookView(currentStep: $currentStep, selectedStruggle: $selectedStruggle)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .leading).combined(with: .opacity)))
                case 1:
                    GoalSelectionView(currentStep: $currentStep, selectedGoal: $selectedGoal)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .leading).combined(with: .opacity)))
                case 2:
                    BodyTypeView(currentStep: $currentStep, selectedBodyType: $selectedBodyType)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .leading).combined(with: .opacity)))
                case 3:
                    AgeView(currentStep: $currentStep, selectedAge: $selectedAge)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .leading).combined(with: .opacity)))
                case 4:
                    PlanBuildingView(currentStep: $currentStep,
                                     selectedGoal: selectedGoal,
                                     selectedBodyType: selectedBodyType,
                                     selectedStruggle: selectedStruggle)
                        .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity),
                                                removal: .scale(scale: 1.1).combined(with: .opacity)))
                case 5:
                    PlanReadyView(currentStep: $currentStep, selectedGoal: selectedGoal, selectedAge: selectedAge)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .leading).combined(with: .opacity)))
                case 6:
                    SubscriptionViewEnhanced { success in
                        HapticFeedbackManager.shared.cancelAllPendingHaptics()
                        OnboardingManager.markOnboardingCompleted()
                        OnboardingViewController.completion?()
                    }
                    .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity),
                                            removal: .scale(scale: 1.05).combined(with: .opacity)))
                default:
                    EmptyView()
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.82), value: currentStep)
        }
        .onAppear {
            AnalyticsManager.shared.trackOnboardingStarted()
            withAnimation(.easeOut(duration: 0.4)) { showContent = true }
        }
        .onChange(of: currentStep) { step in
            HapticFeedbackManager.shared.stepTransition()
            let names = ["pain_hook","goal","body_type","age","plan_building","plan_ready","paywall"]
            if step < names.count {
                AnalyticsManager.shared.trackOnboardingStep(step: names[step], stepNumber: step)
            }
        }
    }
}

// MARK: - Shared Progress Bar

struct SlimProgressBar: View {
    let current: Int   // 0-based current step (exclude paywall from bar)
    let total: Int     // total steps to show (5 — steps 0-4, step 5 is plan ready which feels like completion)

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i <= current ? Color.white : Color.white.opacity(0.25))
                    .frame(height: 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: current)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Shared Option Card

struct OnboardingOptionCard: View {
    let text: String
    let emoji: String
    let isSelected: Bool
    let index: Int
    let action: () -> Void
    @State private var appeared = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 22))
                    .frame(width: 36)
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.white.opacity(0.6) : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .scaleEffect(appeared ? 1 : 0.92)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(Double(index) * 0.07), value: appeared)
        .onAppear { appeared = true }
    }
}

// MARK: - Step 0: Pain Hook

struct PainHookView: View {
    @Binding var currentStep: Int
    @Binding var selectedStruggle: String
    @State private var selectedIndex: Int? = nil
    @State private var showContent = false

    let options: [(emoji: String, text: String)] = [
        ("😞", "My belly won't flatten no matter what I do"),
        ("😤", "I can't stay consistent with workouts"),
        ("🙈", "I have love handles I can't get rid of"),
        ("🤔", "I look slim but still have visible belly fat")
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SlimProgressBar(current: 0, total: 5)
                    .padding(.top, 60)

                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Which of these\nsounds like you?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                    Text("Choose the one that hits closest to home.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.55))
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 32)

                VStack(spacing: 12) {
                    ForEach(options.indices, id: \.self) { i in
                        OnboardingOptionCard(
                            text: options[i].text,
                            emoji: options[i].emoji,
                            isSelected: selectedIndex == i,
                            index: i
                        ) {
                            selectedIndex = i
                            selectedStruggle = options[i].text
                            // Request ATT permission on first onboarding interaction
                            if !FacebookManager.shared.hasRequestedATT {
                                FacebookManager.shared.requestATTPermission()
                            }
                            HapticFeedbackManager.shared.selectionChanged()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                                withAnimation { currentStep += 1 }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onAppear {
            withAnimation { showContent = true }
        }
    }
}

// MARK: - Step 1: Goal Selection

struct GoalSelectionView: View {
    @Binding var currentStep: Int
    @Binding var selectedGoal: String
    @State private var selectedIndex: Int? = nil
    @State private var showContent = false

    let options: [(emoji: String, text: String)] = [
        ("🎯", "Visible six-pack abs"),
        ("🔥", "Flat stomach & less belly fat"),
        ("💪", "Stronger, more stable core"),
        ("🧘", "Better posture & less back pain")
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SlimProgressBar(current: 1, total: 5)
                    .padding(.top, 60)

                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("What do you\nwant most?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                    Text("We'll build your plan around your #1 goal.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.55))
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 32)

                VStack(spacing: 12) {
                    ForEach(options.indices, id: \.self) { i in
                        OnboardingOptionCard(
                            text: options[i].text,
                            emoji: options[i].emoji,
                            isSelected: selectedIndex == i,
                            index: i
                        ) {
                            selectedIndex = i
                            selectedGoal = options[i].text
                            HapticFeedbackManager.shared.selectionChanged()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                                withAnimation { currentStep += 1 }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onAppear { withAnimation { showContent = true } }
    }
}

// MARK: - Step 2: Body Type

struct BodyTypeView: View {
    @Binding var currentStep: Int
    @Binding var selectedBodyType: String
    @State private var selectedIndex: Int? = nil
    @State private var showContent = false

    let options: [(emoji: String, text: String)] = [
        ("🧍", "Slim but soft — not much muscle"),
        ("🙆", "Average build — a bit of belly fat"),
        ("🏃", "Athletic but want more definition"),
        ("⚖️", "Carrying extra weight, especially around the core")
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SlimProgressBar(current: 2, total: 5)
                    .padding(.top, 60)

                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your body\nlike right now?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                    Text("Be honest — your plan only works if it fits you.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.55))
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 32)

                VStack(spacing: 12) {
                    ForEach(options.indices, id: \.self) { i in
                        OnboardingOptionCard(
                            text: options[i].text,
                            emoji: options[i].emoji,
                            isSelected: selectedIndex == i,
                            index: i
                        ) {
                            selectedIndex = i
                            selectedBodyType = options[i].text
                            HapticFeedbackManager.shared.selectionChanged()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                                withAnimation { currentStep += 1 }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onAppear { withAnimation { showContent = true } }
    }
}

// MARK: - Step 3: Age

struct AgeView: View {
    @Binding var currentStep: Int
    @Binding var selectedAge: String
    @State private var selectedIndex: Int? = nil
    @State private var showContent = false

    let options: [(emoji: String, text: String)] = [
        ("🔥", "18–25"),
        ("💪", "26–35"),
        ("⚡", "36–45"),
        ("🏆", "46+")
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                SlimProgressBar(current: 3, total: 5)
                    .padding(.top, 60)

                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("How old are you?")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                    Text("Your plan adapts to your age and metabolism.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.55))
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 32)

                VStack(spacing: 12) {
                    ForEach(options.indices, id: \.self) { i in
                        OnboardingOptionCard(
                            text: options[i].text,
                            emoji: options[i].emoji,
                            isSelected: selectedIndex == i,
                            index: i
                        ) {
                            selectedIndex = i
                            selectedAge = options[i].text
                            HapticFeedbackManager.shared.selectionChanged()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                                withAnimation { currentStep += 1 }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onAppear { withAnimation { showContent = true } }
    }
}

// MARK: - Step 4: Plan Building (auto-advances)

struct PlanBuildingView: View {
    @Binding var currentStep: Int
    let selectedGoal: String
    let selectedBodyType: String
    let selectedStruggle: String

    @State private var progress: CGFloat = 0
    @State private var currentLabel = "Analyzing your profile..."
    @State private var isSpinning = false
    @State private var showChecks = false

    let labels = [
        "Analyzing your profile...",
        "Mapping your core weaknesses...",
        "Selecting targeted exercises...",
        "Calibrating intensity levels...",
        "Your plan is ready."
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                SlimProgressBar(current: 4, total: 5)
                    .padding(.top, 60)

                Spacer()

                VStack(spacing: 36) {
                    // Spinner
                    ZStack {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.cyan, Color(red: 0.4, green: 0.7, blue: 0.6)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 2
                                )
                                .frame(width: 70 + CGFloat(i * 22), height: 70 + CGFloat(i * 22))
                                .rotationEffect(.degrees(isSpinning ? Double(360 * (i % 2 == 0 ? 1 : -1)) : 0))
                                .animation(.linear(duration: Double(2 + i)).repeatForever(autoreverses: false), value: isSpinning)
                        }
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                    .frame(height: 140)

                    // Status label
                    Text(currentLabel)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .id(currentLabel)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .animation(.easeInOut(duration: 0.4), value: currentLabel)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.15)).frame(height: 8)
                            Capsule()
                                .fill(LinearGradient(colors: [Color.cyan, Color(red: 0.4, green: 0.7, blue: 0.6)],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * progress, height: 8)
                                .animation(.easeOut(duration: 0.5), value: progress)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 40)

                    // Input summary
                    VStack(spacing: 10) {
                        InputSummaryRow(label: "Struggle", value: selectedStruggle.isEmpty ? "—" : selectedStruggle, visible: showChecks)
                        InputSummaryRow(label: "Goal", value: selectedGoal.isEmpty ? "—" : selectedGoal, visible: showChecks)
                        InputSummaryRow(label: "Body type", value: selectedBodyType.isEmpty ? "—" : selectedBodyType, visible: showChecks)
                    }
                    .padding(.horizontal, 40)
                }

                Spacer()
            }
        }
        .onAppear {
            isSpinning = true

            // Cycle labels and progress
            let stepDuration = 0.55
            for (i, label) in labels.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                    withAnimation { currentLabel = label }
                    withAnimation { progress = CGFloat(i + 1) / CGFloat(labels.count) }
                    if i == 1 { withAnimation { showChecks = true } }
                    HapticFeedbackManager.shared.progressUpdate()
                }
            }

            // Auto-advance after all labels
            let totalDelay = Double(labels.count) * stepDuration + 0.6
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
                HapticFeedbackManager.shared.celebrationPattern()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    currentStep += 1
                }
            }
        }
    }
}

struct InputSummaryRow: View {
    let label: String
    let value: String
    let visible: Bool
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 16))
            VStack(alignment: .leading, spacing: 1) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer()
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1), value: appeared)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { appeared = true }
        }
    }
}

// MARK: - Step 5: Plan Ready (pre-paywall hype)

struct PlanReadyView: View {
    @Binding var currentStep: Int
    let selectedGoal: String
    let selectedAge: String
    @State private var showContent = false
    @State private var showBullets = false

    let bullets: [(String, String)] = [
        ("⚡", "5-minute daily workouts — no equipment"),
        ("📈", "Progressive difficulty that grows with you"),
        ("🎯", "Exercises targeting your exact weak points"),
        ("🔔", "Daily reminders to keep you on track")
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    // Badge
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [Color.cyan, Color(red: 0.4, green: 0.7, blue: 0.6)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 90, height: 90)
                            .scaleEffect(showContent ? 1 : 0.5)
                            .opacity(showContent ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1), value: showContent)
                        Image(systemName: "checkmark")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(showContent ? 1 : 0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.25), value: showContent)
                    }

                    VStack(spacing: 10) {
                        Text("Your plan is ready.")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                        Text("Join 50,000+ people already building their best core.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                    }

                    // Bullets
                    VStack(spacing: 14) {
                        ForEach(bullets.indices, id: \.self) { i in
                            HStack(spacing: 14) {
                                Text(bullets[i].0).font(.system(size: 20))
                                Text(bullets[i].1)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 32)
                            .opacity(showBullets ? 1 : 0)
                            .offset(x: showBullets ? 0 : -24)
                            .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(i) * 0.1), value: showBullets)
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer()

                // CTA
                VStack(spacing: 12) {
                    Button(action: {
                        HapticFeedbackManager.shared.impact(.heavy)
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    }) {
                        Text("SEE MY PLAN →")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: Color.white.opacity(0.25), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.9)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.7), value: showContent)

                    Text("No payment needed to see your plan")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.85), value: showContent)
                }
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation { showContent = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showBullets = true }
            }
        }
    }
}
