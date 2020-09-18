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
    var minDifference: Double = 0.0
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
        let minDifference = 0.1
        let accelerometer = Accelerometer(x: x, y: y, z: z)
//        print("before if x \(accelerometer.x)")
        guard let lastAccelerometer = data.value.last else {
            data.value.append(accelerometer)
            return
        }

        if abs(accelerometer.x - lastAccelerometer.x) >= minDifference ||
            abs(accelerometer.y - lastAccelerometer.y) >= minDifference ||
            abs(accelerometer.z - lastAccelerometer.z) >= minDifference {
            print("last x \(lastAccelerometer.x)")
            print("current x \(accelerometer.x)")
            data.value.append(accelerometer)
//            data.time = DateManager.shared.currentDate

            AlgolyticsSDK.shared.dataToSend.eventList.append(data)

//            data = AccelerometerData()
        }
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
