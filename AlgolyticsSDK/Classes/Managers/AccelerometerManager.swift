//
//  AccelerometerManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import CoreMotion

struct AccelerometerData: Codable {
    let eventType = "Accelerometer"
    let deviceInfo = DeviceManager()
    var value: [Accelerometer]
}

struct Accelerometer: Codable {
    var x: Double
    var y: Double
    var z: Double
}

final class AccelerometerManager: BasicManagerType {
    var gettingPoolingTime: Double
    var sendingPoolingTime: Double
    var timer: Timer?
    var sendDataTimer: Timer?
    var data: AccelerometerData = AccelerometerData(value: [])
    let motionManager = CMMotionManager()

    public init(gettingPoolingTime: Double, sendingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
        self.sendingPoolingTime = sendingPoolingTime / 1000
        motionManager.startAccelerometerUpdates()
    }

    @objc private func getData() {
        guard let x = motionManager.accelerometerData?.acceleration.x, let y = motionManager.accelerometerData?.acceleration.y, let z = motionManager.accelerometerData?.acceleration.z else { return }
//        print("x: \(x)")
//        print("y: \(y)")
//        print("z: \(z)")
        let accelerometer = Accelerometer(x: x, y: y, z: z)
        data.value.append(accelerometer)
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

         data = AccelerometerData(value: [])
    }

    public func startGettingData() {
        timer = Timer.scheduledTimer(timeInterval: gettingPoolingTime, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        timer?.fire()

        sendDataTimer = Timer.scheduledTimer(timeInterval: sendingPoolingTime, target: self, selector: #selector(sendData), userInfo: nil, repeats: true)
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil

        sendDataTimer?.invalidate()
        sendDataTimer = nil
    }
}
