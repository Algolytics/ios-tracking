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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typ ically from a nib.
        AlgolyticsSDK.shared.startGettingClickEvents(for: view)
        AlgolyticsSDK.shared.startGettingInputEvents(for: view)
//        datePicker.addTarget(AlgolyticsSDK.shared, action: #selector(AlgolyticsSDK.shared.getDatePickerData(_:)), for: .valueChanged)

          //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

//        textField.inputAccessoryView = toolbar
//        textField.inputView = datePicker


        AlgolyticsSDK.shared.sendScreenName(name: "dada")


        textView.delegate = self
    }

    @objc func donedatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        textField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)

        AlgolyticsSDK.shared.sendCustomClickEvent(identifier: "picker", value: textField.text!)
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


