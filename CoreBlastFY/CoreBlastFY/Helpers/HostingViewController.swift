//
//  HostingViewController.swift
//  Sixpack Blueprint
//
//  Created by Riccardo Washington on 10/11/24.
//  Copyright © 2024 Riccardo Washington. All rights reserved.
//

import SwiftUI
import UIKit

final class HostingViewController<Content: View>: UIViewController {
    
    let hostedView: Content
    
    init(view: Content) {
        self.hostedView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the SwiftUI Subscription View in this UIViewController
        addSwiftUIView()
    }
    
    // Function to add the SwiftUI view to the current view controller
    private func addSwiftUIView() {

        // Wrap the SwiftUI view with a UIHostingController
        let hostingController = UIHostingController(rootView: hostedView)

        // Add the hostingController as a child view controller
        addChild(hostingController)
        
        // Add the hostingController's view to the view hierarchy
        view.addSubview(hostingController.view)
        
        // Set constraints for hostingController's view to match the parent UIViewController's view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Notify the hosting controller that it has been moved to the current view controller
        hostingController.didMove(toParent: self)
    }
}

extension HostingViewController: StoreObserverDelegate {
    func storeObserverDidReceiveMessage(_ message: String) {
        let ac = AlertController.alert(Messages.purchaseStatus, message: message)
        present(ac, animated: true, completion: nil)
    }
    
    func storeObserverRestoreDidSucceed() {
        let ac = AlertController.alert(Messages.purchaseStatus, message: "All successful purchases have been restored.")
        present(ac, animated: true, completion: nil)
        
//        for iap in InAppIds.subscriptions {
//            let bought = StoreManager.shared.isPurchased(with: iap)
//        }
    }
}
