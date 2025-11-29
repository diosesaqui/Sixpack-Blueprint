//
//  OnboardingView.swift
//  Sixpack Blueprint
//
//  Created by Riccardo Washington on 10/11/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import SwiftUI
import StoreKit

let ratingKey = "ratingKey"

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var selectedTimePreference = ""
    @State private var selectedTime = Date()

    var body: some View {
        NavigationView {
            VStack {
                if currentStep == 0 {
                    WelcomeView(currentStep: $currentStep)
                } else if currentStep == 1 {
                    CoreTrainingImportanceView(currentStep: $currentStep)
                } else if currentStep == 2 {
                    FeelStrongView(currentStep: $currentStep)
                } else if currentStep == 3 {
                    ConsistencyView(currentStep: $currentStep)
                } else if currentStep == 4 {
                    DailyReminderView(currentStep: $currentStep, selectedTime: $selectedTime)
                } else if currentStep == 5 {
                    SubscriptionView() { success in
                        currentStep += 1
                        // Always mark onboarding as completed, regardless of subscription success
                        OnboardingManager.markOnboardingCompleted()
                        OnboardingViewController.completion?()
                    }
                }
            }
            .navigationBarHidden(true)
            .onChange(of: currentStep) { newStep in
                // Track onboarding funnel steps
                trackOnboardingStep(step: newStep)
            }
        }
        .onAppear {
            // Track onboarding started
            AnalyticsManager.shared.trackOnboardingStarted()
        }
    }
    
    private func trackOnboardingStep(step: Int) {
        let stepNames = [
            "welcome",
            "core_training_importance", 
            "feel_strong",
            "consistency",
            "daily_reminder",
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

struct WelcomeView: View {
    @Binding var currentStep: Int

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressIndicator(currentStep: 0, totalSteps: 5)
                    .padding(.top, 20)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                
                Text("Welcome to Sixpack Blueprint")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
                Text("Our mission is to help you build\nchiseled abs every day.")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button("TAP TO CONTINUE") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.bottom, 50)
            }
        }
    }
}

struct CoreTrainingImportanceView: View {
    @Binding var currentStep: Int

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressIndicator(currentStep: 1, totalSteps: 5)
                    .padding(.top, 20)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "figure.core.training")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                
                Text("Core training is important.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
                Text("Every core workout builds strength,\nstability, and gets you closer to\nthose chiseled abs.")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button("TAP TO CONTINUE") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.bottom, 50)
            }
        }
    }
}

struct FeelStrongView: View {
    @Binding var currentStep: Int

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressIndicator(currentStep: 2, totalSteps: 5)
                    .padding(.top, 20)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.8))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                
                Text("Also, you'll feel strong.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
                Text("Core workouts improve your posture,\nreduce back pain, and boost your\noverall athletic performance.")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button("TAP TO CONTINUE") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.bottom, 50)
            }
        }
    }
}

struct ConsistencyView: View {
    @Binding var currentStep: Int

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressIndicator(currentStep: 3, totalSteps: 5)
                    .padding(.top, 20)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.8))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "target")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                
                Text("Consistency is key.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
                Text("Daily core workouts are essential for\nbuilding visible abs. The Sixpack Blueprint\nmakes it simple to train consistently.")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button("TAP TO CONTINUE") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.bottom, 50)
            }
        }
    }
}

struct TimePreferenceView: View {
    @Binding var currentStep: Int
    @Binding var selectedTimePreference: String
    
    let timeOptions = [
        "After waking up",
        "Before breakfast",
        "After cardio",
        "Before showering",
        "During lunch break",
        "After work",
        "Before going to bed",
        "Other"
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressIndicator(currentStep: 4, totalSteps: 6)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("When is a good time for your\ndaily core workout?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 40)
                    
                    Text("Choose an option to continue")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        ForEach(timeOptions, id: \.self) { option in
                            Button(action: {
                                selectedTimePreference = option
                                withAnimation {
                                    currentStep += 1
                                }
                            }) {
                                Text(option)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
    }
}

struct DailyReminderView: View {
    @Binding var currentStep: Int
    @Binding var selectedTime: Date

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressIndicator(currentStep: 4, totalSteps: 5)
                    .padding(.top, 20)
                
                VStack(spacing: 20) {
                    Text("Set your daily reminder to\ntrain your core every day.")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 40)
                    
                    Text("Choose a time below")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .colorScheme(.dark)
                        .padding(.horizontal, 40)
                        .frame(height: 200)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button("SKIP REMINDER") {
                        // Save that reminder was skipped
                        UserAPI.user.selectedTime = nil
                        UserManager.save()
                        
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    
                    Button("NEXT") {
                        UserAPI.user.selectedTime = selectedTime
                        UserManager.save()
                        UserDefaults.standard.setValue(selectedTime, forKey: UserManager.workoutDateKey)
                        
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.size.width * 0.8)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Rectangle()
                    .fill(index <= currentStep ? Color.white : Color.gray.opacity(0.3))
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .padding(.horizontal, 40)
    }
}

struct ContentView: View {
    var body: some View {
        OnboardingView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
