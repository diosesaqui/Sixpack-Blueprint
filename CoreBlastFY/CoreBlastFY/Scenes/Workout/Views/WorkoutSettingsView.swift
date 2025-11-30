//
//  WorkoutSettingsView.swift
//  CoreBlast
//
//  Created by Claude AI on 11/30/24.
//

import SwiftUI

struct WorkoutSettingsView: View {
    @Binding var isPresented: Bool
    @State private var soundEnabled: Bool = WorkoutFeedbackManager.shared.isSoundEnabledByUser()
    @State private var hapticEnabled: Bool = WorkoutFeedbackManager.shared.isHapticEnabled()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                
                // Settings content
                VStack(alignment: .leading, spacing: 24) {
                    // Sound Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SOUND")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        Toggle(isOn: $soundEnabled) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Workout Sounds")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text("Play sounds at workout start, transitions, and completion")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.horizontal, 20)
                        .onChange(of: soundEnabled) { newValue in
                            WorkoutFeedbackManager.shared.setSoundEnabled(newValue)
                            
                            // Play a sample sound when enabled
                            if newValue {
                                WorkoutFeedbackManager.shared.playExerciseTransitionFeedback()
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Haptic Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HAPTICS")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        Toggle(isOn: $hapticEnabled) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Haptic Feedback")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text("Vibrations for workout events and transitions")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.horizontal, 20)
                        .onChange(of: hapticEnabled) { newValue in
                            WorkoutFeedbackManager.shared.setHapticEnabled(newValue)
                            
                            // Provide haptic feedback when enabled
                            if newValue {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 10)
            }
            .navigationTitle("Workout Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
}

// Preview
struct WorkoutSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutSettingsView(isPresented: .constant(true))
    }
}