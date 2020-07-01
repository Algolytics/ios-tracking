//
//  ScreenEventsManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 08/06/2020.
//

import Foundation

struct ScreenEventData: Codable {
    let eventType: String = "ACTIVITY_CHANGED"
    let value: String
    let deviceInfo = DeviceManager()
    let date = DateManager.shared.currentDate
}

class ScreenEventsManager: BasicAspectType {
    func saveScreenName(name: String) {
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(ScreenEventData(value: name))

            AlgolyticsSDKService.shared.post(data: jsonData)
        } catch {
            print(error.localizedDescription)
        }
     }
}
