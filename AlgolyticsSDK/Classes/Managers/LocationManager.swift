//
//  LocationManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import CoreLocation

struct Location: Codable {
    var latitude: Double
    var longitude: Double
}

public final class LocationManager: NSObject, BasicManagerType {
    var timer: Timer?
    var data: [Location] = []
    let locationManager = CLLocationManager()

    public override init() {
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
        data.append(location)
        print("locations = \(location.latitude) \(location.longitude)")

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
//        print(data.count)
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

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        let location = Location(latitude: locValue.latitude, longitude: locValue.longitude)

    }
}
