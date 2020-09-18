//
//  WifiManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

class WifiData: Event {
    let eventType = "WIFI"
    var value: Wifi = Wifi(name: "")
    var time = DateManager.shared.currentDate
}

struct Wifi: Codable {
    var name: String
}

final class WifiManager: BasicManagerType {
    var gettingPoolingTime: Double
    var getDataTimer: Timer?
    var data: WifiData = WifiData()

    init(gettingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
    }

    @objc private func getData() {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        guard let wifiName = ssid else { return }
        data.value = Wifi(name: wifiName)
        data.time = DateManager.shared.currentDate

        AlgolyticsSDK.shared.dataToSend.eventList.append(data)
    }

    public func startGettingData() {
        getDataTimer = Timer.scheduledTimer(timeInterval: gettingPoolingTime, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        getDataTimer?.fire()
    }

    public func stopGettingData() {
        getDataTimer?.invalidate()
        getDataTimer = nil
    }
}
