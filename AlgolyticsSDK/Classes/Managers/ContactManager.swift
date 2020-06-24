//
//  ContactManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Contacts

struct Contact: Codable {
    let eventType = "CONTACT_NUMBER"
//    let time = Date()
    var value: [Int]
    let deviceInfo = DeviceManager()
}

final class ContactManager: BasicManagerType {
    var gettingPoolingTime: Double
    var sendingPoolingTime: Double
    var timer: Timer?
    var sendDataTimer: Timer?
    var data: Contact = Contact(value: [])
    let contactStore = CNContactStore()

    init(gettingPoolingTime: Double, sendingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
        self.sendingPoolingTime = sendingPoolingTime / 1000
    }

    @objc private func getData() {
        var contactsCount: Int = 0
        let contactFetchRequest = CNContactFetchRequest(keysToFetch: [])
        do {
            try contactStore.enumerateContacts(with: contactFetchRequest) { (contact, error) in
            contactsCount += 1
            }
        } catch {
            print("Error counting all contacts.\nError: \(error)")
        }

        print("contact count")
        print(contactsCount)

        data.value.append(contactsCount)

//        sendData()
    }

    @objc private func sendData() {
        let encoder = JSONEncoder()

//        data.forEach {
            do {
                let jsonData = try encoder.encode(data)

                let str = String(decoding: jsonData, as: UTF8.self)
                print(str)

                AlgolyticsSDKService.shared.post(data: jsonData)
            } catch {
                print(error.localizedDescription)
            }
//        }


        data = Contact(value: [])
    }

    public func startGettingData() {
        DispatchQueue.main.async {  [weak self] in
            self?.contactStore.requestAccess(for: .contacts) {(value, error) in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.timer = Timer.scheduledTimer(timeInterval: strongSelf.gettingPoolingTime, target: strongSelf, selector: #selector(strongSelf.getData), userInfo: nil, repeats: true)
                    strongSelf.timer?.fire()

                    strongSelf.sendDataTimer = Timer.scheduledTimer(timeInterval: strongSelf.sendingPoolingTime, target: strongSelf, selector: #selector(strongSelf.sendData), userInfo: nil, repeats: true)
                }
            }
        }

//        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
//        timer?.fire()
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil

        sendDataTimer?.invalidate()
        sendDataTimer = nil
    }
}
