//
//  ContactManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import Contacts

struct Contact: Codable {
    var count: Int
}

@available(iOS 9.0, *)
public final class ContactManager: BasicManagerType {
    var timer: Timer?
    var data: [Contact] = []
    let contactStore = CNContactStore()

    public init() {
        stopGettingData()
        DispatchQueue.main.async {  [weak self] in
            self?.contactStore.requestAccess(for: .contacts) {(value, error) in
                self?.start()
            }
        }
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
//        }
        print("contact count")
        print(contactsCount)
//        let contact = Contact(count: contactsCount)

//        let encoder = JSONEncoder()
//
//        do {
//            let jsonData = try encoder.encode(bat)
//
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print(jsonString)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//        print(data.count)
    }

    private func start() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        timer?.fire()
    }
    public func startGettingData() {
//        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
//        timer?.fire()
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil
    }
}
