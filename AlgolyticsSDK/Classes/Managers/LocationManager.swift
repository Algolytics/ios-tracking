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
    var getDataTimer: Timer?
    var sendDataTimer: Timer?
    var data: LocationData = LocationData(value: [])
    let locationManager = CLLocationManager()

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
    }

    @objc private func sendData() {
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(data)

            AlgolyticsSDKService.shared.post(data: jsonData)
        } catch {
            print(error.localizedDescription)
        }

        data = LocationData(value: [])
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

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}
