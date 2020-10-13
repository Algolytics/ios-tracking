//
//  ScreenEventsManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 08/06/2020.
//

import Foundation

class ScreenEventData: Event, Codable  {
    let eventType: String = "SCREEN_CHANGED"
    let currentScreen: String
    let newScreen: String
    let date = DateManager.shared.currentDate

    init(currentScreen: String, newScreen: String, eventType: String = "SCREEN_CHANGED", date: String = DateManager.shared.currentDate) {
        self.currentScreen = currentScreen
        self.newScreen = newScreen
    }
}

class ScreenEventsManager: BasicAspectType {
    func saveScreenName(currentScreen: String, newScreen: String) {
        let event = ScreenEventData(currentScreen: currentScreen, newScreen: newScreen)

        AlgolyticsSDK.shared.dataToSend.eventList.append(event)
    }
}
