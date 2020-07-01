//
//  ViewController.swift
//  AlgolyticsSDK
//
//  Created by Mateusz Mirkowski on 06/02/2020.
//  Copyright (c) 2020 Mateusz Mirkowski. All rights reserved.
//

import UIKit
import AlgolyticsSDK

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var datePicker: UIDatePicker!
//    let datePicker = UIDatePicker()
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.accessibilityTraits = UIAccessibilityTraitSearchField
        searchBar.accessibilityIdentifier = "koko"
        searchBar.isAccessibilityElement = false

        // Do any additional setup after loading the view, typ ically from a nib.
        AlgolyticsSDK.shared.startGettingClickEvents(for: view)
        AlgolyticsSDK.shared.startGettingInputEvents(for: view)
//        datePicker.addTarget(AlgolyticsSDK.shared, action: #selector(AlgolyticsSDK.shared.getDatePickerData(_:)), for: .valueChanged)

          //ToolBar
        AlgolyticsSDK.shared.sendScreenName(name: "test")

        textView.delegate = self

        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        view.addGestureRecognizer(tapGestureReconizer)
    }

    @objc func tap(sender: UITapGestureRecognizer) {
        AlgolyticsSDK.shared.sendCustomEvent(identifier: "finish", value: "finish")
        view.endEditing(true)
    }

    @objc func cancelDatePicker() {
       self.view.endEditing(true)
     }
}

extension ViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        AlgolyticsSDK.shared.sendTextViewBeginEditingEvent(textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        AlgolyticsSDK.shared.sendTextViewEndEditingEvent(textView)
    }

    func textViewDidChange(_ textView: UITextView) {
        AlgolyticsSDK.shared.sendTextViewEvent(textView)
    }
}


