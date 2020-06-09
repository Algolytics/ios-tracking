//
//  ClickEventsManager.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import Foundation

final class ClickEventsManager: BasicAspectType {
    func startGettingClickEvents(for view: UIView) {
        let buttons = view.get(all: UIButton.self)
        buttons.forEach { $0.addTarget(self, action: #selector(getIdentifier(_:)), for: .touchUpOutside)}
        buttons.forEach { $0.addTarget(self, action: #selector(getIdentifier2(_:)), for: .touchUpInside)}

        let datePickers = view.get(all: UIDatePicker.self)
        datePickers.forEach { $0.addTarget(self, action: #selector(getDatePickerData(_:)), for: .valueChanged)}

//        let inputViews = view.get(all: UIView.self)
//        inputViews.forEach { ($0 as? UIDatePicker)?.addTarget(self, action: #selector(getDatePickerData(_:)), for: .valueChanged)}

        let allSliders = view.get(all: UISlider.self)
        allSliders.forEach { $0.addTarget(self, action: #selector(getSliderData(_:)), for: .touchDown)}
    }

    @objc private func getIdentifier(_ sender: UIButton) {
        print("jest touch down")
        print(sender.accessibilityIdentifier)
    }

    @objc private func getIdentifier2(_ sender: UIButton) {
        print("jest touch up inside")
        print(sender.accessibilityIdentifier)
        print(sender.titleLabel?.text)
    }

    @objc private func getSliderData(_ sender: UISlider) {
        print(sender.value)
    }

    @objc private func getDatePickerData(_ sender: UIDatePicker) {
        print(sender.date)
    }

    func saveCustomIdentifier(identifier: String, value: String) {
        print("id \(identifier), value \(value)")
    }
}
