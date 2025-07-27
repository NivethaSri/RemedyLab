//
//  Untitled.swift
//  RemedyLab
//
//  Created by nivetha.m on 27/07/25.
//

import Network

class NetworkChecker {
    static let shared = NetworkChecker()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private(set) var isConnected = false

    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
