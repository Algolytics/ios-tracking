//
//  InputEventsManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 05/06/2020.
//

import Foundation

class InputEventsManager: BasicAspectType {
    private var timer: Timer?
    private var dwellStartTimestamp: TimeInterval!
    private var flightStartTimestamp: TimeInterval!

    func startGettingInputEvents(for view: UIView) {
        let allTextFields = view.get(all: UITextField.self)
        allTextFields.forEach { $0.addTarget(self, action: #selector(editingStart), for: .editingDidBegin)}
        allTextFields.forEach { $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)}
        allTextFields.forEach { $0.addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)}
    }

    @objc private func textFieldDidChange(_ sender: UITextField) {
        timer?.invalidate()

        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(validate1), userInfo: sender.text!, repeats: false);
    }

    @objc private func validate1() {
        let string = timer?.userInfo as! String
        print("validate 1")
        print(string)
    }

    @objc private func editingStart() {
        dwellStartTimestamp = NSDate().timeIntervalSince1970
//        let string = timer?.userInfo as! String
        print("editing start")
//        print(string)
        if flightStartTimestamp != nil {
            print("flighttime")
            let flightTimestamp = dwellStartTimestamp - flightStartTimestamp
            print(flightTimestamp)
        }
    }

    @objc private func editingEnd() {
    //        let string = timer?.userInfo as! String
            print("editing end")
    //        print(string)
        let editingEndTimestamp = NSDate().timeIntervalSince1970
        let dwellTimestamp = editingEndTimestamp - dwellStartTimestamp
        print(dwellTimestamp)
        flightStartTimestamp = editingEndTimestamp
    }

    func textViewBeginEditing(_ sender: UITextView) {
        print("textViewBeginEditing")
        print(sender.text ?? "")
        dwellStartTimestamp = NSDate().timeIntervalSince1970
//        let string = timer?.userInfo as! String

//        print(string)
        if flightStartTimestamp != nil {
            print("flighttime")
            let flightTimestamp = dwellStartTimestamp - flightStartTimestamp
            print(flightTimestamp)
        }
    }

    func textViewEndEditing(_ sender: UITextView) {
        print("textViewEndEditing")
        print(sender.text ?? "")
        let editingEndTimestamp = NSDate().timeIntervalSince1970
        let dwellTimestamp = editingEndTimestamp - dwellStartTimestamp
        print(dwellTimestamp)
        flightStartTimestamp = editingEndTimestamp
    }

    func textViewDidChange(_ sender: UITextView) {
        timer?.invalidate()

        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(validate1), userInfo: sender.text, repeats: false);
    }
}
