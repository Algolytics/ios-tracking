//
//  AccelerometerManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import CoreMotion

class AccelerometerData: Event, Codable {
    let eventType = "ACCELEROMETER"
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
    var minDifference: Double = 0.0
    var getDataTimer: Timer?
    var data: AccelerometerData = AccelerometerData()
    let motionManager = CMMotionManager()

    public init(gettingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000

        motionManager.startAccelerometerUpdates()
    }

    @objc private func getData() {
        guard let x = motionManager.accelerometerData?.acceleration.x, let y = motionManager.accelerometerData?.acceleration.y, let z = motionManager.accelerometerData?.acceleration.z else { return }
        let minDifference = 0.1
        let accelerometer = Accelerometer(x: x, y: y, z: z)
        
        guard let lastAccelerometer = data.value.last else {
            data.value.append(accelerometer)
            return
        }

        if abs(accelerometer.x - lastAccelerometer.x) >= minDifference ||
            abs(accelerometer.y - lastAccelerometer.y) >= minDifference ||
            abs(accelerometer.z - lastAccelerometer.z) >= minDifference {
            data.value.append(accelerometer)

            AlgolyticsSDK.shared.dataToSend.eventList.append(data)
        }
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
