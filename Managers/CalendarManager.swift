//
//  CalendarManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import EventKit

struct Calendar: Codable {
    var title: String
    var dateStart: TimeInterval
    var dateEnd: TimeInterval
}

public final class CalendarManager: BasicManagerType {
    var timer: Timer?
    var data: [Calendar] = []
    let eventStore = EKEventStore()

    public init() {
        stopGettingData()
        eventStore.requestAccess(to: .event) { [weak self] (value, error) in
            self?.startGettingData()
        }
    }

    @objc private func getData() {
        let calendars = eventStore.calendars(for: .event)

        var calendarEvents: [Calendar] = []
        for calendar in calendars {
            let oneMonthAgo = Date(timeIntervalSinceNow: -30*24*3600)
            let oneMonthAfter = Date(timeIntervalSinceNow: +30*24*3600)

            let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: [calendar])

            let events = eventStore.events(matching: predicate)

            for event in events {
                let calendar = Calendar(title: event.title, dateStart: event.startDate.timeIntervalSince1970, dateEnd: event.endDate.timeIntervalSince1970)
                calendarEvents.append(calendar)
            }
        }

        print("all calendar events")
        print(calendarEvents)
//        let photo = Photo(count: result.count)

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

    public func startGettingData() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        timer?.fire()
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil
    }
}
