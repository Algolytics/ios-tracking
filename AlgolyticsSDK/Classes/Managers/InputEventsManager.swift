//
//  InputEventsManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 05/06/2020.
//

import Foundation

struct InputEventData: Codable {
    let eventType = "TEXT_INSERTED"
    var value: InputData
//    let deviceInfo = DeviceManager()
    let time = DateManager.shared.currentDate
}

struct InputData: Codable {
    let inputName: String
    let value: String
    let dwellTime: TimeInterval
    let flightTime: TimeInterval
}

class InputEventsManager: BasicAspectType {
    private var getDataTimer: Timer?
    private var dwellStartTimestamp: TimeInterval!
    private var flightStartTimestamp: TimeInterval!
    private var dwellTimestamp: TimeInterval!
    private var flightTimestamp: TimeInterval!

    func startGettingInputEvents(for view: UIView) {
        let allTextFields = view.get(all: UITextField.self)
        
        allTextFields.forEach { $0.addTarget(self, action: #selector(textFieldStartEditing(_:)), for: .editingDidBegin)}
        allTextFields.forEach { $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)}
        allTextFields.forEach { $0.addTarget(self, action: #selector(textFieldEndEditing), for: .editingDidEnd)}
    }

    @objc private func validateInputEvent() {
        let data = getDataTimer?.userInfo as! [String: Any]
        let name = data["name"] as? String
        let value = data["value"] as? String
        let editingEndTimestamp = NSDate().timeIntervalSince1970
        dwellTimestamp = editingEndTimestamp - dwellStartTimestamp

        sendInputEvent(name: name ?? "no-identifier", value: value ?? "no-value", dwellTime: dwellTimestamp ?? -1, flightTime: flightTimestamp ?? -1)
    }

    private func sendInputEvent(name: String, value: String, dwellTime: TimeInterval, flightTime: TimeInterval) {
        let data = InputEventData(value: InputData(inputName: name, value: value, dwellTime: dwellTime, flightTime: flightTime))
        let encoder = JSONEncoder()

        do {
            let jsonData = try encoder.encode(data)
            
            AlgolyticsSDKService.shared.post(data: jsonData)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension InputEventsManager {
    @objc private func textFieldDidChange(_ sender: UITextField) {
        getDataTimer?.invalidate()

        getDataTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(validateInputEvent), userInfo: ["name": sender.accessibilityIdentifier, "value": sender.text], repeats: false);
    }

    @objc private func textFieldStartEditing(_ sender: UITextField) {
        dwellStartTimestamp = NSDate().timeIntervalSince1970

        if flightStartTimestamp != nil {
            flightTimestamp = dwellStartTimestamp - flightStartTimestamp
        }
    }

    @objc private func textFieldEndEditing(_ sender: UITextField) {
        let name = sender.accessibilityLabel
        let value = sender.text

        let editingEndTimestamp = NSDate().timeIntervalSince1970
        dwellTimestamp = editingEndTimestamp - dwellStartTimestamp
        flightStartTimestamp = editingEndTimestamp

        sendInputEvent(name: name ?? "no-identifier", value: value ?? "no-value", dwellTime: dwellTimestamp ?? -1, flightTime: flightTimestamp ?? -1)
    }
}

extension InputEventsManager {
    func textViewDidChange(_ sender: UITextView) {
        getDataTimer?.invalidate()

        getDataTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(validateInputEvent), userInfo: ["name": sender.accessibilityIdentifier ?? "no-identifier", "value": sender.text ?? "no-value"], repeats: false);
    }
    
    func textViewBeginEditing(_ sender: UITextView) {
        dwellStartTimestamp = NSDate().timeIntervalSince1970

        if flightStartTimestamp != nil {
            flightTimestamp = dwellStartTimestamp - flightStartTimestamp
        }
    }

    func textViewEndEditing(_ sender: UITextView) {
        let name = sender.accessibilityLabel
        let value = sender.text

        let editingEndTimestamp = NSDate().timeIntervalSince1970
        dwellTimestamp = editingEndTimestamp - dwellStartTimestamp

        flightStartTimestamp = editingEndTimestamp

        sendInputEvent(name: name ?? "no-identifier", value: value ?? "no-value", dwellTime: dwellTimestamp ?? -1, flightTime: flightTimestamp ?? -1)
    }
}
