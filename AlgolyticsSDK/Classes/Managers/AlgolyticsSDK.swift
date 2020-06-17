//
//  AlgolyticsSDK.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 04/06/2020.
//

import UIKit

public final class AlgolyticsSDK {
    public static let shared = AlgolyticsSDK()
    private var components: [BasicManagerType] = []
    private var clickEventsManager: ClickEventsManager = ClickEventsManager()
    private var inputEventsManager: InputEventsManager = InputEventsManager()
    private var screenEventsManager: ScreenEventsManager = ScreenEventsManager()

    public func initWith(url: String, components: [BasicManagerType]) {
        AlgolyticsSDKService.shared.baseURL = url
        self.components = components
        self.components.forEach { $0.startGettingData() }
    }

    public func sendScreenName(name: String) {
        screenEventsManager.saveScreenName(name: name)
    }

    public func startGettingClickEvents(for view: UIView) {
        clickEventsManager.startGettingClickEvents(for: view)
    }

    public func sendCustomClickEvent(identifier: String, value: String) {
        clickEventsManager.saveCustomIdentifier(identifier: identifier, value: value)
    }

    public func startGettingInputEvents(for view: UIView) {
        inputEventsManager.startGettingInputEvents(for: view)
    }

    public func sendTextViewBeginEditingEvent(_ sender: UITextView) {
        inputEventsManager.textViewBeginEditing(sender)
    }

    public func sendTextViewEndEditingEvent(_ sender: UITextView) {
        inputEventsManager.textViewEndEditing(sender)
    }

    public func sendTextViewEvent(_ sender: UITextView) {
        inputEventsManager.textViewDidChange(sender)
    }

//    public func stopGettingData() {
//        components.forEach { $0.stopGettingData() }
//    }
}
