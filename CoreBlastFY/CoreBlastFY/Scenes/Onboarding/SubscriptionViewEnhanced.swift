//
//  SubscriptionViewEnhanced.swift
//  Sixpack Blueprint
//
//  Created by Assistant on 12/23/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

struct SubscriptionViewEnhanced: View {
    var callBack: ((Bool) -> Void)?
    
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedOption: SubscriptionOption?
    @State private var currentTestimonialIndex = 0
    @StateObject private var viewModel = PurchaseViewModel()
    @State private var showContent = false
    @State private var animateBenefits = false
    @State private var animateIcons = false
    @State private var pulseSubscribe = false
    @State private var showOneTimeOffer = false
    @State private var showDismiss = false
    
    // Dynamic subscription options
    private var options: [SubscriptionOption] {
        var dynamicOptions: [SubscriptionOption] = []
        
        for product in storeManager.subscriptions {
            let option: SubscriptionOption
            
            switch product.id {
            case InAppIds.premiumAnnual:
                let monthlyPrice = product.price / 12
                let hasFreeTrial = product.subscription?.introductoryOffer != nil
                option = SubscriptionOption(
                    id: product.id,
                    title: "Yearly",
                    price: monthlyPrice.formatted(.currency(code: product.priceFormatStyle.currencyCode)) + " / mo",
                    billingPeriod: product.displayPrice,
                    savings: "Save 65%",
                    cta: hasFreeTrial ? "START FREE TRIAL" : "SUBSCRIBE",
                    ctaTitle: hasFreeTrial
                        ? "7-day free trial, then \(product.displayPrice)/year. Cancel Anytime."
                        : "\(product.displayPrice) billed annually. Cancel Anytime.",
                    freeTrial: hasFreeTrial
                )
            case InAppIds.premiumMonthly:
                option = SubscriptionOption(
                    id: product.id,
                    title: "Monthly",
                    price: product.displayPrice + " / mo",
                    billingPeriod: "per month",
                    savings: nil,
                    cta: "SUBSCRIBE",
                    ctaTitle: "\(product.displayPrice) monthly. Cancel Anytime."
                )
            default:
                continue
            }
            dynamicOptions.append(option)
        }
        
        if dynamicOptions.isEmpty {
            return [
                SubscriptionOption(id: InAppIds.premiumAnnual, title: "Yearly", price: "$1.67 / mo", billingPeriod: "$19.99", savings: "Save 65%", cta: "START FREE TRIAL", ctaTitle: "7-day free trial, then $19.99/year. Cancel Anytime.", freeTrial: true),
                SubscriptionOption(id: InAppIds.premiumMonthly, title: "Monthly", price: "$4.99 / mo", billingPeriod: "per month", savings: nil, cta: "SUBSCRIBE", ctaTitle: "$4.99 monthly. Cancel Anytime.")
            ]
        }
        
        // Sort: Yearly first, Monthly second
        return dynamicOptions.sorted { lhs, rhs in
            let order: [String: Int] = [InAppIds.premiumAnnual: 0, InAppIds.premiumMonthly: 1]
            return (order[lhs.id] ?? 99) < (order[rhs.id] ?? 99)
        }
    }
    
    // CTA button label based on selected plan
    private var ctaButtonTitle: String {
        guard let option = selectedOption else { return "Get Started" }
        if option.freeTrial { return "Try Free for 7 Days" }
        switch option.id {
        case InAppIds.premiumAnnual:  return "Get Yearly Access"
        case InAppIds.premiumMonthly: return "Get Monthly Access"
        case InAppIds.premiumWeekly:  return "Get Weekly Access"
        default:                      return "Subscribe Now"
        }
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            
            contentBody
       
            if viewModel.isPurchasing {
                LoadingOverlay()
            }
            
            // One-Time Offer Modal
            if showOneTimeOffer {
                OneTimeOfferModal(
                    isPresented: $showOneTimeOffer,
                    onPurchase: { option in
                        AnalyticsManager.shared.trackOneTimeOfferAccepted()
                        viewModel.purchase(productID: option.id)
                    },
                    onDismiss: {
                        AnalyticsManager.shared.trackOneTimeOfferDismissed()
                        callBack?(false)
                    }
                )
            }
        }
        .onAppear {
            selectedOption = options.first
            AnalyticsManager.shared.trackSubscriptionViewShown(trigger: "onboarding")
            FacebookManager.shared.logEvent(.paywallShown)
            
            viewModel.callBack = { success in
                if success {
                    HapticFeedbackManager.shared.subscriptionSuccess()
                    callBack?(success)
                }
            }
            
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateBenefits = true
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                animateIcons = true
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.0)) {
                pulseSubscribe = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeIn(duration: 0.3)) { showDismiss = true }
            }
        }
        .alert("Purchase Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.showError = false
                HapticFeedbackManager.shared.error()
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    var contentBody: some View {
        VStack(spacing: 0) {
            // Close button with animation
            VStack(spacing: 4) {
                HStack {
                    Button(action: {
                        HapticFeedbackManager.shared.impact(.medium)
                        AnalyticsManager.shared.trackOneTimeOfferShown()
                        showOneTimeOffer = true
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .scaleEffect(showContent ? 1 : 0)
                    .opacity(showDismiss ? 1 : 0)
                    .disabled(!showDismiss)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: showContent)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    // Animated title
                    VStack(spacing: 12) {
                        Text("Get Visible Abs in 5\nMinutes a Day")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .scaleEffect(showContent ? 1 : 0.8)
                            .opacity(showContent ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                        
                        Text("Daily workouts build momentum—most users see results within 2–4 weeks.")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                    }
                    .padding(.top, 30)
                    
                    // Animated Exercise Icons
                    HStack(spacing: 20) {
                        AnimatedExerciseIcon(systemName: "figure.core.training", color: .green, delay: 0, isAnimating: animateIcons)
                        AnimatedExerciseIcon(systemName: "figure.strengthtraining.traditional", color: .orange, delay: 0.2, isAnimating: animateIcons)
                        AnimatedExerciseIcon(systemName: "flame.fill", color: .red, delay: 0.4, isAnimating: animateIcons)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .scaleEffect(animateIcons ? 1 : 0.9)
                            .opacity(animateIcons ? 1 : 0)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                
                    // Animated Benefits Section
                    VStack(spacing: 20) {
                        Text("Feel Great with Just 5\nMinutes a Day.")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 30)
                            .fadeInAnimation(delay: 0.6)
                        
                        VStack(spacing: 16) {
                            ForEach(Array(["Build Core Strength", "Improve Posture", "Get Visible Abs", "Boost Confidence", "Increase Stability"].enumerated()), id: \.offset) { index, benefit in
                                AnimatedBenefitRow(text: benefit, index: index, isAnimating: animateBenefits)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    
                    // Enhanced Testimonial Section
                    VStack(spacing: 15) {
                        EnhancedTestimonialCarousel(currentIndex: $currentTestimonialIndex)
                        
                        // Animated pagination dots
                        HStack(spacing: 8) {
                            ForEach(0..<testimonials.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentTestimonialIndex ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: index == currentTestimonialIndex ? 10 : 8, height: index == currentTestimonialIndex ? 10 : 8)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentTestimonialIndex)
                            }
                        }
                        .padding(.top, 8)
                        
                        // Animated star rating
                        AnimatedStarRating()
                        
                        Text("Join 50,000+ people building their best core")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .opacity(0.9)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            
            // Enhanced sticky bottom with animations
            VStack(spacing: 0) {
                // Plan selector — tap to select only, no immediate purchase
                VStack(spacing: 10) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        EnhancedPricingOption(
                            option: option,
                            isSelected: selectedOption?.id == option.id,
                            isPopular: index == 0,
                            isPulsing: pulseSubscribe && index == 0
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedOption = option
                            }
                            HapticFeedbackManager.shared.selectionChanged()
                        }
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.8 + Double(index) * 0.1), value: showContent)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                
                // Benefit checkmarks — social proof near CTA
                HStack(spacing: 0) {
                    Spacer()
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(["5-minute daily workouts", "No equipment needed", "Cancel anytime"], id: \.self) { benefit in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                Text(benefit)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(1.0), value: showContent)
                
                // CTA Button
                Button(action: {
                    guard let option = selectedOption else { return }
                    HapticFeedbackManager.shared.rhythmicSelection()
                    AnalyticsManager.shared.trackSubscriptionOptionSelected(
                        productId: option.id,
                        isYearly: option.id == InAppIds.premiumAnnual
                    )
                    AnalyticsManager.shared.trackSubscriptionPaymentStarted(productId: option.id)
                    FacebookManager.shared.logEvent(.ctaTapped, parameters: ["product_id": option.id])
                    viewModel.purchase(productID: option.id)
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.8)
                        }
                        Text(ctaButtonTitle)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color(red: 0.9, green: 0.97, blue: 0.95)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: Color.white.opacity(0.4), radius: 8, x: 0, y: 4)
                    .scaleEffect(pulseSubscribe ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseSubscribe)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .disabled(selectedOption == nil || viewModel.isPurchasing)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.9)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.1), value: showContent)
                
                // Billing subtitle
                if let option = selectedOption {
                    Text(option.ctaTitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 6)
                }
                
                Button("Restore Purchases") {
                    HapticFeedbackManager.shared.buttonTap()
                    viewModel.restore()
                }
                .font(.system(size: 14))
                .foregroundColor(.white)
                .opacity(0.7)
                .padding(.top, 10)
                .disabled(viewModel.isPurchasing)
                
                // FAQ — removes last-second doubt
                VStack(spacing: 8) {
                    FAQRow(question: "When does billing start?", answer: "After your free trial ends. Not before.")
                    FAQRow(question: "Can I cancel anytime?", answer: "Yes — cancel in 1 tap from Settings.")
                    FAQRow(question: "Is a credit card required now?", answer: "No charge until your trial is over.")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(1.2), value: showContent)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: Color.black.opacity(0.6), radius: 12, x: 0, y: -6)
        }
    }
}

// MARK: - Animated Components

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.7, blue: 0.6),
                Color(red: 0.3, green: 0.6, blue: 0.5)
            ]),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct AnimatedExerciseIcon: View {
    let systemName: String
    let color: Color
    let delay: Double
    let isAnimating: Bool
    @State private var bounce = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.8))
                .frame(width: 60, height: 60)
                .scaleEffect(bounce ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true).delay(delay), value: bounce)
            
            Image(systemName: systemName)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .rotationEffect(.degrees(bounce ? 10 : -10))
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(delay), value: bounce)
        }
        .scaleEffect(isAnimating ? 1 : 0)
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay), value: isAnimating)
        .onAppear {
            bounce = true
        }
    }
}

struct AnimatedBenefitRow: View {
    let text: String
    let index: Int
    let isAnimating: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(Double(index) * 0.1 + 0.2), value: isAnimating)
            }
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(x: isAnimating ? 0 : -30)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1), value: isAnimating)
    }
}

struct EnhancedTestimonialCarousel: View {
    @Binding var currentIndex: Int
    @State private var dragOffset: CGSize = .zero
    @State private var testimonialTimer: Timer? = nil
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(testimonials.indices, id: \.self) { index in
                EnhancedTestimonialCard(testimonial: testimonials[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 160)
        .onChange(of: currentIndex) { _ in
            HapticFeedbackManager.shared.selectionChanged()
        }
        .onAppear {
            testimonialTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    currentIndex = (currentIndex + 1) % testimonials.count
                }
            }
        }
        .onDisappear {
            // Clean up timer when view disappears
            testimonialTimer?.invalidate()
            testimonialTimer = nil
        }
    }
}

struct EnhancedTestimonialCard: View {
    let testimonial: Testimonial
    @State private var showContent = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(testimonial.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : -10)
                .animation(.easeOut(duration: 0.4), value: showContent)
            
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                        .scaleEffect(showContent ? 1 : 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(Double(index) * 0.05), value: showContent)
                }
            }
            
            Text(testimonial.content)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .opacity(0.9)
                .lineLimit(nil)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
                .scaleEffect(showContent ? 1 : 0.95)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showContent)
        )
        .padding(.horizontal, 20)
        .onAppear {
            showContent = true
        }
    }
}

struct AnimatedStarRating: View {
    @State private var animateStars = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "laurel.leading")
                .foregroundColor(.white)
                .opacity(0.8)
                .scaleEffect(animateStars ? 1 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: animateStars)
            
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                        .scaleEffect(animateStars ? 1 : 0)
                        .rotationEffect(.degrees(animateStars ? 0 : 180))
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(index) * 0.1), value: animateStars)
                }
            }
            
            Image(systemName: "laurel.trailing")
                .foregroundColor(.white)
                .opacity(0.8)
                .scaleEffect(animateStars ? 1 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: animateStars)
        }
        .onAppear {
            animateStars = true
        }
    }
}

struct EnhancedPricingOption: View {
    let option: SubscriptionOption
    let isSelected: Bool
    let isPopular: Bool
    let isPulsing: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                onTap()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(isSelected ? 0.25 : 0.15),
                                Color.white.opacity(isSelected ? 0.2 : 0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 1.5)
                    )
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(option.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if option.title == "Yearly" {
                            HStack(spacing: 4) {
                                Text("$79.99")
                                    .font(.system(size: 12))
                                    .strikethrough()
                                    .foregroundColor(.white.opacity(0.6))
                                Text(option.billingPeriod)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        } else {
                            Text(option.billingPeriod)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(option.price)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if let savings = option.savings {
                            Text(savings)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                
                if isPopular {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Most Popular")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Color.white)
                                .cornerRadius(6)
                                .scaleEffect(isPulsing ? 1.05 : 1.0)
                                .offset(x: -4, y: -6)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 56)
            .scaleEffect(isPressed ? 0.98 : (isSelected ? 1.02 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

struct LoadingOverlay: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                CircularProgressAnimation()
                    .frame(width: 50, height: 50)
                
                Text("Processing purchase...")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                
                LoadingDots()
            }
            .padding(30)
            .background(Color.black)
            .cornerRadius(15)
            .scaleEffect(isAnimating ? 1 : 0.9)
            .opacity(isAnimating ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct FAQRow: View {
    let question: String
    let answer: String
    @State private var expanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: { withAnimation(.spring(response: 0.3)) { expanded.toggle() } }) {
                HStack {
                    Text(question)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            if expanded {
                Text(answer)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}
