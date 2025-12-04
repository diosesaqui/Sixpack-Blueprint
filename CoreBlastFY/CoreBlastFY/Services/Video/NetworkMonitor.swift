//
//  NetworkMonitor.swift
//  CoreBlastFY
//
//  Created by Claude on 12/4/24.
//

import Foundation
import Network
import Combine

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = false
    @Published var connectionType = NWInterface.InterfaceType.other
    
    var isExpensive: Bool {
        return monitor.currentPath.isExpensive
    }
    
    var isConstrained: Bool {
        return monitor.currentPath.isConstrained
    }
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type ?? .other
            }
        }
        monitor.start(queue: queue)
    }
    
    func shouldDownloadVideo() -> Bool {
        return isConnected && !isExpensive && !isConstrained
    }
    
    deinit {
        monitor.cancel()
    }
}