//
//  ConnectivityManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Reachability
import Network

class ConnectivityData: Event {
    let eventType = "CONNECTION_INFO"
    var value: Connectivity = Connectivity(isConnected: false, isConnectedToWifi: false, isConnectedToMobile: false)
    var time = DateManager.shared.currentDate
}

struct Connectivity: Codable {
    var isConnected: Bool
    var isConnectedToWifi: Bool
    var isConnectedToMobile: Bool
}

final class ConnectivityManager: BasicManagerType {
    var gettingPoolingTime: Double
    var getDataTimer: Timer?
    var data: ConnectivityData = ConnectivityData()
    let reachability = try! Reachability()

    init(gettingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000

        reachability.whenReachable = { [weak self] reachability in
            if reachability.connection == .wifi {
                self?.data.value = Connectivity(isConnected: true, isConnectedToWifi: true, isConnectedToMobile: false)
            } else if reachability.connection == .cellular {
                self?.data.value = Connectivity(isConnected: true, isConnectedToWifi: false, isConnectedToMobile: true)
            } else {
                self?.data.value = Connectivity(isConnected: false, isConnectedToWifi: false, isConnectedToMobile: false)
            }

            self?.data.time = DateManager.shared.currentDate
            guard let unwrappedData = self?.data else { return }
            AlgolyticsSDK.shared.dataToSend.eventList.append(unwrappedData)
        }
        reachability.whenUnreachable = { [weak self] _ in
            self?.data.value = Connectivity(isConnected: false, isConnectedToWifi: false, isConnectedToMobile: false)

            self?.data.time = DateManager.shared.currentDate
            guard let unwrappedData = self?.data else { return }
            AlgolyticsSDK.shared.dataToSend.eventList.append(unwrappedData)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    public func startGettingData() {

    }

    public func stopGettingData() {
        getDataTimer?.invalidate()
        getDataTimer = nil
    }
}
