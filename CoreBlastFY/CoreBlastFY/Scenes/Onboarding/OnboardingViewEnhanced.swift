//
//  OnboardingViewEnhanced.swift
//  Sixpack Blueprint
//
//  Created by Assistant on 12/23/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import SwiftUI
import StoreKit

struct OnboardingViewEnhanced: View {
    @State private var currentStep = 0
    @State private var selectedTimePreference = ""
    @State private var selectedTime = Date()
    @State private var selectedGoal = ""
    @State private var selectedBodyType = ""
    @State private var selectedTrainingTime = ""
    @State private var selectedStruggle = ""
    @State private var selectedAge = ""
    @State private var showContent = false

    var body: some View {
        NavigationView {
            ZStack {
                // Animated background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.black.opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.8), value: showContent)
                
                VStack {
                    if currentStep == 0 {
                        TransformationProofView(currentStep: $currentStep)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentStep == 1 {
                        AgeSelectionView(currentStep: $currentStep, selectedAge: $selectedAge)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentStep == 2 {
                        GoalSelectionViewEnhanced(currentStep: $currentStep, selectedGoal: $selectedGoal)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentStep == 3 {
                        BodyTypeSelectionViewEnhanced(currentStep: $currentStep, selectedBodyType: $selectedBodyType)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentStep == 4 {
                        StruggleSelectionViewEnhanced(currentStep: $currentStep, selectedStruggle: $selectedStruggle)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentStep == 5 {
                        TrainingTimeSelectionViewEnhanced(currentStep: $currentStep, selectedTrainingTime: $selectedTrainingTime)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentStep == 6 {
                        TransformationTimelineView(currentStep: $currentStep)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 1.2).combined(with: .opacity)
                            ))
                    } else if currentStep == 7 {
                        PersonalizedPlanBuildingView(currentStep: $currentStep, selectedGoal: selectedGoal, selectedBodyType: selectedBodyType, selectedTrainingTime: selectedTrainingTime, selectedStruggle: selectedStruggle)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 1.2).combined(with: .opacity)
                            ))
                    } else if currentStep == 8 {
                        SuccessStoriesView(currentStep: $currentStep, selectedAge: selectedAge)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentStep == 9 {
                        CommitmentView(currentStep: $currentStep)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentStep == 10 {
                        DailyReminderViewEnhanced(currentStep: $currentStep, selectedTime: $selectedTime)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentStep == 11 {
                        PreviewWorkoutViewEnhanced(currentStep: $currentStep)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentStep == 12 {
                        SubscriptionViewEnhanced() { success in
                            currentStep += 1
                            // Clean up all haptics before completing onboarding
                            HapticFeedbackManager.shared.cancelAllPendingHaptics()
                            OnboardingManager.markOnboardingCompleted()
                            OnboardingViewController.completion?()
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 1.05).combined(with: .opacity)
                        ))
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
            }
            .navigationBarHidden(true)
            .onChange(of: currentStep) { newStep in
                // Add stronger haptic feedback on step change
                HapticFeedbackManager.shared.stepTransition()
                
                // Add special haptics for milestone steps
                if newStep == 7 {
                    // Plan building excitement
                    HapticFeedbackManager.shared.excitementBuild()
                } else if newStep == 11 {
                    // Preview workout excitement
                    HapticFeedbackManager.shared.excitementBuild()
                } else if newStep == 12 {
                    // Subscription screen
                    HapticFeedbackManager.shared.pulsePattern()
                }
                
                trackOnboardingStep(step: newStep)
            }
        }
        .onAppear {
            AnalyticsManager.shared.trackOnboardingStarted()
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
    
    private func trackOnboardingStep(step: Int) {
        let stepNames = [
            "transformation_proof",
            "age_selection",
            "goal_selection",
            "body_type_selection",
            "struggle_selection",
            "training_time_selection",
            "transformation_timeline",
            "personalized_plan_building",
            "success_stories",
            "commitment",
            "daily_reminder",
            "preview_workout",
            "subscription"
        ]
        
        if step < stepNames.count {
            AnalyticsManager.shared.trackOnboardingStep(
                step: stepNames[step],
                stepNumber: step
            )
        }
    }
}

// MARK: - Transformation Proof View

struct TransformationProofView: View {
    @Binding var currentStep: Int
    @State private var showContent = false
    @State private var currentTransformation = 0
    
    let transformations = [
        TransformationExample(
            beforeImage: "transformation_before_1",
            afterImage: "transformation_after_1", 
            name: "Mike",
            timeframe: "12 weeks",
            age: "28"
        ),
        TransformationExample(
            beforeImage: "transformation_before_2",
            afterImage: "transformation_after_2",
            name: "David",
            timeframe: "8 weeks", 
            age: "35"
        ),
        TransformationExample(
            beforeImage: "transformation_before_3",
            afterImage: "transformation_after_3",
            name: "Alex",
            timeframe: "16 weeks",
            age: "24"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                AnimatedProgressIndicator(currentStep: 0, totalSteps: 12)
                    .padding(.top, 20)
                    .fadeInAnimation()
                
                Spacer()
                
                VStack(spacing: 24) {
                    Text("Real Results From Real People")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                    
                    Text("See what's possible with just 5-10 minutes a day")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .fadeInAnimation(delay: 0.4)
                    
                    // Transformation showcase
                    TransformationCard(transformation: transformations[currentTransformation])
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                    
                    // Transformation indicator dots
                    HStack(spacing: 8) {
                        ForEach(0..<transformations.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentTransformation ? Color.goatBlue : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentTransformation)
                        }
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
                
                Button(action: {
                    HapticFeedbackManager.shared.buttonTap()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep += 1
                    }
                }) {
                    Text("I WANT RESULTS LIKE THIS")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.size.width * 0.8)
                        .padding()
                        .background(Color.goatBlue)
                        .cornerRadius(12)
                }
                .bounceButton()
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            
            // Auto-cycle through transformations
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentTransformation = (currentTransformation + 1) % transformations.count
                }
            }
        }
    }
}

struct TransformationExample {
    let beforeImage: String
    let afterImage: String
    let name: String
    let timeframe: String
    let age: String
}

struct TransformationCard: View {
    let transformation: TransformationExample
    @State private var showAfter = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Before/After Images
            HStack(spacing: 20) {
                VStack {
                    Text("BEFORE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 160)
                        
                        // Placeholder for before image
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                }
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.goatBlue)
                    .scaleEffect(showAfter ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: showAfter)
                
                VStack {
                    Text("AFTER")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 120, height: 160)
                        
                        // Placeholder for after image  
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Transformation details
            VStack(spacing: 8) {
                Text("\(transformation.name), \(transformation.age) years old")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Transformed in \(transformation.timeframe)")
                    .font(.system(size: 14))
                    .foregroundColor(.goatBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.goatBlue.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showAfter = true
            }
        }
    }
}

// MARK: - Age Selection View

struct AgeSelectionView: View {
    @Binding var currentStep: Int
    @Binding var selectedAge: String
    @State private var showContent = false
    @State private var selectedIndex: Int? = nil
    
    let ageRanges = ["18-25", "26-35", "36-45", "46+"]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                AnimatedProgressIndicator(currentStep: 1, totalSteps: 12)
                    .padding(.top, 20)
                    .fadeInAnimation()
                
                Spacer()
                
                Text("What's your age range?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                
                Text("This helps us show you age-matched success stories")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .fadeInAnimation(delay: 0.4)
                
                VStack(spacing: 16) {
                    ForEach(Array(ageRanges.enumerated()), id: \.offset) { index, age in
                        AnimatedOptionCard(
                            text: age,
                            isSelected: selectedIndex == index,
                            index: index,
                            action: {
                                selectedIndex = index
                                selectedAge = age
                                AnalyticsManager.shared.trackAgeSelected(age: age)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentStep += 1
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Enhanced Goal Selection

struct GoalSelectionViewEnhanced: View {
    @Binding var currentStep: Int
    @Binding var selectedGoal: String
    @State private var showContent = false
    @State private var selectedIndex: Int? = nil
    
    let goals = ["Flat stomach", "Visible abs", "Lose belly fat", "Strength & posture"]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                AnimatedProgressIndicator(currentStep: 2, totalSteps: 12)
                    .padding(.top, 20)
                    .fadeInAnimation()
                
                Spacer()
                
                Text("What's your goal?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                
                VStack(spacing: 16) {
                    ForEach(Array(goals.enumerated()), id: \.offset) { index, goal in
                        AnimatedOptionCard(
                            text: goal,
                            isSelected: selectedIndex == index,
                            index: index,
                            action: {
                                selectedIndex = index
                                selectedGoal = goal
                                AnalyticsManager.shared.trackGoalSelected(goal: goal)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentStep += 1
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Enhanced Body Type Selection

struct BodyTypeSelectionViewEnhanced: View {
    @Binding var currentStep: Int
    @Binding var selectedBodyType: String
    @State private var showContent = false
    @State private var selectedIndex: Int? = nil
    
    let bodyTypes = ["Skinny", "Average", "Muscular", "Higher body fat"]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                AnimatedProgressIndicator(currentStep: 3, totalSteps: 12)
                    .padding(.top, 20)
                    .fadeInAnimation()
                
                Spacer()
                
                Text("What's your current shape?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                
                VStack(spacing: 16) {
                    ForEach(Array(bodyTypes.enumerated()), id: \.offset) { index, bodyType in
                        AnimatedOptionCard(
                            text: bodyType,
                            isSelected: selectedIndex == index,
                            index: index,
                            action: {
                                selectedIndex = index
                                selectedBodyType = bodyType
                                AnalyticsManager.shared.trackBodyTypeSelected(bodyType: bodyType)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentStep += 1
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Enhanced Struggle Selection

struct StruggleSelectionViewEnhanced: View {
    @Binding var currentStep: Int
    @Binding var selectedStruggle: String
    @State private var showContent = false
    @State private var selectedIndex: Int? = nil
    
    let struggles = ["Lower belly", "Love handles", "Staying consistent", "Belly fat even when skinny"]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                AnimatedProgressIndicator(currentStep: 4, totalSteps: 12)
                    .padding(.top, 20)
                    .fadeInAnimation()
                
                Spacer()
                
                Text("Where do you struggle most?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                
                VStack(spacing: 16) {
                    ForEach(Array(struggles.enumerated()), id: \.offset) { index, struggle in
                        AnimatedOptionCard(
                            text: struggle,
                            isSelected: selectedIndex == index,
                            index: index,
                            action: {
                                selectedIndex = index
                                selectedStruggle = struggle
                                AnalyticsManager.shared.trackStruggleSelected(struggle: struggle)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentStep += 1
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Enhanced Training Time Selection

struct TrainingTimeSelectionViewEnhanced: View {
    @Binding var currentStep: Int
    @Binding var selectedTrainingTime: String
    @State private var showContent = false
    @State private var selectedIndex: Int? = nil
    
    let trainingTimes = ["5 mins", "7 mins", "10 mins", "15 mins"]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                AnimatedProgressIndicator(currentStep: 5, totalSteps: 12)
                    .padding(.top, 20)
                    .fadeInAnimation()
                
                Spacer()
                
                Text("How long can you train per day?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                
                VStack(spacing: 16) {
                    ForEach(Array(trainingTimes.enumerated()), id: \.offset) { index, time in
                        AnimatedOptionCard(
                            text: time,
                            isSelected: selectedIndex == index,
                            index: index,
                            action: {
                                selectedIndex = index
                                selectedTrainingTime = time
                                AnalyticsManager.shared.trackTrainingTimeSelected(trainingTime: time)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentStep += 1
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Transformation Timeline View

struct TransformationTimelineView: View {
    @Binding var currentStep: Int
    @State private var showContent = false
    @State private var animateWeeks = false
    @State private var currentWeek = 0
    
    let weeklyProgression = [
        WeeklyProgress(week: 1, title: "Foundation", description: "Core activation & posture", progress: 0.2),
        WeeklyProgress(week: 2, title: "Engagement", description: "Deeper muscle connection", progress: 0.3),
        WeeklyProgress(week: 4, title: "Definition", description: "First visible changes", progress: 0.5),
        WeeklyProgress(week: 6, title: "Strength", description: "Noticeable core strength", progress: 0.7),
        WeeklyProgress(week: 8, title: "Transformation", description: "Clear ab definition", progress: 0.9),
        WeeklyProgress(week: 12, title: "Results", description: "Complete transformation", progress: 1.0)
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                AnimatedProgressIndicator(currentStep: 6, totalSteps: 12)
                    .padding(.top, 20)
                    .fadeInAnimation()
                
                Spacer()
                
                VStack(spacing: 24) {
                    Text("Your 12-Week Transformation Timeline")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                    
                    Text("See how your core transforms week by week")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .fadeInAnimation(delay: 0.4)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(weeklyProgression.enumerated()), id: \.offset) { index, week in
                                WeeklyProgressCard(
                                    week: week,
                                    isActive: index <= currentWeek,
                                    delay: Double(index) * 0.2
                                )
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    }
                }
                
                Button(action: {
                    HapticFeedbackManager.shared.buttonTap()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep += 1
                    }
                }) {
                    Text("START MY TRANSFORMATION")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.size.width * 0.8)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.goatBlue, Color.cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .bounceButton()
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            
            // Animate week progression
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
                if currentWeek < weeklyProgression.count - 1 {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        currentWeek += 1
                    }
                    HapticFeedbackManager.shared.progressUpdate()
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}

struct WeeklyProgress {
    let week: Int
    let title: String
    let description: String
    let progress: CGFloat
}

struct WeeklyProgressCard: View {
    let week: WeeklyProgress
    let isActive: Bool
    let delay: Double
    @State private var showCard = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Week indicator
            ZStack {
                Circle()
                    .fill(isActive ? Color.goatBlue : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isActive)
                
                Text("W\(week.week)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(week.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isActive ? .white : .gray)
                
                Text(week.description)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .gray : .gray.opacity(0.7))
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.goatBlue, Color.cyan]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: isActive ? geometry.size.width * week.progress : 0, height: 6)
                            .animation(.easeOut(duration: 1.0).delay(delay), value: isActive)
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? Color.white.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? Color.goatBlue.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(showCard ? 1 : 0.8)
        .opacity(showCard ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: showCard)
        .onAppear {
            showCard = true
        }
    }
}

// MARK: - Personalized Plan Building View

struct PersonalizedPlanBuildingView: View {
    @Binding var currentStep: Int
    let selectedGoal: String
    let selectedBodyType: String
    let selectedTrainingTime: String
    let selectedStruggle: String
    @State private var buildingProgress: CGFloat = 0
    @State private var showComponents = false
    @State private var isBuilding = false
    @State private var showCelebration = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if showCelebration {
                ParticleEffect()
                    .allowsHitTesting(false)
            }
            
            VStack {
                AnimatedProgressIndicator(currentStep: 7, totalSteps: 12)
                    .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 32) {
                    // AI Building Animation
                    VStack(spacing: 24) {
                        ZStack {
                            // Rotating AI rings
                            ForEach(0..<3) { index in
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.cyan, Color.goatBlue]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 80 + CGFloat(index * 20), height: 80 + CGFloat(index * 20))
                                    .rotationEffect(.degrees(isBuilding ? Double(360 * (index + 1)) : 0))
                                    .animation(
                                        .linear(duration: Double(2 + index))
                                        .repeatForever(autoreverses: false),
                                        value: isBuilding
                                    )
                            }
                            
                            // Central AI icon
                            ZStack {
                                Circle()
                                    .fill(Color.cyan.opacity(0.8))
                                    .frame(width: 60, height: 60)
                                    .scaleEffect(isBuilding ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isBuilding)
                                
                                Image(systemName: "brain")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .scaleEffect(isBuilding ? 1.05 : 0.95)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isBuilding)
                            }
                        }
                        
                        Text("AI is creating your personalized plan...")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    // Building Progress
                    VStack(spacing: 16) {
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.cyan, Color.goatBlue]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * buildingProgress, height: 12)
                                    .animation(.easeOut(duration: 0.3), value: buildingProgress)
                            }
                        }
                        .frame(height: 12)
                        .padding(.horizontal, 40)
                        
                        Text("\(Int(buildingProgress * 100))% Complete")
                            .font(.system(size: 16))
                            .foregroundColor(.cyan)
                    }
                    
                    // Plan Components
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Building your plan based on:")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        
                        PlanComponent(title: "Goal", value: selectedGoal, isVisible: showComponents)
                        PlanComponent(title: "Body Type", value: selectedBodyType, isVisible: showComponents)
                        PlanComponent(title: "Training Time", value: selectedTrainingTime, isVisible: showComponents)
                        PlanComponent(title: "Focus Area", value: selectedStruggle, isVisible: showComponents)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
        .onAppear {
            isBuilding = true
            showComponents = true
            
            // Animate building progress
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if buildingProgress < 1.0 {
                    buildingProgress += 0.2
                    HapticFeedbackManager.shared.progressUpdate()
                } else {
                    timer.invalidate()
                    showCelebration = true
                    HapticFeedbackManager.shared.celebrationPattern()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    }
                }
            }
        }
    }
}

struct PlanComponent: View {
    let title: String
    let value: String
    let isVisible: Bool
    @State private var showCheck = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(showCheck ? 0.8 : 0.3))
                    .frame(width: 24, height: 24)
                    .animation(.spring(response: 0.3), value: showCheck)
                
                if showCheck {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(showCheck ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: showCheck)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .opacity(isVisible ? 1 : 0)
        .animation(.easeOut(duration: 0.4), value: isVisible)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showCheck = true
            }
        }
    }
}

// MARK: - Success Stories View

struct SuccessStoriesView: View {
    @Binding var currentStep: Int
    let selectedAge: String
    @State private var showContent = false
    @State private var currentStory = 0
    
    var ageMatchedStories: [SuccessStory] {
        let allStories = [
            SuccessStory(name: "James", age: "22", ageRange: "18-25", timeframe: "8 weeks", result: "Lost 15 lbs, visible abs"),
            SuccessStory(name: "Mike", age: "28", ageRange: "26-35", timeframe: "12 weeks", result: "Gained definition, stronger core"),
            SuccessStory(name: "David", age: "38", ageRange: "36-45", timeframe: "16 weeks", result: "Lost belly fat, better posture"),
            SuccessStory(name: "Robert", age: "52", ageRange: "46+", timeframe: "20 weeks", result: "Strengthened core, reduced back pain"),
            SuccessStory(name: "Alex", age: "24", ageRange: "18-25", timeframe: "10 weeks", result: "Six-pack definition achieved"),
            SuccessStory(name: "Chris", age: "31", ageRange: "26-35", timeframe: "14 weeks", result: "Lost love handles, gained confidence")
        ]
        
        return allStories.filter { $0.ageRange == selectedAge }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                AnimatedProgressIndicator(currentStep: 8, totalSteps: 12)
                    .padding(.top, 20)
                    .fadeInAnimation()
                
                Spacer()
                
                VStack(spacing: 24) {
                    Text("Success Stories from Your Age Group")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                    
                    Text("Real results from people ages \(selectedAge)")
                        .font(.system(size: 16))
                        .foregroundColor(.goatBlue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .fadeInAnimation(delay: 0.4)
                    
                    if !ageMatchedStories.isEmpty {
                        SuccessStoryCard(story: ageMatchedStories[currentStory])
                            .padding(.horizontal, 30)
                            .padding(.vertical, 20)
                        
                        // Story indicator dots
                        if ageMatchedStories.count > 1 {
                            HStack(spacing: 8) {
                                ForEach(0..<ageMatchedStories.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == currentStory ? Color.goatBlue : Color.gray.opacity(0.5))
                                        .frame(width: 8, height: 8)
                                        .animation(.spring(response: 0.3), value: currentStory)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    HapticFeedbackManager.shared.buttonTap()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep += 1
                    }
                }) {
                    Text("I'M READY FOR MY RESULTS")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.size.width * 0.8)
                        .padding()
                        .background(Color.goatBlue)
                        .cornerRadius(12)
                }
                .bounceButton()
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            
            // Auto-cycle through stories if multiple available
            if ageMatchedStories.count > 1 {
                Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentStory = (currentStory + 1) % ageMatchedStories.count
                    }
                }
            }
        }
    }
}

struct SuccessStory {
    let name: String
    let age: String
    let ageRange: String
    let timeframe: String
    let result: String
}

struct SuccessStoryCard: View {
    let story: SuccessStory
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile section
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.goatBlue.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.goatBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("\(story.age) years old")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Results section
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("TIME TO RESULTS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Text(story.timeframe)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.goatBlue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("ACHIEVEMENT")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.yellow)
                    }
                }
                
                Text("\(story.result)")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .italic()
                    .padding(.top, 8)
            }
            .opacity(showDetails ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(0.3), value: showDetails)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.goatBlue.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            showDetails = true
        }
    }
}

// MARK: - Commitment View

struct CommitmentView: View {
    @Binding var currentStep: Int
    @State private var showContent = false
    @State private var commitmentLevel: Int = 0
    @State private var showPsychology = false
    
    let commitmentOptions = [
        "I'll try it out",
        "I'm serious about results",
        "I'm 100% committed to my transformation"
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                AnimatedProgressIndicator(currentStep: 9, totalSteps: 12)
                    .padding(.top, 20)
                    .fadeInAnimation()
                
                Spacer()
                
                VStack(spacing: 32) {
                    // Psychology insight
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.8))
                                .frame(width: 80, height: 80)
                                .scaleEffect(showPsychology ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: showPsychology)
                            
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        Text("Research shows that commitment level predicts success")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                    
                    // Commitment question
                    VStack(spacing: 24) {
                        Text("How committed are you to getting results?")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        VStack(spacing: 16) {
                            ForEach(Array(commitmentOptions.enumerated()), id: \.offset) { index, option in
                                CommitmentOptionCard(
                                    text: option,
                                    isSelected: commitmentLevel == index,
                                    commitmentLevel: index + 1,
                                    action: {
                                        commitmentLevel = index
                                        AnalyticsManager.shared.trackCommitmentLevel(level: index + 1)
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                currentStep += 1
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                }
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
                showPsychology = true
            }
        }
    }
}

struct CommitmentOptionCard: View {
    let text: String
    let isSelected: Bool
    let commitmentLevel: Int
    let action: () -> Void
    @State private var showCard = false
    
    var cardColor: Color {
        switch commitmentLevel {
        case 1: return Color.orange
        case 2: return Color.goatBlue
        case 3: return Color.green
        default: return Color.gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Commitment level indicator
                ZStack {
                    Circle()
                        .fill(cardColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    ForEach(0..<commitmentLevel, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(cardColor)
                    }
                }
                
                Text(text)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(cardColor)
                        .scaleEffect(1.2)
                        .animation(.spring(response: 0.3), value: isSelected)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? cardColor.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? cardColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .pressableButton()
        .scaleEffect(showCard ? 1 : 0.8)
        .opacity(showCard ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(commitmentLevel) * 0.1), value: showCard)
        .onAppear {
            showCard = true
        }
    }
}

// MARK: - Enhanced Daily Reminder View

struct DailyReminderViewEnhanced: View {
    @Binding var currentStep: Int
    @Binding var selectedTime: Date
    @State private var showPicker = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                AnimatedProgressIndicator(currentStep: 10, totalSteps: 12)
                    .padding(.top, 20)
                
                VStack(spacing: 20) {
                    Text("Set your daily reminder to\ntrain your core every day.")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 40)
                        .fadeInAnimation()
                    
                    Text("Choose a time below")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .fadeInAnimation(delay: 0.2)
                    
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .colorScheme(.dark)
                        .padding(.horizontal, 40)
                        .frame(height: 200)
                        .scaleEffect(showPicker ? 1 : 0.8)
                        .opacity(showPicker ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: showPicker)
                        .onChange(of: selectedTime) { _ in
                            HapticFeedbackManager.shared.selectionChanged()
                        }
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        HapticFeedbackManager.shared.buttonTap()
                        UserAPI.user.selectedTime = nil
                        UserManager.save()
                        withAnimation {
                            currentStep += 1
                        }
                    }) {
                        Text("SKIP REMINDER")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        HapticFeedbackManager.shared.buttonTap()
                        UserAPI.user.selectedTime = selectedTime
                        UserManager.save()
                        UserDefaults.standard.setValue(selectedTime, forKey: UserManager.workoutDateKey)
                        OptimizedNotificationManager.shared.updateNotificationTime(newTime: selectedTime)
                        
                        withAnimation {
                            currentStep += 1
                        }
                    }) {
                        Text("NEXT")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.size.width * 0.8)
                            .padding()
                            .background(Color.goatBlue)
                            .cornerRadius(12)
                    }
                    .bounceButton()
                }
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            withAnimation {
                showPicker = true
            }
        }
    }
}

// MARK: - Enhanced Preview Workout View

struct PreviewWorkoutViewEnhanced: View {
    @Binding var currentStep: Int
    @State private var currentExerciseIndex = 0
    @State private var isAnimating = false
    @State private var exerciseProgress: CGFloat = 0
    @State private var showExercises = false
    @State private var exerciseTimer: Timer? = nil
    @State private var urgencyTimer = 30
    @State private var showUrgency = false
    
    let sampleExercises = [
        "Basic Plank",
        "Mountain Climbers",
        "Crunches",
        "Russian Twists",
        "Bicycle Crunches"
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                AnimatedProgressIndicator(currentStep: 11, totalSteps: 12)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
                // Urgency Timer
                if showUrgency {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("Limited setup expires in \(urgencyTimer)s")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    .padding(.bottom, 10)
                    .pulseAnimation(isPulsing: true)
                }
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Try a Sample Workout")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .fadeInAnimation()
                        
                        Text("See what your 5-minute routine looks like")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .fadeInAnimation(delay: 0.2)
                        
                        VStack(spacing: 8) {
                            Text("Most users see results within 2–4 weeks.")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Your plan adapts as you get stronger — don't lose this setup.")
                                .font(.system(size: 13))
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 10)
                        .fadeInAnimation(delay: 0.4)
                        
                        // Enhanced Exercise Animation
                        VStack(spacing: 20) {
                            ZStack {
                                // Multiple animated rings
                                ForEach(0..<3) { index in
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.goatBlue, Color.cyan]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .frame(width: 140 + CGFloat(index * 20), height: 140 + CGFloat(index * 20))
                                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                                        .opacity(isAnimating ? 0 : 0.6)
                                        .animation(
                                            .easeOut(duration: 2)
                                            .repeatForever()
                                            .delay(Double(index) * 0.3),
                                            value: isAnimating
                                        )
                                }
                                
                                // Progress ring
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 6)
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .trim(from: 0, to: exerciseProgress)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.goatBlue, Color.cyan]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                                    )
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: exerciseProgress)
                                
                                // Center content
                                Circle()
                                    .fill(Color.goatBlue.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(isAnimating ? 1.05 : 0.95)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                                
                                Image(systemName: "figure.core.training")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                            }
                            
                            Text(sampleExercises[currentExerciseIndex])
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                                .animation(.easeInOut, value: currentExerciseIndex)
                            
                            HStack(spacing: 20) {
                                Image(systemName: "timer")
                                    .foregroundColor(.cyan)
                                Text("30 seconds")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            .pulseAnimation(isPulsing: isAnimating)
                        }
                        .padding(.bottom, 40)
                        
                        // Enhanced Exercise List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your 5-minute routine includes:")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            
                            ForEach(Array(sampleExercises.enumerated()), id: \.offset) { index, exercise in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(index == currentExerciseIndex ? Color.goatBlue : Color.gray.opacity(0.3))
                                            .frame(width: 24, height: 24)
                                        
                                        if index == currentExerciseIndex {
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(.white)
                                                .scaleEffect(isAnimating ? 1.2 : 1.0)
                                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                                        } else {
                                            Text("\(index + 1)")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    Text(exercise)
                                        .font(.system(size: 16))
                                        .foregroundColor(index == currentExerciseIndex ? .white : .gray)
                                    
                                    Spacer()
                                    
                                    Text("30s")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .opacity(showExercises ? 1 : 0)
                                .offset(x: showExercises ? 0 : -20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1), value: showExercises)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 100)
                    }
                }
                
                // Fixed bottom buttons with enhanced animation
                VStack(spacing: 16) {
                    Button(action: {
                        HapticFeedbackManager.shared.buttonTap()
                        AnalyticsManager.shared.trackPreviewWorkoutSkipped()
                        withAnimation {
                            currentStep += 1
                        }
                    }) {
                        Text("SKIP PREVIEW")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        HapticFeedbackManager.shared.buttonTap()
                        withAnimation {
                            currentStep += 1
                        }
                    }) {
                        Text("GET FULL ACCESS")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.size.width * 0.8)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.goatBlue, Color.cyan]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .bounceButton()
                    .shimmerEffect(isAnimating: isAnimating)
                }
                .padding(.bottom, 50)
                .background(Color.black)
            }
        }
        .onAppear {
            AnalyticsManager.shared.trackPreviewWorkoutShown()
            
            withAnimation {
                isAnimating = true
                showExercises = true
                exerciseProgress = 1
                showUrgency = true
            }
            
            // Urgency countdown timer
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if urgencyTimer > 0 && currentStep == 11 {
                    urgencyTimer -= 1
                } else {
                    timer.invalidate()
                }
            }
            
            // Create and store timer reference for proper cleanup
            exerciseTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
                // Check if view is still active
                guard currentStep == 11 else {
                    timer.invalidate()
                    return
                }
                
                // Pulse before transition
                HapticFeedbackManager.shared.pulsePattern()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    // Double-check view is still active before haptics
                    guard currentStep == 11 else { return }
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentExerciseIndex = (currentExerciseIndex + 1) % sampleExercises.count
                    }
                    // Impact on exercise change
                    HapticFeedbackManager.shared.impact(.medium)
                }
            }
        }
        .onDisappear {
            // Critical: Clean up timer when view disappears
            exerciseTimer?.invalidate()
            exerciseTimer = nil
        }
        .onChange(of: currentStep) { newStep in
            // Also invalidate timer if we navigate away
            if newStep != 11 {
                exerciseTimer?.invalidate()
                exerciseTimer = nil
            }
        }
    }
}

// MARK: - Shared Components

struct AnimatedProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    @State private var animatedProgress: CGFloat = 0
    
    var progress: CGFloat {
        CGFloat(currentStep) / CGFloat(totalSteps - 1)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.goatBlue, Color.cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * animatedProgress, height: 6)
                        .animation(.easeOut(duration: 0.5), value: animatedProgress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 40)
            
            Text("\(currentStep + 1) of \(totalSteps)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: currentStep) { _ in
            animatedProgress = progress
        }
    }
}

struct AnimatedOptionCard: View {
    let text: String
    let isSelected: Bool
    let index: Int
    let action: () -> Void
    @State private var showCard = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.goatBlue)
                        .scaleEffect(1.2)
                        .animation(.spring(response: 0.3), value: isSelected)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.goatBlue.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.goatBlue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .pressableButton()
        .scaleEffect(showCard ? 1 : 0.8)
        .opacity(showCard ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: showCard)
        .onAppear {
            showCard = true
        }
    }
}

// MARK: - Analytics Extension

extension AnalyticsManager {
    func trackAgeSelected(age: String) {
        // Implementation for age selection tracking
        print("Age selected: \(age)")
    }
    
    func trackCommitmentLevel(level: Int) {
        // Implementation for commitment level tracking
        print("Commitment level: \(level)")
    }
}