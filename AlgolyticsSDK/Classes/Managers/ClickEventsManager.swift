//
//  ClickEventsManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import Foundation

struct ClickEvent: Codable {
    let name: String
    let value: String
    let deviceInfo = DeviceManager()
    let date = DateManager.shared.currentDate
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
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: sender.titleLabel?.text ?? "no-text")
    }

    @objc private func getSliderData(_ sender: UISlider) {
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: String(sender.value))
    }

    @objc private func getDatePickerData(_ sender: UIDatePicker) {
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: DateManager.shared.dateFormatter.string(from: sender.date))
    }

    @objc private func getSwitchData(_ sender: UISwitch) {
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: sender.isOn ? "true" : "false")
    }

    @objc private func getSegmentedData(_ sender: UISegmentedControl) {
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex)
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: title ?? "no-value")
    }

    @objc private func getSteperData(_ sender: UIStepper) {
        sendData(name: sender.accessibilityIdentifier ?? "no-identifier", value: String(sender.value))
    }

    func sendCustomIdentifier(identifier: String, value: String) {
        sendData(name: identifier, value: value)
    }

    func sendData(name: String, value: String) {
        let event = ClickEvent(name: name, value: value)
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(event)

            let str = String(decoding: jsonData, as: UTF8.self)
            print(str)

            AlgolyticsSDKService.shared.post(data: jsonData)
        } catch {
            print(error.localizedDescription)
        }
    }
}
