//
//  PermissionsManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 18/09/2020.
//

import Foundation
import EventKit
import Contacts
import Photos

struct Permission: Codable {
    let eventType: String = "NO_PERMISSIONS"
    let time = DateManager.shared.currentDate
    var value: [String] = []
}
class PermissionsManager {
    static let shared = PermissionsManager()

    private func getAllNoPermissions() -> [String] {
        var noPermissions: [String] = []

        if EKEventStore.authorizationStatus(for: .event) != .authorized {
            noPermissions.append("CALLENDAR_EVENTS")
        }

        if CNContactStore.authorizationStatus(for: .contacts) != .authorized {
            noPermissions.append("CONTACTS_NUMBER")
        }

        if CLLocationManager.authorizationStatus() != .authorizedAlways && CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            noPermissions.append("LOCATION")
        }

        if PHPhotoLibrary.authorizationStatus() != .authorized {
            noPermissions.append("NUMBER_OF_PHOTOS")
        }

        return noPermissions
    }

    func sendNoPermissions() {
        var permissions = Permission()
        permissions.value = getAllNoPermissions()
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(permissions)
            AlgolyticsSDKService.shared.post(data: jsonData)
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
