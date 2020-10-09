//
//  LocationManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import CoreLocation

class LocationData: Event, Codable {
    let eventType = "LOCATION"
    var value: Location = Location(latitude: 0, longitude: 0)
    var time = DateManager.shared.currentDate
}

struct Location: Codable {
    var latitude: Double
    var longitude: Double
}

final class LocationManager: NSObject, BasicManagerType {
    var gettingPoolingTime: Double
    var getDataTimer: Timer?
    var data: LocationData = LocationData()
    let locationManager = CLLocationManager()

    init(gettingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000

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
        data.value = location
        data.time = DateManager.shared.currentDate

        AlgolyticsSDK.shared.dataToSend.eventList.append(data)
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

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}
