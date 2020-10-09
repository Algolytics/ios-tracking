//
//  ClickEventsManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import Foundation

class ClickEvent: Event, Codable {
    var eventType: String = "CLICK_EVENT"
    var value: Click
    var time = DateManager.shared.currentDate

    init(click: Click, eventType: String, time: String = DateManager.shared.currentDate) {
        self.value = click
        self.eventType = eventType
        self.time = time
    }
}

struct Click: Codable {
    let name: String
    let value: String
}

class ClickEventsManager: BasicAspectType {
    func startGettingClickEvents(for view: UIView) {
        let buttons = view.get(all: UIButton.self)

        buttons.forEach { $0.addTarget(self, action: #selector(getButtonData(_:)), for: .touchUpInside)}

        let allDatePickers = view.get(all: UIDatePicker.self)
        allDatePickers.forEach { $0.addTarget(self, action: #selector(getDatePickerData(_:)), for: .valueChanged)}

        let allSliders = view.get(all: UISlider.self)
        allSliders.forEach { $0.addTarget(self, action: #selector(getSliderData(_:)), for: .touchDown)}

        let allSwitches = view.get(all: UISwitch.self)
        allSwitches.forEach { $0.addTarget(self, action: #selector(getSwitchData), for: .valueChanged)}

        let allSegmented = view.get(all: UISegmentedControl.self)
        allSegmented.forEach { $0.addTarget(self, action: #selector(getSegmentedData(_:)), for: .valueChanged)}

        let allStepers = view.get(all: UIStepper.self)
        allStepers.forEach { $0.addTarget(self, action: #selector(getSteperData(_:)), for: .valueChanged)}
    }

    @objc private func getButtonData(_ sender: UIButton) {
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: sender.titleLabel?.text ?? "no-text", eventType: "BUTTON_CLICK")
    }

    @objc private func getSliderData(_ sender: UISlider) {
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: String(sender.value), eventType: "SLIDER_CLICK")
    }

    @objc private func getDatePickerData(_ sender: UIDatePicker) {
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: DateManager.shared.dateFormatter.string(from: sender.date), eventType: "DATEPICKER_CLICK")
    }

    @objc private func getSwitchData(_ sender: UISwitch) {
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: sender.isOn ? "true" : "false", eventType: "SWITCH_CLICK")
    }

    @objc private func getSegmentedData(_ sender: UISegmentedControl) {
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex)
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: title ?? "no-value", eventType: "SEGMENTED_CLICK")
    }

    @objc private func getSteperData(_ sender: UIStepper) {
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: String(sender.value), eventType: "STEPPER_CLICK")
    }

    func sendCustomIdentifier(identifier: String?, value: String, eventType: String = "CLICK_EVENT") {
        sendData(name: identifier ?? "no-identifier", value: value, eventType: eventType)
    }

    func sendData(name: String, value: String, eventType: String = "CLICK_EVENT") {
        let event = ClickEvent(click: Click(name: name, value: value), eventType: eventType)

        AlgolyticsSDK.shared.dataToSend.eventList.append(event)

    }
}
