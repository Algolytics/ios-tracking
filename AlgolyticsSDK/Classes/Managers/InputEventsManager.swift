//
//  InputEventsManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 05/06/2020.
//

import Foundation

class InputEventsManager: BasicAspectType {
    private var timer: Timer?

    func startGettingInputEvents(for view: UIView) {
        let allTextFields = view.get(all: UITextField.self)
        allTextFields.forEach { $0.addTarget(self, action: #selector(validate2), for: .editingDidBegin)}
        allTextFields.forEach { $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)}
        allTextFields.forEach { $0.addTarget(self, action: #selector(validate2), for: .editingDidEnd)}
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

    @objc private func validate2() {
//        let string = timer?.userInfo as! String
        print("validate 2")
//        print(string)
    }

    func textViewBeginEditing(_ sender: UITextView) {
        print("textViewBeginEditing")
        print(sender.text ?? "")
    }

    func textViewEndEditing(_ sender: UITextView) {
        print("textViewEndEditing")
        print(sender.text ?? "")
    }

    func textViewDidChange(_ sender: UITextView) {
        timer?.invalidate()

        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(validate1), userInfo: sender.text, repeats: false);
    }
}
