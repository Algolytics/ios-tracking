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
}

struct Calendar: Codable {
    var title: String
    var dateStart: TimeInterval
    var dateEnd: TimeInterval

//    enum CodingKeys: String, CodingKey {
//        case title, dateStart, dateEnd
//    }
}

public final class CalendarManager: BasicManagerType {
    var timer: Timer?
    var sendDataTimer: Timer?
    var data: CalendarData = CalendarData(calendarInfo: [])
    var eventStore = EKEventStore()

    public init() {
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

        print("all calendar events")
        print(calendarEvents)

        data.calendarInfo.append(calendarEvents)
    }

    @objc private func sendData() {
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(["EventList" : data])

            let str = String(decoding: jsonData, as: UTF8.self)
            print(str)

            AlgolyticsSDKService.shared.post(data: jsonData)
        } catch {
            print(error.localizedDescription)
        }

        data = CalendarData(calendarInfo: [])
    }

    public func startGettingData() {
//        stopGettingData()
        eventStore.requestAccess(to: .event) { [weak self] (value, error) in
//            self?.startGettingData()
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.timer = Timer.scheduledTimer(timeInterval: 1, target: strongSelf, selector: #selector(strongSelf.getData), userInfo: nil, repeats: true)
                strongSelf.timer?.fire()

                strongSelf.sendDataTimer = Timer.scheduledTimer(timeInterval: 5, target: strongSelf, selector: #selector(strongSelf.sendData), userInfo: nil, repeats: true)
            }
        }
    }

    public func stopGettingData() {
        timer?.invalidate()
        timer = nil

        sendDataTimer?.invalidate()
        sendDataTimer = nil
    }
}
