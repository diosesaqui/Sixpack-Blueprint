//
//  MembershipDetailView.swift
//  CoreBlast
//
//  Created by Claude AI on 11/30/24.
//

import SwiftUI

struct MembershipDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storeManager = StoreManager.shared
    @State private var showCancelMembership = false
    
    private var memberSinceDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        
        if let startDate = storeManager.membershipStartDate {
            return formatter.string(from: startDate)
        } else {
            // Fallback if no subscription date is available
            return "Unknown"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Content
                VStack(alignment: .leading, spacing: 32) {
                    // Membership Access Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MEMBERSHIP ACCESS")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("You are currently a Premium member.")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("Ab Workouts Premium is an ad-free experience with unlimited access to all features and routines.")
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Membership History Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MEMBERSHIP HISTORY")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        Text("You've been a member since \(memberSinceDate)")
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Cancel Membership Button
                    Button(action: {
                        showCancelMembership = true
                    }) {
                        Text("Cancel Membership")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .padding(.top, 20)
            }
            .background(Color.black)
            .navigationTitle("Membership")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showCancelMembership) {
            CancelMembershipView()
        }
    }
}

struct CancelMembershipView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("We're sorry to see you go!")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("As a reminder — if you cancel and re-subscribe later on you'll no longer be locked in to your current rate if prices go up.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Thanks for giving Us a try and remember to stay healthy and keep working towards your goals every day!")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cancel Membership")
                        .font(.headline)
                        .underline()
                        .foregroundColor(.primary)
                    
                    Text("For additional instructions, please follow the link:")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Link("https://support.apple.com/HT202039", 
                         destination: URL(string: "https://support.apple.com/HT202039")!)
                        .font(.body)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(Color.black)
            .navigationTitle("Cancel Membership")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("✕") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Preview
struct MembershipDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MembershipDetailView()
    }
}
