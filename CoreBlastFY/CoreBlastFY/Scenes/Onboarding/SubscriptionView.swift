//
//  SubscriptionView.swift
//  Sixpack Blueprint
//
//  Created by Riccardo Washington on 10/11/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

struct SubscriptionOption: Identifiable, Equatable {
    let id: String
    let title: String
    let price: String
    let billingPeriod: String
    let savings: String?
    let cta: String
    let ctaTitle: String
    var freeTrial = false
}

class PurchaseViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    var callBack: ((Bool) -> Void)?
    @Published var isPurchasing = false
    @Published var errorMessage: String = ""
    @Published var showError = false
    
    init() {
        // Add observers for notifications
        NotificationCenter.default.publisher(for: PurchaseSuccess)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.purchaseSuccess()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: PurchaseCancelled)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.purchaseCancelled()
                }
            }
            .store(in: &cancellables)
    }
    
    func restore() {
        Task {
            await StoreManager.shared.restorePurchases()
        }
    }
    
    func purchase(productID: String) {
        guard !isPurchasing else { return }
        
        isPurchasing = true
        errorMessage = ""
        showError = false
        
        Task {
            do {
                guard let product = StoreManager.shared.getProduct(for: productID) else {
                    await MainActor.run {
                        self.showError(message: "Product not available. Please try again later.")
                    }
                    return
                }
                
                let _ = try await StoreManager.shared.purchase(product)
                
            } catch {
                await MainActor.run {
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    @MainActor
    private func showError(message: String) {
        errorMessage = message
        showError = true
        isPurchasing = false
        
        // Track payment failure if we have context
        // Note: This is a simple implementation - ideally you'd track the specific product ID
        AnalyticsManager.shared.trackSubscriptionPaymentFailed(
            productId: "unknown", 
            error: message
        )
    }
    
    // Handle purchase success
    func purchaseSuccess() {
        withAnimation {
            isPurchasing = false
            showError = false
        }
        callBack?(true)
    }
    
    // Handle purchase cancellation
    func purchaseCancelled() {
        withAnimation {
            isPurchasing = false
        }
        callBack?(false)
    }
}


struct SubscriptionView: View {
    var callBack: ((Bool) -> Void)?
    
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedOption: SubscriptionOption?
    @State private var showOneTimeOffer = false  // One-time offer enabled
    @State private var currentTestimonialIndex = 0
    @StateObject private var viewModel = PurchaseViewModel()
    
    // Dynamic subscription options based on available products
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
            case InAppIds.premiumWeekly:
                option = SubscriptionOption(
                    id: product.id,
                    title: "Weekly",
                    price: product.displayPrice + " / wk",
                    billingPeriod: "per week",
                    savings: nil,
                    cta: "SUBSCRIBE",
                    ctaTitle: "\(product.displayPrice) weekly. Cancel Anytime."
                )
            default:
                continue
            }
            dynamicOptions.append(option)
        }
        
        // Fallback to hardcoded options if products aren't loaded yet
        if dynamicOptions.isEmpty {
            return [
                SubscriptionOption(id: InAppIds.premiumAnnual, title: "Yearly", price: "$1.67 / mo", billingPeriod: "$19.99", savings: "Save 65%", cta: "START FREE TRIAL", ctaTitle: "7-day free trial, then $19.99/year. Cancel Anytime.", freeTrial: true),
                SubscriptionOption(id: InAppIds.premiumMonthly, title: "Monthly", price: "$4.99 / mo", billingPeriod: "per month", savings: nil, cta: "SUBSCRIBE", ctaTitle: "$4.99 monthly. Cancel Anytime."),
                SubscriptionOption(id: InAppIds.premiumWeekly, title: "Weekly", price: "$2.99 / wk", billingPeriod: "per week", savings: nil, cta: "SUBSCRIBE", ctaTitle: "$2.99 weekly. Cancel Anytime.")
            ]
        }
        
        // Sort: Yearly first, Monthly second, Weekly third
        return dynamicOptions.sorted { lhs, rhs in
            let order: [String: Int] = [InAppIds.premiumAnnual: 0, InAppIds.premiumMonthly: 1, InAppIds.premiumWeekly: 2]
            return (order[lhs.id] ?? 99) < (order[rhs.id] ?? 99)
        }
    }
   
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.7, blue: 0.6),  // Soft teal
                    Color(red: 0.3, green: 0.6, blue: 0.5)   // Deeper green
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            contentBody
       
            if viewModel.isPurchasing {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Processing purchase...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
            
            // One-Time Offer Modal Overlay
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
            selectedOption = options.first // Select yearly by default
            
            // Track subscription view shown
            AnalyticsManager.shared.trackSubscriptionViewShown(trigger: "onboarding")
            
            viewModel.callBack = { success in
                if success {
                    callBack?(success)
                }
            }
        }
        .alert("Purchase Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.showError = false
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    var contentBody: some View {
        VStack(spacing: 0) {
            // Top benefits bar (like status bar area)
            VStack(spacing: 4) {
                HStack {
                    Button(action: {
                        // Disabled one-time offer for now
                        // AnalyticsManager.shared.trackOneTimeOfferShown()
                        // showOneTimeOffer = true
                        
                        // Instead, just dismiss normally
                        callBack?(false)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    // Main Title and Value Proposition
                    VStack(spacing: 12) {
                        Text("Get Visible Abs in 5\nMinutes a Day")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        Text("Daily workouts build momentum—most users see results within 2–4 weeks.")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .padding(.top, 30)
                    
                    // Exercise Icons Section moved up
                    HStack(spacing: 20) {
                        ExerciseIcon(systemName: "figure.core.training", color: .green)
                        ExerciseIcon(systemName: "figure.strengthtraining.traditional", color: .orange)
                        ExerciseIcon(systemName: "flame.fill", color: .red)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                
                // Feel Great Section
                VStack(spacing: 20) {
                    Text("Feel Great with Just 5\nMinutes a Day.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.top, 30)
                    
                    // Benefits List
                    VStack(spacing: 16) {
                        CoreBenefitRow(text: "Build Core Strength")
                        CoreBenefitRow(text: "Improve Posture") 
                        CoreBenefitRow(text: "Get Visible Abs")
                        CoreBenefitRow(text: "Boost Confidence")
                        CoreBenefitRow(text: "Increase Stability")
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.top, 20)
                
                // Community Section
                VStack(spacing: 15) {
                    
                    // Testimonial Carousel
                    TestimonialCarousel(currentIndex: $currentTestimonialIndex)
                    
                    // Pagination dots
                    HStack(spacing: 8) {
                        ForEach(0..<testimonials.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentTestimonialIndex ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Star Rating
                    HStack(spacing: 8) {
                        Image(systemName: "laurel.leading")
                            .foregroundColor(.white)
                            .opacity(0.8)
                        
                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 16))
                            }
                        }
                        
                        Image(systemName: "laurel.trailing")
                            .foregroundColor(.white)
                            .opacity(0.8)
                    }
                    
                    Text("Join 50,000+ people building their best core")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .opacity(0.9)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                .padding(.bottom, 40) // Extra padding for sticky bottom content
                }
            }
            
            // Sticky bottom section with pricing options - compact
            VStack(spacing: 0) {
                // Pricing Options - much more compact
                VStack(spacing: 10) {
                    ForEach(options.indices, id: \.self) { index in
                        let option = options[index]
                        let isPopular = index == 0 // First option (Yearly) is most popular
                        
                        PricingOptionView(
                            option: option,
                            isSelected: selectedOption?.id == option.id,
                            isPopular: isPopular
                        ) {
                            // Select the option when tapped
                            selectedOption = option
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                
                // Main CTA Button with urgency
                Button(action: {
                    guard let option = selectedOption else { return }
                    
                    // Track subscription option selection and payment started
                    AnalyticsManager.shared.trackSubscriptionOptionSelected(
                        productId: option.id,
                        isYearly: option.id == InAppIds.premiumAnnual
                    )
                    AnalyticsManager.shared.trackSubscriptionPaymentStarted(productId: option.id)
                    viewModel.purchase(productID: option.id)
                }) {
                    VStack(spacing: 6) {
                        HStack {
                            Text("🔥 CLAIM YOUR TRANSFORMATION")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Text("Start Your 6-12 Week Journey Today")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.9),
                                Color.orange.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(viewModel.isPurchasing ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.isPurchasing)
                }
                .padding(.horizontal, 18)
                .padding(.top, 15)
                .disabled(selectedOption == nil || viewModel.isPurchasing)
                
                // Restore Purchases - compact
                Button("Restore Purchases") {
                    viewModel.restore()
                }
                .font(.system(size: 14))
                .foregroundColor(.white)
                .opacity(0.7)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .disabled(viewModel.isPurchasing)
            }
            .background(
                // Add subtle gradient overlay to separate sticky section
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

// Testimonial data
let testimonials = [
    Testimonial(
        title: "Why I love Sixpack Blueprint",
        content: "I use this at least once a day. Sometimes two or three times. It's the first thing I do in the morning. I use it to train my core after cardio. Some days I use it during work breaks. Easy to follow workouts. Keeps you on track. Feel strong afterwards."
    ),
    Testimonial(
        title: "Game changer for my abs",
        content: "Never thought I'd see real definition until I started using this app. The progressive workouts are challenging but doable. I've been consistent for 3 months and my core strength has improved dramatically."
    ),
    Testimonial(
        title: "Perfect for busy schedules",
        content: "As someone with a hectic work life, these quick core sessions fit perfectly into my routine. The variety keeps things interesting and I love tracking my progress."
    )
]

struct Testimonial {
    let title: String
    let content: String
}

// Benefits row with checkmark
struct BenefitRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// Core benefits row with checkmark circle
struct CoreBenefitRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// Exercise icon component
struct ExerciseIcon: View {
    let systemName: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.8))
                .frame(width: 60, height: 60)
            
            Image(systemName: systemName)
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
    }
}

// Testimonial carousel component
struct TestimonialCarousel: View {
    @Binding var currentIndex: Int
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(testimonials.indices, id: \.self) { index in
                TestimonialCard(testimonial: testimonials[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 160)
        .onAppear {
            // Auto-scroll testimonials every 5 seconds
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentIndex = (currentIndex + 1) % testimonials.count
                }
            }
        }
    }
}

// Updated testimonial card component
struct TestimonialCard: View {
    let testimonial: Testimonial
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(testimonial.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                }
            }
            
            Text(testimonial.content)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .opacity(0.9)
                .lineLimit(nil)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
        .padding(.horizontal, 20)
    }
}

// New pricing option view
struct PricingOptionView: View {
    let option: SubscriptionOption
    let isSelected: Bool
    let isPopular: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 1.5)
                )
            
            HStack(spacing: 12) {
                // Left side - title and billing
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
                
                // Right side - price and savings in single line
                HStack(spacing: 8) {
                    Text(option.price)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if let savings = option.savings {
                        Text(savings)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            
            // Most Popular Badge - tiny
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
                            .offset(x: -4, y: -6)
                    }
                    Spacer()
                }
            }
        }
        .frame(height: 56)
        .onTapGesture {
            onTap()
        }
    }
}

// One-Time Offer Modal
struct OneTimeOfferModal: View {
    @Binding var isPresented: Bool
    var onPurchase: (SubscriptionOption) -> Void
    var onDismiss: (() -> Void)?
    
    let discountOption = SubscriptionOption(
        id: InAppIds.premiumAnnual,
        title: "Yearly",
        price: "$1.99 / mo",
        billingPeriod: "$23.99",
        savings: "Lifetime Discount",
        cta: "CLAIM OFFER",
        ctaTitle: "$23.99 Billed annually. Cancel Anytime."
    )
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                    onDismiss?()
                }
            
            VStack {
                Spacer()
                
                ZStack {
                    // Blue gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.6, blue: 1.0),
                            Color(red: 0.4, green: 0.3, blue: 0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    
                    VStack(spacing: 20) {
                        // Header with close button only
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                isPresented = false
                                onDismiss?()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.top, 15)
                        .padding(.horizontal, 20)
                        
                        // Main offer content
                        VStack(spacing: 15) {
                            Text("Your One-Time Offer")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            // Highlighted offer box with sparkles
                            ZStack {
                                // Sparkle effects
                                SparkleEffect(position: CGPoint(x: -60, y: -20), size: 20)
                                SparkleEffect(position: CGPoint(x: 70, y: -30), size: 25)
                                SparkleEffect(position: CGPoint(x: -45, y: 35), size: 15)
                                SparkleEffect(position: CGPoint(x: 65, y: 40), size: 20)
                                
                                // Main offer box
                                VStack(spacing: 8) {
                                    Text("$56 OFF")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("FOREVER")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 30)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.cyan, lineWidth: 3)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.goatBlue.opacity(0.3))
                                        )
                                )
                            }
                            
                            // Price comparison
                            VStack(spacing: 8) {
                                HStack(spacing: 12) {
                                    Text("$79.99")
                                        .font(.system(size: 24, weight: .medium))
                                        .strikethrough()
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Text("$23.99/year")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.cyan)
                                }
                                
                                Text("Once you close your one-time offer, it's gone!")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // Bottom section - more compact
                        VStack(spacing: 12) {
                            OneTimeOfferPlan(option: discountOption) {
                                onPurchase(discountOption)
                                isPresented = false
                            }
                            
                            // Terms
                            Text("7 day free trial then $1.99 monthly. Cancel Anytime.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 30)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.55)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// Sparkle effect component
struct SparkleEffect: View {
    let position: CGPoint
    let size: CGFloat
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: size))
            .foregroundColor(.white)
            .opacity(0.8)
            .offset(x: position.x, y: position.y)
    }
}

// One-time offer plan component
struct OneTimeOfferPlan: View {
    let option: SubscriptionOption
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.cyan, lineWidth: 2)
                    )
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("$79.99")
                                .font(.system(size: 14))
                                .strikethrough()
                                .foregroundColor(.white.opacity(0.6))
                            Text(option.billingPeriod)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(option.price)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(16)
                
                // Lifetime Discount Badge
                VStack {
                    HStack {
                        Spacer()
                        Text("Lifetime Discount")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(12)
                            .offset(x: -8, y: -12)
                    }
                    Spacer()
                }
            }
        }
        .frame(height: 70)
        .padding(.horizontal, 20)
    }
}

// Extension for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
