//
//  BatteryManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import UIKit

struct BatteryData: Codable {
    let eventType = "Battery"
    let batteryInfo: Battery
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
    var data: BatteryData = BatteryData(batteryInfo: Battery(batteryLevel: -1, isAcCharging: false))

    public init() {
//        startGettingData()
    }

    @objc private func getData() {
        let battery = Battery(batteryLevel: UIDevice.current.batteryLevel, isAcCharging: UIDevice.current.batteryState.rawValue == 2)
        data = BatteryData(batteryInfo: battery)

//        print(data.count)

        sendData()
    }

    private func sendData() {
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

        data = BatteryData(batteryInfo: Battery(batteryLevel: -1, isAcCharging: false))
    }

    public func startGettingData() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        timer?.fire()
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil
    }
}
