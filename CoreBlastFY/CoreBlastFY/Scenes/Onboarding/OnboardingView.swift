////
////  OnboardingView.swift
////  Sixpack Blueprint
////
////  Created by Riccardo Washington on 10/11/24.
////  Copyright © 2024 Riccardo Washington. All rights reserved.
////
//
//import SwiftUI
//import StoreKit
//
//let ratingKey = "ratingKey"
//
//struct OnboardingView: View {
//    @State private var currentStep = 0
//    @State private var selectedTimePreference = ""
//    @State private var selectedTime = Date()
//    @State private var selectedGoal = ""
//    @State private var selectedBodyType = ""
//    @State private var selectedTrainingTime = ""
//    @State private var selectedStruggle = ""
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if currentStep == 0 {
//                    GoalSelectionView(currentStep: $currentStep, selectedGoal: $selectedGoal)
//                } else if currentStep == 1 {
//                    BodyTypeSelectionView(currentStep: $currentStep, selectedBodyType: $selectedBodyType)
//                } else if currentStep == 2 {
//                    TrainingTimeSelectionView(currentStep: $currentStep, selectedTrainingTime: $selectedTrainingTime)
//                } else if currentStep == 3 {
//                    StruggleSelectionView(currentStep: $currentStep, selectedStruggle: $selectedStruggle)
//                } else if currentStep == 4 {
//                    YourPlanIsReadyView(currentStep: $currentStep, selectedGoal: selectedGoal, selectedBodyType: selectedBodyType, selectedTrainingTime: selectedTrainingTime, selectedStruggle: selectedStruggle)
//                } else if currentStep == 5 {
//                    WelcomeView(currentStep: $currentStep)
//                } else if currentStep == 6 {
//                    CoreTrainingImportanceView(currentStep: $currentStep)
//                } else if currentStep == 7 {
//                    FeelStrongView(currentStep: $currentStep)
//                } else if currentStep == 8 {
//                    ConsistencyView(currentStep: $currentStep)
//                } else if currentStep == 9 {
//                    DailyReminderView(currentStep: $currentStep, selectedTime: $selectedTime)
//                } else if currentStep == 10 {
//                    ReviewPromptView(currentStep: $currentStep)
//                } else if currentStep == 11 {
//                    PreviewWorkoutView(currentStep: $currentStep)
//                } else if currentStep == 12 {
//                    SubscriptionView() { success in
//                        currentStep += 1
//                        // Always mark onboarding as completed, regardless of subscription success
//                        OnboardingManager.markOnboardingCompleted()
//                        OnboardingViewController.completion?()
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//            .onChange(of: currentStep) { newStep in
//                // Track onboarding funnel steps
//                trackOnboardingStep(step: newStep)
//            }
//        }
//        .onAppear {
//            // Track onboarding started
//            AnalyticsManager.shared.trackOnboardingStarted()
//        }
//    }
//    
//    private func trackOnboardingStep(step: Int) {
//        let stepNames = [
//            "goal_selection",
//            "body_type_selection",
//            "training_time_selection",
//            "struggle_selection",
//            "your_plan_ready",
//            "welcome",
//            "core_training_importance", 
//            "feel_strong",
//            "consistency",
//            "daily_reminder",
//            "review_prompt",
//            "preview_workout",
//            "subscription"
//        ]
//        
//        if step < stepNames.count {
//            AnalyticsManager.shared.trackOnboardingStep(
//                step: stepNames[step], 
//                stepNumber: step
//            )
//        }
//    }
//}
//
////struct GoalSelectionView: View {
////    @Binding var currentStep: Int
////    @Binding var selectedGoal: String
////    
////    let goals = ["Flat stomach", "Visible abs", "Lose belly fat", "Strength & posture"]
////
////    var body: some View {
////        ZStack {
////            Color.black.edgesIgnoringSafeArea(.all)
////            
////            VStack {
////                ProgressIndicator(currentStep: 0, totalSteps: 12)
////                    .padding(.top, 20)
////                
////                Spacer()
////                
////                Text("What's your goal?")
////                    .font(.system(size: 32, weight: .bold))
////                    .foregroundColor(.white)
////                    .multilineTextAlignment(.center)
////                    .padding(.horizontal, 40)
////                    .padding(.bottom, 40)
////                
////                VStack(spacing: 16) {
////                    ForEach(goals, id: \.self) { goal in
////                        Button(action: {
////                            selectedGoal = goal
////                            AnalyticsManager.shared.trackGoalSelected(goal: goal)
////                            withAnimation {
////                                currentStep += 1
////                            }
////                        }) {
////                            Text(goal)
////                                .font(.system(size: 18))
////                                .foregroundColor(.white)
////                                .frame(maxWidth: .infinity)
////                                .padding()
////                                .background(Color.gray.opacity(0.3))
////                                .cornerRadius(12)
////                        }
////                    }
////                }
////                .padding(.horizontal, 40)
////                
////                Spacer()
////            }
////        }
////    }
////}
//
//struct BodyTypeSelectionView: View {
//    @Binding var currentStep: Int
//    @Binding var selectedBodyType: String
//    
//    let bodyTypes = ["Skinny", "Average", "Muscular", "Higher body fat"]
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 1, totalSteps: 12)
//                    .padding(.top, 20)
//                
//                Spacer()
//                
//                Text("What's your current shape?")
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 40)
//                
//                VStack(spacing: 16) {
//                    ForEach(bodyTypes, id: \.self) { bodyType in
//                        Button(action: {
//                            selectedBodyType = bodyType
//                            AnalyticsManager.shared.trackBodyTypeSelected(bodyType: bodyType)
//                            withAnimation {
//                                currentStep += 1
//                            }
//                        }) {
//                            Text(bodyType)
//                                .font(.system(size: 18))
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.gray.opacity(0.3))
//                                .cornerRadius(12)
//                        }
//                    }
//                }
//                .padding(.horizontal, 40)
//                
//                Spacer()
//            }
//        }
//    }
//}
//
//struct TrainingTimeSelectionView: View {
//    @Binding var currentStep: Int
//    @Binding var selectedTrainingTime: String
//    
//    let trainingTimes = ["5 mins", "7 mins", "10 mins", "15 mins"]
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 2, totalSteps: 12)
//                    .padding(.top, 20)
//                
//                Spacer()
//                
//                Text("How long can you train per day?")
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 40)
//                
//                VStack(spacing: 16) {
//                    ForEach(trainingTimes, id: \.self) { time in
//                        Button(action: {
//                            selectedTrainingTime = time
//                            AnalyticsManager.shared.trackTrainingTimeSelected(trainingTime: time)
//                            withAnimation {
//                                currentStep += 1
//                            }
//                        }) {
//                            Text(time)
//                                .font(.system(size: 18))
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.gray.opacity(0.3))
//                                .cornerRadius(12)
//                        }
//                    }
//                }
//                .padding(.horizontal, 40)
//                
//                Spacer()
//            }
//        }
//    }
//}
//
//struct StruggleSelectionView: View {
//    @Binding var currentStep: Int
//    @Binding var selectedStruggle: String
//    
//    let struggles = ["Lower belly", "Love handles", "Staying consistent", "Belly fat even when skinny"]
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 3, totalSteps: 12)
//                    .padding(.top, 20)
//                
//                Spacer()
//                
//                Text("Where do you struggle most?")
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 40)
//                
//                VStack(spacing: 16) {
//                    ForEach(struggles, id: \.self) { struggle in
//                        Button(action: {
//                            selectedStruggle = struggle
//                            AnalyticsManager.shared.trackStruggleSelected(struggle: struggle)
//                            withAnimation {
//                                currentStep += 1
//                            }
//                        }) {
//                            Text(struggle)
//                                .font(.system(size: 18))
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.gray.opacity(0.3))
//                                .cornerRadius(12)
//                        }
//                    }
//                }
//                .padding(.horizontal, 40)
//                
//                Spacer()
//            }
//        }
//    }
//}
//
//struct YourPlanIsReadyView: View {
//    @Binding var currentStep: Int
//    let selectedGoal: String
//    let selectedBodyType: String
//    let selectedTrainingTime: String
//    let selectedStruggle: String
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 4, totalSteps: 12)
//                    .padding(.top, 20)
//                
//                Spacer()
//                
//                ZStack {
//                    Circle()
//                        .fill(Color.orange.opacity(0.8))
//                        .frame(width: 120, height: 120)
//                    
//                    Text("🔥")
//                        .font(.system(size: 50))
//                }
//                .padding(.bottom, 40)
//                
//                Text("Your Sixpack Blueprint Is Ready 🔥")
//                    .font(.system(size: 28, weight: .bold))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 20)
//                
//                VStack(spacing: 20) {
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Customized for your goals:")
//                            .font(.system(size: 18, weight: .medium))
//                            .foregroundColor(.white)
//                        
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("• \(selectedGoal.lowercased())")
//                            Text("• \(selectedStruggle.lowercased()) tightening")
//                            Text("• Daily \(selectedTrainingTime) routines")
//                        }
//                        .font(.system(size: 16))
//                        .foregroundColor(.gray)
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Your plan includes:")
//                            .font(.system(size: 18, weight: .medium))
//                            .foregroundColor(.white)
//                        
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("✓ Smart progression")
//                            Text("✓ Real ab definition tracking")
//                            Text("✓ Beginner-friendly core workouts")
//                            Text("✓ Motivation reminders")
//                        }
//                        .font(.system(size: 16))
//                        .foregroundColor(.gray)
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 40)
//                
//                Spacer()
//                
//                Button("CONTINUE →") {
//                    AnalyticsManager.shared.trackPersonalizationComplete(
//                        goal: selectedGoal,
//                        bodyType: selectedBodyType,
//                        trainingTime: selectedTrainingTime,
//                        struggle: selectedStruggle
//                    )
//                    withAnimation {
//                        currentStep += 1
//                    }
//                }
//                .font(.system(size: 18, weight: .medium))
//                .foregroundColor(.white)
//                .frame(width: UIScreen.main.bounds.size.width * 0.8)
//                .padding()
//                .background(Color.goatBlue)
//                .cornerRadius(12)
//                .padding(.bottom, 50)
//            }
//        }
//    }
//}
//
//struct WelcomeView: View {
//    @Binding var currentStep: Int
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 5, totalSteps: 12)
//                    .padding(.top, 20)
//                
//                Spacer()
//                
//                ZStack {
//                    Circle()
//                        .fill(Color.goatBlue.opacity(0.8))
//                        .frame(width: 120, height: 120)
//                    
//                    Image(systemName: "figure.strengthtraining.traditional")
//                        .font(.system(size: 50))
//                        .foregroundColor(.white)
//                }
//                .padding(.bottom, 40)
//                
//                Text("This is your year for visible abs.")
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 20)
//                
//                Text("Your personalized Sixpack Blueprint will guide you step-by-step.")
//                    .font(.system(size: 18))
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                
//                Spacer()
//                
//                Button("TAP TO CONTINUE") {
//                    withAnimation {
//                        currentStep += 1
//                    }
//                }
//                .font(.system(size: 16, weight: .medium))
//                .foregroundColor(.gray)
//                .padding(.bottom, 50)
//            }
//        }
//    }
//}
//
//struct CoreTrainingImportanceView: View {
//    @Binding var currentStep: Int
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 6, totalSteps: 12)
//                    .padding(.top, 20)
//                
//                Spacer()
//                
//                ZStack {
//                    Circle()
//                        .fill(Color.green.opacity(0.8))
//                        .frame(width: 120, height: 120)
//                    
//                    Image(systemName: "figure.core.training")
//                        .font(.system(size: 50))
//                        .foregroundColor(.white)
//                }
//                .padding(.bottom, 40)
//                
//                Text("A strong core reshapes your entire body.")
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 20)
//                
//                Text("Better posture, better definition, better confidence.")
//                    .font(.system(size: 18))
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                
//                Spacer()
//                
//                Button("TAP TO CONTINUE") {
//                    withAnimation {
//                        currentStep += 1
//                    }
//                }
//                .font(.system(size: 16, weight: .medium))
//                .foregroundColor(.gray)
//                .padding(.bottom, 50)
//            }
//        }
//    }
//}
//
//struct FeelStrongView: View {
//    @Binding var currentStep: Int
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 7, totalSteps: 12)
//                    .padding(.top, 20)
//                
//                Spacer()
//                
//                ZStack {
//                    Circle()
//                        .fill(Color.purple.opacity(0.8))
//                        .frame(width: 120, height: 120)
//                    
//                    Image(systemName: "flame.fill")
//                        .font(.system(size: 50))
//                        .foregroundColor(.white)
//                }
//                .padding(.bottom, 40)
//                
//                Text("Every workout tightens your waist and builds real strength.")
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 20)
//                
//                Text("")
//                    .font(.system(size: 18))
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                
//                Spacer()
//                
//                Button("TAP TO CONTINUE") {
//                    withAnimation {
//                        currentStep += 1
//                    }
//                }
//                .font(.system(size: 16, weight: .medium))
//                .foregroundColor(.gray)
//                .padding(.bottom, 50)
//            }
//        }
//    }
//}
//
//struct ConsistencyView: View {
//    @Binding var currentStep: Int
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 8, totalSteps: 12)
//                    .padding(.top, 20)
//                
//                Spacer()
//                
//                ZStack {
//                    Circle()
//                        .fill(Color.orange.opacity(0.8))
//                        .frame(width: 120, height: 120)
//                    
//                    Image(systemName: "target")
//                        .font(.system(size: 50))
//                        .foregroundColor(.white)
//                }
//                .padding(.bottom, 40)
//                
//                Text("Visible abs come from a routine you can actually stick to.")
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 20)
//                
//                Text("We built Sixpack Blueprint to be fast, simple, and effective.")
//                    .font(.system(size: 18))
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                
//                Spacer()
//                
//                Button("TAP TO CONTINUE") {
//                    withAnimation {
//                        currentStep += 1
//                    }
//                }
//                .font(.system(size: 16, weight: .medium))
//                .foregroundColor(.gray)
//                .padding(.bottom, 50)
//            }
//        }
//    }
//}
//
//struct TimePreferenceView: View {
//    @Binding var currentStep: Int
//    @Binding var selectedTimePreference: String
//    
//    let timeOptions = [
//        "After waking up",
//        "Before breakfast",
//        "After cardio",
//        "Before showering",
//        "During lunch break",
//        "After work",
//        "Before going to bed",
//        "Other"
//    ]
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 4, totalSteps: 6)
//                    .padding(.top, 20)
//                
//                VStack(alignment: .leading, spacing: 20) {
//                    Text("When is a good time for your\ndaily core workout?")
//                        .font(.system(size: 32, weight: .bold))
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 40)
//                        .padding(.top, 40)
//                    
//                    Text("Choose an option to continue")
//                        .font(.system(size: 18))
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 40)
//                        .padding(.bottom, 20)
//                    
//                    VStack(spacing: 16) {
//                        ForEach(timeOptions, id: \.self) { option in
//                            Button(action: {
//                                selectedTimePreference = option
//                                withAnimation {
//                                    currentStep += 1
//                                }
//                            }) {
//                                Text(option)
//                                    .font(.system(size: 18))
//                                    .foregroundColor(.white)
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                                    .background(Color.gray.opacity(0.3))
//                                    .cornerRadius(12)
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 40)
//                }
//                
//                Spacer()
//            }
//        }
//    }
//}
//
//struct DailyReminderView: View {
//    @Binding var currentStep: Int
//    @Binding var selectedTime: Date
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 9, totalSteps: 12)
//                    .padding(.top, 20)
//                
//                VStack(spacing: 20) {
//                    Text("Set your daily reminder to\ntrain your core every day.")
//                        .font(.system(size: 32, weight: .bold))
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 40)
//                        .padding(.top, 40)
//                    
//                    Text("Choose a time below")
//                        .font(.system(size: 18))
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 40)
//                    
//                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
//                        .datePickerStyle(WheelDatePickerStyle())
//                        .labelsHidden()
//                        .colorScheme(.dark)
//                        .padding(.horizontal, 40)
//                        .frame(height: 200)
//                }
//                
//                Spacer()
//                
//                VStack(spacing: 16) {
//                    Button("SKIP REMINDER") {
//                        // Save that reminder was skipped
//                        UserAPI.user.selectedTime = nil
//                        UserManager.save()
//                        
//                        withAnimation {
//                            currentStep += 1
//                        }
//                    }
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.gray)
//                    
//                    Button("NEXT") {
//                        UserAPI.user.selectedTime = selectedTime
//                        UserManager.save()
//                        UserDefaults.standard.setValue(selectedTime, forKey: UserManager.workoutDateKey)
//                        
//                        // Update notifications with new time
//                        OptimizedNotificationManager.shared.updateNotificationTime(newTime: selectedTime)
//                        
//                        withAnimation {
//                            currentStep += 1
//                        }
//                    }
//                    .font(.system(size: 18, weight: .medium))
//                    .foregroundColor(.white)
//                    .frame(width: UIScreen.main.bounds.size.width * 0.8)
//                    .padding()
//                    .background(Color.goatBlue)
//                    .cornerRadius(12)
//                }
//                .padding(.bottom, 100)
//            }
//        }
//    }
//}
//
//struct ProgressIndicator: View {
//    let currentStep: Int
//    let totalSteps: Int
//    
//    var body: some View {
//        HStack(spacing: 8) {
//            ForEach(0..<totalSteps, id: \.self) { index in
//                Rectangle()
//                    .fill(index <= currentStep ? Color.white : Color.gray.opacity(0.3))
//                    .frame(height: 3)
//                    .cornerRadius(1.5)
//            }
//        }
//        .padding(.horizontal, 40)
//    }
//}
//
//struct ContentView: View {
//    var body: some View {
//        OnboardingView()
//    }
//}
//
//struct ReviewPromptView: View {
//    @Binding var currentStep: Int
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ProgressIndicator(currentStep: 10, totalSteps: 12)
//                    .padding(.top, 20)
//                
//                Spacer()
//                
//                ZStack {
//                    Circle()
//                        .fill(Color.yellow.opacity(0.8))
//                        .frame(width: 120, height: 120)
//                    
//                    Image(systemName: "star.fill")
//                        .font(.system(size: 50))
//                        .foregroundColor(.white)
//                }
//                .padding(.bottom, 40)
//                
//                Text("Help us grow!")
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 20)
//                
//                Text("Leave a 5-star review to help other\npeople discover Sixpack Blueprint!")
//                    .font(.system(size: 18))
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                
//                Spacer()
//                
//                VStack(spacing: 16) {
//                    Button("HELP US GROW") {
//                        // Request review using StoreKit
//                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//                            SKStoreReviewController.requestReview(in: scene)
//                            UserAPI.user.requestReviewCount += 1
//                            UserAPI.user.lastReviewRequestDate = Date()
//                            UserManager.save()
//                        }
//                        
//                        withAnimation {
//                            currentStep += 1
//                        }
//                    }
//                    .font(.system(size: 18, weight: .medium))
//                    .foregroundColor(.white)
//                    .frame(width: UIScreen.main.bounds.size.width * 0.8)
//                    .padding()
//                    .background(Color.goatBlue)
//                    .cornerRadius(12)
//                    
//                    Button("MAYBE LATER") {
//                        withAnimation {
//                            currentStep += 1
//                        }
//                    }
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.gray)
//                }
//                .padding(.bottom, 100)
//            }
//        }
//    }
//}
//
//struct PreviewWorkoutView: View {
//    @Binding var currentStep: Int
//    @State private var currentExerciseIndex = 0
//    @State private var isAnimating = false
//    
//    let sampleExercises = [
//        "Basic Plank",
//        "Mountain Climbers",
//        "Crunches",
//        "Russian Twists",
//        "Bicycle Crunches"
//    ]
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            VStack(spacing: 0) {
//                ProgressIndicator(currentStep: 11, totalSteps: 12)
//                    .padding(.top, 20)
//                    .padding(.bottom, 20)
//                
//                ScrollView {
//                    VStack(spacing: 16) {
//                        Text("Try a Sample Workout")
//                            .font(.system(size: 28, weight: .bold))
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal, 40)
//                        
//                        Text("See what your 5-minute routine looks like")
//                            .font(.system(size: 16))
//                            .foregroundColor(.gray)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal, 40)
//                        
//                        VStack(spacing: 8) {
//                            Text("Most users see results within 2–4 weeks.")
//                                .font(.system(size: 15, weight: .medium))
//                                .foregroundColor(.white)
//                                .multilineTextAlignment(.center)
//                            
//                            Text("Your plan adapts as you get stronger — don't lose this setup.")
//                                .font(.system(size: 13))
//                                .foregroundColor(.orange)
//                                .multilineTextAlignment(.center)
//                        }
//                        .padding(.horizontal, 40)
//                        .padding(.bottom, 10)
//                
//                // Sample Exercise Animation
//                VStack(spacing: 20) {
//                    ZStack {
//                        // Outer glow ring
//                        Circle()
//                            .stroke(Color.goatBlue.opacity(0.3), lineWidth: 4)
//                            .frame(width: 140, height: 140)
//                            .scaleEffect(isAnimating ? 1.1 : 1.0)
//                            .opacity(isAnimating ? 0.6 : 0.3)
//                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
//                        
//                        // Base progress ring
//                        Circle()
//                            .stroke(Color.white.opacity(0.2), lineWidth: 6)
//                            .frame(width: 120, height: 120)
//                        
//                        // Animated progress ring
//                        Circle()
//                            .trim(from: 0, to: isAnimating ? 1 : 0)
//                            .stroke(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [Color.goatBlue, Color.cyan]),
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                ),
//                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
//                            )
//                            .frame(width: 120, height: 120)
//                            .rotationEffect(.degrees(-90))
//                            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: false), value: isAnimating)
//                        
//                        // Pulsing center circle
//                        Circle()
//                            .fill(Color.goatBlue.opacity(0.2))
//                            .frame(width: 80, height: 80)
//                            .scaleEffect(isAnimating ? 1.05 : 0.95)
//                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
//                        
//                        // Exercise icon with bounce
//                        Image(systemName: "figure.core.training")
//                            .font(.system(size: 40))
//                            .foregroundColor(.white)
//                            .scaleEffect(isAnimating ? 1.1 : 1.0)
//                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
//                    }
//                    .onAppear {
//                        withAnimation {
//                            isAnimating = true
//                        }
//                    }
//                    
//                    Text(sampleExercises[currentExerciseIndex])
//                        .font(.system(size: 24, weight: .semibold))
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//                        .animation(.easeInOut, value: currentExerciseIndex)
//                    
//                    Text("30 seconds")
//                        .font(.system(size: 16))
//                        .foregroundColor(.gray)
//                }
//                .padding(.bottom, 40)
//                
//                // Exercise List Preview
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Your 5-minute routine includes:")
//                        .font(.system(size: 18, weight: .medium))
//                        .foregroundColor(.white)
//                        .padding(.bottom, 10)
//                    
//                    ForEach(sampleExercises.indices, id: \.self) { index in
//                        HStack(spacing: 12) {
//                            ZStack {
//                                Circle()
//                                    .fill(index == currentExerciseIndex ? Color.goatBlue : Color.gray.opacity(0.3))
//                                    .frame(width: 24, height: 24)
//                                
//                                if index == currentExerciseIndex {
//                                    Image(systemName: "play.fill")
//                                        .font(.system(size: 10))
//                                        .foregroundColor(.white)
//                                        .scaleEffect(isAnimating ? 1.2 : 1.0)
//                                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
//                                } else {
//                                    Text("\(index + 1)")
//                                        .font(.system(size: 12, weight: .medium))
//                                        .foregroundColor(.white)
//                                }
//                            }
//                            
//                            Text(sampleExercises[index])
//                                .font(.system(size: 16))
//                                .foregroundColor(index == currentExerciseIndex ? .white : .gray)
//                            
//                            Spacer()
//                            
//                            Text("30s")
//                                .font(.system(size: 14))
//                                .foregroundColor(.gray)
//                        }
//                    }
//                        }
//                        .padding(.horizontal, 40)
//                        .padding(.bottom, 100) // Space for bottom buttons
//                    }
//                }
//                
//                // Fixed bottom buttons
//                VStack(spacing: 16) {
//                    Button("SKIP PREVIEW") {
//                        AnalyticsManager.shared.trackPreviewWorkoutSkipped()
//                        withAnimation {
//                            currentStep += 1
//                        }
//                    }
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.gray)
//                    
//                    Button("GET FULL ACCESS") {
//                        withAnimation {
//                            currentStep += 1
//                        }
//                    }
//                    .font(.system(size: 18, weight: .medium))
//                    .foregroundColor(.white)
//                    .frame(width: UIScreen.main.bounds.size.width * 0.8)
//                    .padding()
//                    .background(Color.goatBlue)
//                    .cornerRadius(12)
//                }
//                .padding(.bottom, 50)
//                .background(Color.black)
//            }
//        }
//        .onAppear {
//            // Track preview workout shown
//            AnalyticsManager.shared.trackPreviewWorkoutShown()
//            
//            // Auto-cycle through exercises
//            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//                withAnimation(.easeInOut(duration: 0.5)) {
//                    currentExerciseIndex = (currentExerciseIndex + 1) % sampleExercises.count
//                }
//            }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
