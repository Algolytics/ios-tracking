//
//  LocationManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import CoreLocation

struct LocationData: Codable {
    let eventType = "Location"
    var value: [Location]
    let deviceInfo = DeviceManager()
    let date = DateManager.shared.currentDate
}

struct Location: Codable {
    var latitude: Double
    var longitude: Double
}

final class LocationManager: NSObject, BasicManagerType {
    var gettingPoolingTime: Double
    var sendingPoolingTime: Double
    var timer: Timer?
    var sendTimer: Timer?
    var data: LocationData = LocationData(value: [])
    let locationManager = CLLocationManager()

//    public override init() {
//
//    }

    init(gettingPoolingTime: Double, sendingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
        self.sendingPoolingTime = sendingPoolingTime / 1000

        self.locationManager.requestWhenInUseAuthorization()
    }
    

    @objc private func getData() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }

        guard let currentLocation = locationManager.location?.coordinate else { return }
        let location = Location(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        data.value.append(location)
        print("locations = \(location.latitude) \(location.longitude)")
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

        data = LocationData(value: [])
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

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        let location = Location(latitude: locValue.latitude, longitude: locValue.longitude)

    }
}