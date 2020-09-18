//
//  ScreenEventsManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 08/06/2020.
//

import Foundation

struct ScreenEventData: Codable {
    let eventType: String = "SCREEN_CHANGED"
    let currentScreen: String
    let newScreen: String
    let date = DateManager.shared.currentDate
}

class ScreenEventsManager: BasicAspectType {
    func saveScreenName(currentScreen: String, newScreen: String) {
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(ScreenEventData(currentScreen: currentScreen, newScreen: newScreen))

            AlgolyticsSDKService.shared.post(data: jsonData)
        } catch {
            print(error.localizedDescription)
        }
     }
}
