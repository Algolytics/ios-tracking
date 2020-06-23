//
//  BatteryManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import UIKit

struct BatteryData: Codable {
    let eventType = "Battery"
    var batteryInfo: [Battery]
    let deviceInfo = DeviceManager()
}

struct Battery: Codable {
    var batteryLevel: Float
    var isAcCharging: Bool

    enum CodingKeys: String, CodingKey {
        case batteryLevel, isAcCharging
    }

//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(batteryLevel, forKey: .batteryLevel)
//        try container.encode(isAcCharging, forKey: .isAcCharging)
//    }
}

//extension Battery: Encodable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(type.rawValue, forKey: .type)
//        try container.encode(isFavorited, forKey: .isFavorited)
//    }
//}

public final class BatteryManager: BasicManagerType {
    var timer: Timer?
    var sendDataTimer: Timer?
    var data: BatteryData = BatteryData(batteryInfo: [])

    public init() {
//        startGettingData()
    }

    @objc private func getData() {
        let battery = Battery(batteryLevel: UIDevice.current.batteryLevel * 100, isAcCharging: UIDevice.current.batteryState.rawValue == 2)
        
        data.batteryInfo.append(battery)
    }

    @objc private func sendData() {
        let encoder = JSONEncoder()

//        data.forEach {
            do {
                let jsonData = try encoder.encode(data)

                let str = String(decoding: jsonData, as: UTF8.self)
                print(str)

                AlgolyticsSDKService.shared.post(data: jsonData)

            } catch {
                print(error.localizedDescription)
            }
//        }

        data = BatteryData(batteryInfo: [])
    }

    public func startGettingData() {
        UIDevice.current.isBatteryMonitoringEnabled = true

        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        timer?.fire()

        sendDataTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(sendData), userInfo: nil, repeats: true)
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil

        sendDataTimer?.invalidate()
        sendDataTimer = nil
    }
}
