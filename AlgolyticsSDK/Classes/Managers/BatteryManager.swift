//
//  BatteryManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import UIKit

public protocol BatteryManagerType {
    var data: [Battery] { get }
}

public struct Battery: Codable {
    var batteryLevel: Float
    var isAcCharging: Bool
}

public final class BatteryManager: BasicManagerType {
    var timer: Timer?
    var data: [Battery] = []

    public init() {
//        startGettingData()
    }

    @objc private func getData() {
        let bat = Battery(batteryLevel: UIDevice.current.batteryLevel, isAcCharging: UIDevice.current.batteryState.rawValue == 2)
        data.append(bat)
//        let encoder = JSONEncoder()
//
//        do {
//            let jsonData = try encoder.encode(bat)
//
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print(jsonString)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
        print(data.count)
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
