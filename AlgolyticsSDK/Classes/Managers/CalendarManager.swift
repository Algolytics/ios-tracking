//
//  CalendarManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 12/06/2020.
//

import Foundation
import EventKit

struct CalendarData: Codable {
    let eventType = "Calendar"
    var calendarInfo: [[Calendar]]
    let deviceInfo = DeviceManager()
    let date = DateManager.shared.currentDate
}

struct Calendar: Codable {
    var title: String
    var dateStart: TimeInterval
    var dateEnd: TimeInterval
}

final class CalendarManager: BasicManagerType {
    var gettingPoolingTime: Double
    var sendingPoolingTime: Double
    var getDataTimer: Timer?
    var sendDataTimer: Timer?
    var data: CalendarData = CalendarData(calendarInfo: [])
    var eventStore = EKEventStore()

    init(gettingPoolingTime: Double, sendingPoolingTime: Double) {
        self.gettingPoolingTime = gettingPoolingTime / 1000
        self.sendingPoolingTime = sendingPoolingTime / 1000
    }

    @objc private func getData() {
        eventStore = EKEventStore()
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

        data.calendarInfo.append(calendarEvents)
    }

    @objc private func sendData() {
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(["EventList" : data])

            AlgolyticsSDKService.shared.post(data: jsonData)
        } catch {
            print(error.localizedDescription)
        }

        data = CalendarData(calendarInfo: [])
    }

    public func startGettingData() {
        eventStore.requestAccess(to: .event) { [weak self] (value, error) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.getDataTimer = Timer.scheduledTimer(timeInterval: strongSelf.gettingPoolingTime, target: strongSelf, selector: #selector(strongSelf.getData), userInfo: nil, repeats: true)
                strongSelf.getDataTimer?.fire()

                strongSelf.sendDataTimer = Timer.scheduledTimer(timeInterval: strongSelf.sendingPoolingTime, target: strongSelf, selector: #selector(strongSelf.sendData), userInfo: nil, repeats: true)
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
