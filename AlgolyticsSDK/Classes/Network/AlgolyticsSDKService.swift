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

    lazy var currentDate: String = {
        let now = Date()
        let dateString = dateFormatter.string(from:now)
        return dateString
    }()
}

class Event: Codable {

}

struct EventData: Codable {
    let phoneInformation = DeviceManager()
    var eventList: [Event]
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
