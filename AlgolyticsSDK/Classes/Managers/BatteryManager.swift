//
//  BatteryManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import UIKit

class BatteryData: Event {
    let eventType = "BATTERY"
    var value: Battery = Battery(batteryLevel: -1, isAcCharging: false)
    var time = DateManager.shared.currentDate
}

struct Battery: Codable {
    var batteryLevel: Float
    var isAcCharging: Bool

    enum CodingKeys: String, CodingKey {
        case batteryLevel, isAcCharging
    }
}

final class BatteryManager: BasicManagerType {
    var gettingPoolingTime: Double
    var getDataTimer: Timer?
    var data: BatteryData = BatteryData()

    init(gettingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
    }

    @objc private func getData() {
        let battery = Battery(batteryLevel: UIDevice.current.batteryLevel * 100, isAcCharging: UIDevice.current.batteryState.rawValue == 2)
        
        data.value = battery
        data.time = DateManager.shared.currentDate

        AlgolyticsSDK.shared.dataToSend.eventList.append(data)

        data = BatteryData()
    }

    public func startGettingData() {
        UIDevice.current.isBatteryMonitoringEnabled = true

        getDataTimer = Timer.scheduledTimer(timeInterval: gettingPoolingTime, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        getDataTimer?.fire()
    }

    public func stopGettingData() {
        getDataTimer?.invalidate()
        getDataTimer = nil
    }
}
