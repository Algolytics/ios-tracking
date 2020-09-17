//
//  AccelerometerManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import CoreMotion

class AccelerometerData: Event {
    let eventType = "Accelerometer"
//    let deviceInfo = DeviceManager()
    var value: [Accelerometer] = []
    var time = DateManager.shared.currentDate
}

struct Accelerometer: Codable {
    let time = DateManager.shared.currentDate
    var x: Double
    var y: Double
    var z: Double
}

final class AccelerometerManager: BasicManagerType {
    var gettingPoolingTime: Double
    var sendingPoolingTime: Double
    var getDataTimer: Timer?
    var sendDataTimer: Timer?
    var data: AccelerometerData = AccelerometerData()
    let motionManager = CMMotionManager()

    public init(gettingPoolingTime: Double, sendingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
        self.sendingPoolingTime = sendingPoolingTime / 1000
        motionManager.startAccelerometerUpdates()
    }

    @objc private func getData() {
        guard let x = motionManager.accelerometerData?.acceleration.x, let y = motionManager.accelerometerData?.acceleration.y, let z = motionManager.accelerometerData?.acceleration.z else { return }
        
        let accelerometer = Accelerometer(x: x, y: y, z: z)
        data.value.append(accelerometer)
        data.time = DateManager.shared.currentDate

        AlgolyticsSDK.shared.dataToSend.eventList.append(data)

        data = AccelerometerData()
    }

    @objc private func sendData() {
//        let encoder = JSONEncoder()
//
//         do {
//             let jsonData = try encoder.encode(data)
//
//             AlgolyticsSDKService.shared.post(data: jsonData)
//         } catch {
//             print(error.localizedDescription)
//         }

//         data = AccelerometerData()
    }

    public func startGettingData() {
        getDataTimer = Timer.scheduledTimer(timeInterval: gettingPoolingTime, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        getDataTimer?.fire()

        sendDataTimer = Timer.scheduledTimer(timeInterval: sendingPoolingTime, target: self, selector: #selector(sendData), userInfo: nil, repeats: true)
    }

    public func stopGettingData() {
        getDataTimer?.invalidate()
        getDataTimer = nil

        sendDataTimer?.invalidate()
        sendDataTimer = nil
    }
}
