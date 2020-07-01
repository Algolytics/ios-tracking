//
//  AlgolyticsSDKService.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 17/06/2020.
//

import Foundation

struct DeviceManager: Codable {
    let name = UIDevice.current.name
    let model = UIDevice.current.model
    let systemName = UIDevice.current.systemName
    let systemVersion = UIDevice.current.systemVersion
    let deviceId = UIDevice.current.identifierForVendor
    let osLanguage = Locale.current.identifier
}

class DateManager {
    static let shared = DateManager()
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()

    lazy var currentDate: String = {
        let now = Date()
        let dateString = dateFormatter.string(from:now)
        return dateString
    }()
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
