//
//  AlgolyticsSDKService.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 17/06/2020.
//

import UIKit

struct Resolution: Codable {
    let x: Int
    let y: Int
}

struct DeviceManager: Codable {
    let deviceType = "SMARTPHONE"
    let deviceModel = UIDevice.current.name
    let deviceManufacturer = "Apple"
    let deviceResolution = Resolution(x: Int(UIScreen.main.bounds.width), y: Int(UIScreen.main.bounds.height))
    let deviceId = UIDevice.current.identifierForVendor?.description ?? ""
    let os = UIDevice.current.systemName
    let osVersion = UIDevice.current.systemVersion
    let osLanguage = Locale.current.identifier
}

class DateManager {
    static let shared = DateManager()
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS Z"
        return formatter
    }()

    var currentDate: String {
        let now = Date()
        let dateString = dateFormatter.string(from:now)
        return dateString
    }
}

protocol Event {}

struct EventData: Codable {
    let phoneInformation = DeviceManager()
    var eventList: [Event]

    init(eventList: [Event]) {
        self.eventList = eventList
    }

    private enum CodingKeys: String, CodingKey {
        case eventList, phoneInformation
    }

    func encode(to encoder: Encoder) throws {
        let wrappers = eventList.map { EventWrapper($0) }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(wrappers, forKey: .eventList)
        try container.encode(phoneInformation, forKey: .phoneInformation)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wrappers = try container.decode([EventWrapper].self, forKey: .eventList)
        self.eventList = wrappers.map { $0.event }
    }
}

private struct EventWrapper: Codable {
    let event: Event

    private enum CodingKeys: String, CodingKey {
        case base, payload
    }

    private enum Base: Int, Codable {
        case accelerometer
        case battery
        case calendar
        case click
        case connectivity
        case contact
        case input
        case location
        case photo
        case screen
        case wifi
    }

    init(_ event: Event) {
        self.event = event
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)

        switch base {
            case .accelerometer:
                self.event = try container.decode(AccelerometerData.self, forKey: .payload)
            case .battery:
                self.event = try container.decode(BatteryData.self, forKey: .payload)
            case .calendar:
                self.event = try container.decode(CalendarData.self, forKey: .payload)
            case .click:
                self.event = try container.decode(ClickEvent.self, forKey: .payload)
            case .connectivity:
                self.event = try container.decode(ConnectivityData.self, forKey: .payload)
            case .contact:
                self.event = try container.decode(Contact.self, forKey: .payload)
            case .input:
                self.event = try container.decode(InputEventData.self, forKey: .payload)
            case .location:
                self.event = try container.decode(LocationData.self, forKey: .payload)
            case .photo:
                self.event = try container.decode(PhotoData.self, forKey: .payload)
            case .screen:
                self.event = try container.decode(ScreenEventData.self, forKey: .payload)
            case .wifi:
                self.event = try container.decode(WifiData.self, forKey: .payload)

        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch event {
            case let payload as AccelerometerData:
                try container.encode(Base.accelerometer, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as BatteryData:
                try container.encode(Base.battery, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as CalendarData:
                try container.encode(Base.calendar, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as ClickEvent:
                try container.encode(Base.click, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as CalendarData:
                try container.encode(Base.calendar, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as ClickEvent:
                try container.encode(Base.click, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as ConnectivityData:
                try container.encode(Base.connectivity, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as Contact:
                try container.encode(Base.contact, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as InputEventData:
                try container.encode(Base.input, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as LocationData:
                try container.encode(Base.location, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as PhotoData:
                try container.encode(Base.photo, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as ScreenEventData:
                try container.encode(Base.screen, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as WifiData:
                try container.encode(Base.wifi, forKey: .base)
                try container.encode(payload, forKey: .payload)
            default:
                break
        }
    }
}

class AlgolyticsSDKService {
    static let shared = AlgolyticsSDKService()
    var baseURL: String = ""
    var apiKey: String = ""

    func post(data: Data) {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Api-Key")

        request.httpBody = data

        let session = URLSession.shared
        session.dataTask(with: request) { (_, _, _) in

        }.resume()
    }
}
