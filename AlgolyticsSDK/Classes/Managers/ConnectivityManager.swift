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
    let eventType = "Connectivity"
    var value: Connectivity = Connectivity(isConnected: false, isConnectedToWifi: false, isConnectedToMobile: false)
//    let deviceInfo = DeviceManager()
    var time = DateManager.shared.currentDate
}

struct Connectivity: Codable {
    var isConnected: Bool
    var isConnectedToWifi: Bool
    var isConnectedToMobile: Bool
}

final class ConnectivityManager: BasicManagerType {
    var gettingPoolingTime: Double
    var sendingPoolingTime: Double
    var getDataTimer: Timer?
    var sendDataTimer: Timer?
    var data: ConnectivityData = ConnectivityData()
    let reachability = try! Reachability()

    init(gettingPoolingTime: Double, sendingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
        self.sendingPoolingTime = sendingPoolingTime / 1000

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

    @objc private func getData() {

    }

    @objc private func sendData() {
//        let encoder = JSONEncoder()
//
//            do {
//                let jsonData = try encoder.encode(data)
//
//                AlgolyticsSDKService.shared.post(data: jsonData)
//
//            } catch {
//                print(error.localizedDescription)
//            }

//        data = ConnectivityData(connectivityInfo: [])
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
