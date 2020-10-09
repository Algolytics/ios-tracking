//
//  CalendarManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import EventKit

class CalendarData: Event, Codable {
    let eventType = "CALLENDAR_EVENTS"
    var value: [Calendar] = []
    var time = DateManager.shared.currentDate
}

struct Calendar: Codable {
    var title: String
    var dtstart: Int
    var dtend: Int
}

final class CalendarManager: BasicManagerType {
    var gettingPoolingTime: Double
    var getDataTimer: Timer?
    var data: CalendarData = CalendarData()
    var eventStore = EKEventStore()

    init(gettingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
    }

    @objc private func getData() {
        eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)

        var calendarEvents: [Calendar] = []
        for calendar in calendars {
            let startDate = Date(timeIntervalSinceNow: -30*24*3600*24)
            let endDate = Date(timeIntervalSinceNow: +30*24*3600*12)

            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])

            let events = eventStore.events(matching: predicate)

            for event in events {
                let calendar = Calendar(title: event.title, dtstart: Int(event.startDate.timeIntervalSince1970), dtend: Int(event.endDate.timeIntervalSince1970))
                calendarEvents.append(calendar)
            }
        }

        data.value = calendarEvents
        data.time = DateManager.shared.currentDate

        AlgolyticsSDK.shared.dataToSend.eventList.append(data)
    }

    public func startGettingData() {
        eventStore.requestAccess(to: .event) { [weak self] (value, error) in
            if value {
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
