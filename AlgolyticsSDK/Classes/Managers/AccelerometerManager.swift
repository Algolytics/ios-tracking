//
//  AccelerometerManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import CoreMotion

struct Accelerometer: Codable {
    var x: Double
    var y: Double
    var z: Double
}

public final class AccelerometerManager: BasicManagerType {
    var timer: Timer?
    var data: [Accelerometer] = []
    let motionManager = CMMotionManager()

    public init() {
        motionManager.startAccelerometerUpdates()
    }

    @objc private func getData() {
        guard let x = motionManager.accelerometerData?.acceleration.x, let y = motionManager.accelerometerData?.acceleration.y, let z = motionManager.accelerometerData?.acceleration.z else { return }
//        print("x: \(x)")
//        print("y: \(y)")
//        print("z: \(z)")
        let accelerometer = Accelerometer(x: x, y: y, z: z)
        data.append(accelerometer)
    }


    public func startGettingData() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        timer?.fire()
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil
    }
}
