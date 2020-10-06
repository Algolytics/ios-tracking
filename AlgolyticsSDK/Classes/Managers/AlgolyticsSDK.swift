//
//  AlgolyticsSDK.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import UIKit

public final class AlgolyticsSDK {
    public enum AlgolyticsComponentType {
        case accelerometer(poolingTime: Double = 30000.0, minDifference: Double = 0.0)
        case battery(poolingTime: Double = 30000.0)
        case calendar(poolingTime: Double = 30000.0)
        case connectivity(poolingTime: Double = 30000.0)
        case contact(poolingTime: Double = 30000.0)
        case location(poolingTime: Double = 30000.0)
        case photo(poolingTime: Double = 30000.0)
        case wifi(poolingTime: Double = 30000.0)
    }

    public static let shared = AlgolyticsSDK()
    private var components: [BasicManagerType] = []
    private var clickEventsManager: ClickEventsManager = ClickEventsManager()
    private var inputEventsManager: InputEventsManager = InputEventsManager()
    private var screenEventsManager: ScreenEventsManager = ScreenEventsManager()
    var dataToSend: EventData = EventData(eventList: [])
    var sendAllEventsTimer: Timer?

    public func initWith(url: String, apiKey: String, apiPoolingTime: Double = 30000.0, components: [AlgolyticsComponentType]) {
        AlgolyticsSDKService.shared.baseURL = url
        AlgolyticsSDKService.shared.apiKey = apiKey

        components.forEach {
            switch $0 {
            case .accelerometer(let poolingTime, let minDifference):
                let accelerometerManager = AccelerometerManager(gettingPoolingTime: poolingTime)
                accelerometerManager.minDifference = minDifference
                self.components.append(accelerometerManager)
            case .battery(let poolingTime):
                self.components.append(BatteryManager(gettingPoolingTime: poolingTime))
            case .calendar(let poolingTime):
                self.components.append(CalendarManager(gettingPoolingTime: poolingTime))
            case .connectivity(let poolingTime):
                self.components.append(ConnectivityManager(gettingPoolingTime: poolingTime))
            case .contact(let poolingTime):
                self.components.append(ContactManager(gettingPoolingTime: poolingTime))
            case .location(let poolingTime):
                self.components.append(LocationManager(gettingPoolingTime: poolingTime))
            case .photo(let poolingTime):
                self.components.append(PhotoManager(gettingPoolingTime: poolingTime))
            case .wifi(let poolingTime):
                self.components.append(WifiManager(gettingPoolingTime: poolingTime))
            }
        }

        sendAllEventsTimer = Timer.scheduledTimer(timeInterval: apiPoolingTime/1000, target: self, selector: #selector(sendAllEvents), userInfo: nil, repeats: true)

        self.components.forEach { $0.startGettingData() }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            PermissionsManager.shared.sendNoPermissions()
        }
    }

    public func sendScreenName(currentScreen: String, newScreen: String) {
        screenEventsManager.saveScreenName(currentScreen: currentScreen, newScreen: newScreen)
    }

    public func startGettingClickEvents(for view: UIView) {
        clickEventsManager.startGettingClickEvents(for: view)
    }

    public func sendCustomEvent(identifier: String?, value: String) {
        clickEventsManager.sendCustomIdentifier(identifier: identifier, value: value)
    }

    public func startGettingInputEvents(for view: UIView) {
        inputEventsManager.startGettingInputEvents(for: view)
    }

    public func sendTextViewBeginEditingEvent(_ sender: UITextView) {
        inputEventsManager.textViewBeginEditing(sender)
    }

    public func sendTextViewEndEditingEvent(_ sender: UITextView) {
        inputEventsManager.textViewEndEditing(sender)
    }

    public func sendTextViewEvent(_ sender: UITextView) {
        inputEventsManager.textViewDidChange(sender)
    }

    @objc private func sendAllEvents() {
        if dataToSend.eventList.count > 0 {
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(dataToSend)
                AlgolyticsSDKService.shared.post(data: jsonData)
                dataToSend = EventData(eventList: [])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
