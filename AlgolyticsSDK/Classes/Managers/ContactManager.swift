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
    var time = DateManager.shared.currentDate
}

final class ContactManager: BasicManagerType {
    var gettingPoolingTime: Double
    var getDataTimer: Timer?
    var data: Contact = Contact()
    let contactStore = CNContactStore()

    init(gettingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
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

    public func startGettingData() {
        DispatchQueue.main.async {  [weak self] in
            self?.contactStore.requestAccess(for: .contacts) {(value, error) in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.getDataTimer = Timer.scheduledTimer(timeInterval: strongSelf.gettingPoolingTime, target: strongSelf, selector: #selector(strongSelf.getData), userInfo: nil, repeats: true)
                    strongSelf.getDataTimer?.fire()
                }
            }
        }
    }

    public func stopGettingData() {
        getDataTimer?.invalidate()
        getDataTimer = nil
    }
}
