//
//  FirstViewController.swift
//  GestureRecognition
//
//  Created by Kramer, Jeremiah William on 1/17/20.
//  Copyright © 2020 OSU-CS11. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var labelText = ""
    
    @IBOutlet weak var labelPicker: UIPickerView!
    
    @IBOutlet weak var userInput: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    
    let labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return labels[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        labels.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        labelText = labels[row].lowercased()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func enterField(_ sender: Any) {        
        if userInput.text!.lowercased() == labelText {
            textView.text = "Success!"
        }
        else {
            textView.text = "Failure!"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userInput.resignFirstResponder()
    }
}

extension FirstViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
