//
//  ContactManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Contacts

class Contact: Event {
    let eventType = "CONTACTS_NUMBER"
    var value: Int = 0
//    let deviceInfo = DeviceManager()
    var time = DateManager.shared.currentDate
}

final class ContactManager: BasicManagerType {
    var gettingPoolingTime: Double
    var sendingPoolingTime: Double
    var getDataTimer: Timer?
    var sendDataTimer: Timer?
    var data: Contact = Contact()
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

        data.value = contactsCount
        data.time = DateManager.shared.currentDate

        AlgolyticsSDK.shared.dataToSend.eventList.append(data)
    }

    @objc private func sendData() {
//        let encoder = JSONEncoder()
//
//        do {
//            let jsonData = try encoder.encode(data)
//
//            AlgolyticsSDKService.shared.post(data: jsonData)
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        data = Contact(value: [])
    }

    public func startGettingData() {
        DispatchQueue.main.async {  [weak self] in
            self?.contactStore.requestAccess(for: .contacts) {(value, error) in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.getDataTimer = Timer.scheduledTimer(timeInterval: strongSelf.gettingPoolingTime, target: strongSelf, selector: #selector(strongSelf.getData), userInfo: nil, repeats: true)
                    strongSelf.getDataTimer?.fire()

                    strongSelf.sendDataTimer = Timer.scheduledTimer(timeInterval: strongSelf.sendingPoolingTime, target: strongSelf, selector: #selector(strongSelf.sendData), userInfo: nil, repeats: true)
                }
            }
        }
    }

    public func stopGettingData() {
        getDataTimer?.invalidate()
        getDataTimer = nil

        sendDataTimer?.invalidate()
        sendDataTimer = nil
    }
}
