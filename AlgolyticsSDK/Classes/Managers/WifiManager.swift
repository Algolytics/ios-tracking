//
//  WifiManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

struct WifiData: Codable {
    let eventType = "Wifi"
    var value: [Wifi]
    let deviceInfo = DeviceManager()
    let date = DateManager.shared.currentDate
}

struct Wifi: Codable {
    var name: String
}

final class WifiManager: BasicManagerType {
    var gettingPoolingTime: Double
    var sendingPoolingTime: Double
    var timer: Timer?
    var sendTimer: Timer?
    var data: WifiData = WifiData(value: [])

    init(gettingPoolingTime: Double, sendingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
        self.sendingPoolingTime = sendingPoolingTime / 1000
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
        print("wifiname")
        print(wifiName)
        data.value.append(Wifi(name: wifiName))
    }

    @objc private func sendData() {
        let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(data)

                let str = String(decoding: jsonData, as: UTF8.self)
                print(str)

                AlgolyticsSDKService.shared.post(data: jsonData)
            } catch {
                print(error.localizedDescription)
            }

        data = WifiData(value: [])
    }

    public func startGettingData() {
        timer = Timer.scheduledTimer(timeInterval: gettingPoolingTime, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        timer?.fire()

        sendTimer = Timer.scheduledTimer(timeInterval: sendingPoolingTime, target: self, selector: #selector(sendData), userInfo: nil, repeats: true)
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil
    }
}
