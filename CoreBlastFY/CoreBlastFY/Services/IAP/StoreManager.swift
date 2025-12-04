//
//  StoreManager.swift
//  CoreBlastFY
//
//  Created by Riccardo Washington on 5/17/20.
//  Copyright © 2020 Riccardo Washington. All rights reserved.
//
/*
Abstract:
Retrieves product information from the App Store using SKRequestDelegate, SKProductsRequestDelegate, SKProductsResponse, and SKProductsRequest.
Notifies its observer with a list of products available for sale along with a list of invalid product identifiers. Logs an error message if the
product request failed.
*/

import StoreKit
import Foundation
import Combine
// MARK: - StoreManagerDelegate

protocol StoreManagerDelegate: AnyObject {
    /// Provides the delegate with the error encountered during the product request.
    func storeManagerDidReceiveMessage(_ message: String)
}
typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}

class StoreManager: NSObject, ObservableObject {
    // MARK: - Types

    static let shared = StoreManager()
    
    @Published var isPremium: Bool = false
    @Published private(set) var subscriptions: [Product]
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    @Published private(set) var membershipStartDate: Date?
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    var cancellable: AnyCancellable?
    
    private override init() {
        subscriptions = []
        super.init()
      
        //Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()

        Task {
            //During store initialization, request products from the App Store.
            await requestProducts()

            //Deliver products that the customer purchases.
            await updateCustomerProductStatus()
        }
        
        cancellable = $subscriptionGroupStatus
            .map { $0 }
            .sink { [weak self] value in
                self?.isPremium = value == .subscribed
            }
    }

    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Management
    
    @MainActor
    func requestProducts() async {
        do {
            //Request products from the App Store using the identifiers that the Products.plist file defines.
            let storeProducts = try await Product.products(for: InAppIds.subscriptions)
            
            var newSubscriptions: [Product] = []
            
            //Filter the products into different categories based on their type.
            for product in storeProducts {
                switch product.type {
                case .autoRenewable:
                    newSubscriptions.append(product)
                default:
                    //Ignore this product.
                    print("Unknown product type: \(product.type)")
                }
            }
            
            //Sort each product category by price, lowest to highest, to update the store.
            subscriptions = sortByPrice(newSubscriptions)
            
            print("✅ Successfully loaded \(subscriptions.count) subscription products")
            subscriptions.forEach { product in
                print("📱 Product: \(product.id) - \(product.displayPrice)")
            }
            
        } catch {
            print("❌ Failed product request from the App Store server: \(error)")
        }
    }
    
    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
    
    // MARK: - Purchase Management
    
    @MainActor
    func purchase(_ product: Product) async throws -> Transaction? {
        //Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            //Check whether the transaction is verified. If it isn't,
            //this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            //The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()

            //Always finish a transaction.
            await transaction.finish()
            
            // Track successful purchase in Analytics
            AnalyticsManager.shared.trackSubscriptionStarted(
                productId: product.id, 
                price: Double(truncating: product.price as NSNumber)
            )
            AnalyticsManager.shared.setSubscriptionStatus(true)
            
            // Notify success
            NotificationCenter.default.post(name: PurchaseSuccess, object: nil)
            print("✅ Purchase successful: \(product.id)")

            return transaction
        case .userCancelled:
            // User cancelled the purchase
            NotificationCenter.default.post(name: PurchaseCancelled, object: nil)
            print("🚫 Purchase cancelled by user")
            return nil
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or approval from a parent
            print("⏳ Purchase pending approval")
            return nil
        @unknown default:
            print("❌ Unknown purchase result")
            return nil
        }
    }
    
    func getProduct(for productID: String) -> Product? {
        return subscriptions.first { $0.id == productID }
    }
    
    // MARK: - Restore Purchases
    
    @MainActor
    func restorePurchases() async {
        do {
            //This call displays a system prompt that asks users to authenticate with their App Store credentials.
            //Call this function only in response to an explicit user action, such as tapping a button.
            try await AppStore.sync()
            
            //Update customer product status after restore
            await updateCustomerProductStatus()
            
            print("✅ Restore completed successfully")
            
        } catch {
            print("❌ Restore failed: \(error.localizedDescription)")
            // You can notify the UI about restore failure here
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    //Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSubscriptions: [Product] = []

        //Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)

                //Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        purchasedSubscriptions.append(subscription)
                        
                        // Capture the original purchase date as membership start date
                        if membershipStartDate == nil || transaction.originalPurchaseDate < membershipStartDate! {
                            membershipStartDate = transaction.originalPurchaseDate
                        }
                    }
                default:
                    break
                }
            } catch {
                print()
            }
        }

        //Update the store information with auto-renewable subscription products.
        self.purchasedSubscriptions = purchasedSubscriptions

        //Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
        //is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
        //group, so products in the subscriptions array all belong to the same group. The statuses that
        //`product.subscription.status` returns apply to the entire subscription group.
        subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }


    // MARK: - Properties

    /// Keeps track of all valid products. These products are available for sale in the App Store.
    fileprivate var availableProducts: [String?] = InAppIds.all

    weak var delegate: StoreManagerDelegate?

    // MARK: - Initializer

  //  private override init() {}

    // MARK: - Request Product Information
    
     func isPurchased(with id: String) -> Bool {
            let purchaseRecipt = UserDefaults.standard.bool(forKey: id)
            return purchaseRecipt
        }

    /// Legacy method for backward compatibility - now uses StoreKit 2
    func startProductRequest(with identifiers: String) {
        Task {
            guard let product = getProduct(for: identifiers) else {
                print("❌ Product not found: \(identifiers)")
                NotificationCenter.default.post(name: PurchaseCancelled, object: nil)
                return
            }
            
            do {
                let _ = try await purchase(product)
            } catch {
                print("❌ Purchase failed: \(error.localizedDescription)")
                NotificationCenter.default.post(name: PurchaseCancelled, object: nil)
            }
        }
    }
}


// MARK: - SKRequestDelegate

/// Extends StoreManager to conform to SKRequestDelegate.
extension StoreManager: SKRequestDelegate {
    /// Called when the product request failed.
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.delegate?.storeManagerDidReceiveMessage(error.localizedDescription)
        }
    }
}
