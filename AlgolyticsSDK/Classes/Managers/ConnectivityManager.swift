//
//  ConnectivityManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Reachability
import Network

struct ConnectivityData: Codable {
    let eventType = "Connectivity"
    var connectivityInfo: [Connectivity]
    let deviceInfo = DeviceManager()
    let date = DateManager.shared.currentDate
}

struct Connectivity: Codable {
    var isConnected: Bool
    var isConnectedToWifi: Bool
    var isConnectedToCellular: Bool
}

final class ConnectivityManager: BasicManagerType {
    var gettingPoolingTime: Double
    var sendingPoolingTime: Double
    var getDataTimer: Timer?
    var sendDataTimer: Timer?
    var data: ConnectivityData = ConnectivityData(connectivityInfo: [])
    let reachability = try! Reachability()

    init(gettingPoolingTime: Double, sendingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
        self.sendingPoolingTime = sendingPoolingTime / 1000

        reachability.whenReachable = { [weak self] reachability in
            if reachability.connection == .wifi {
                self?.data.connectivityInfo.append(Connectivity(isConnected: true, isConnectedToWifi: true, isConnectedToCellular: false))
            } else if reachability.connection == .cellular {
                self?.data.connectivityInfo.append(Connectivity(isConnected: true, isConnectedToWifi: false, isConnectedToCellular: true))
            } else {
                self?.data.connectivityInfo.append(Connectivity(isConnected: false, isConnectedToWifi: false, isConnectedToCellular: false))
            }
        }
        reachability.whenUnreachable = { [weak self] _ in
            self?.data.connectivityInfo.append(Connectivity(isConnected: false, isConnectedToWifi: false, isConnectedToCellular: false))
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    @objc private func getData() {

    }

    @objc private func sendData() {
        let encoder = JSONEncoder()

            do {
                let jsonData = try encoder.encode(data)

                AlgolyticsSDKService.shared.post(data: jsonData)

            } catch {
                print(error.localizedDescription)
            }

        data = ConnectivityData(connectivityInfo: [])
    }

    public func startGettingData() {
        sendDataTimer = Timer.scheduledTimer(timeInterval: sendingPoolingTime, target: self, selector: #selector(sendData), userInfo: nil, repeats: true)
    }

    public func stopGettingData() {
        getDataTimer?.invalidate()
        getDataTimer = nil

        sendDataTimer?.invalidate()
        sendDataTimer = nil
    }
}
