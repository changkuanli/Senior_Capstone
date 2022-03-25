//
//  KeyboardViewController.swift
//  GestureCustomKeyboard
//
//  Created by Changkuan Li on 2/10/20.
//  Copyright © 2020 ChangkuanLi. All rights reserved.
//

import UIKit
import SnapKit
import CoreML
import CoreMotion

class KeyboardViewController: UIInputViewController {

    var caseType: String = ""
    let keyboardViewHeight = 280
    
    // MARK:- Properties
    
    //ML model
    private var gestureAI = GestureAlphabetProcessor()
    
    private let queue = OperationQueue.init()
    private let motionManager = CMMotionManager()
    private lazy var timer: Timer = {
        Timer.scheduledTimer(timeInterval: 1.0, target: self,
                             selector: #selector(self.updateTimer(tm:)), userInfo: nil, repeats: true)
    }()
    let userDefaults = UserDefaults.standard
    
    private let timeMax: Int = 4
    private var cntTimer: Int = 0
    private let inputDim: Int = 3
    private let lengthMax: Int = 30
    private var sequenceTargetX: [Double] = []
    private var sequenceTargetY: [Double] = []
    private var sequenceTargetZ: [Double] = []
    
    // MARK:- Outlets
    let SCWidth = UIScreen.main.bounds.width
    @IBOutlet var nextKeyboardButton: UIButton!
    
    var pickerData: [String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    // MARK:- UIViewControllers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let heightConstraint = NSLayoutConstraint(item: self.view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: CGFloat(keyboardViewHeight))
        self.view.addConstraint(heightConstraint)
        
        //set view background to white
        self.view.backgroundColor = .white
        
        //set case type to lowercase
        caseType = "abc"
        
        addNextKeyboardButton()
        keyboardView()
        
    }
    
    //Allow user to change keyboards
    func addNextKeyboardButton() {
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    //Snapkit Auto-layout with keyboard button constraints
    func keyboardView() {
        
        let topView = UIView()
        topView.backgroundColor = .lightGray
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(50)
        }
        
        //Caps
        let caseButton: UIButton = UIButton()
        caseButton.setImage(UIImage(named: "cap.png"), for: .normal)
        caseButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        caseButton.addTarget(self, action: #selector(caseButtonTouch), for: .touchUpInside)
        topView.addSubview(caseButton)
        caseButton.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.top)
            make.left.equalTo(topView.snp.left)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        //Delete
        let delButton: UIButton = UIButton()
        delButton.setImage(UIImage(named: "delete.png"), for: .normal)
        delButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        delButton.addTarget(self, action: #selector(delButtonTouch), for: .touchUpInside)
        topView.addSubview(delButton)
        delButton.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.top)
            make.right.equalTo(self.view.snp.right)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        let bottomView = UIView()
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(50)
        }
        
        //Change Keyboard
        let chgButton: UIButton = UIButton()
        chgButton.setImage(UIImage(named: "globe.png"), for: .normal)
        chgButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        chgButton.addTarget(self, action: #selector(chgButtonTouch), for: .touchUpInside)
        bottomView.addSubview(chgButton)
        chgButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomView)
            make.left.equalTo(bottomView.snp.left).offset(10)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        //Space
        let spaceButton: UIButton = UIButton()
//        spaceButton.setImage(UIImage(named: "space.png"), for: .normal)
//        spaceButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        spaceButton.setTitle("Space", for: .normal)
        spaceButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        spaceButton.layer.cornerRadius = 5
        spaceButton.layer.masksToBounds = true
        spaceButton.layer.borderWidth = 4
        spaceButton.layer.borderColor = UIColor.black.cgColor
        spaceButton.setTitleColor(.black, for: .normal)
        spaceButton.addTarget(self, action: #selector(spaceButtonTouch), for: .touchUpInside)
        bottomView.addSubview(spaceButton)
        spaceButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomView)
            make.left.equalTo(bottomView.snp.left).offset(70)
            make.right.equalTo(bottomView.snp.right).offset(-70)
            make.height.equalTo(40)
        }
        
        let keyViewFirst = UIView()
        keyViewFirst.tag = 2000
        view.addSubview(keyViewFirst)
        keyViewFirst.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.bottom.equalTo(bottomView.snp.top).offset(-10)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        let buttonTitles: Array<Any>
        if caseType == "abc" {
            //buttonTitles = ["a-z", "a-z", "0-9"]
            buttonTitles = ["a-z"]
        }else{
            //buttonTitles = ["A-Z", "A-Z", "0-9"]
            buttonTitles = ["A-Z"]
        }
        //
        //let keyFirstWIth = SCWidth / 3
        let keyFirstWIth = SCWidth
        for i in 0..<buttonTitles.count {
            let keyX: CGFloat = CGFloat(i) * keyFirstWIth
            let keyButton:UIButton = UIButton(frame: CGRect(x: keyX, y: 0, width: keyFirstWIth, height: CGFloat(keyboardViewHeight)-120 ))
            keyButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            keyButton.setBackgroundImage(UIImage(named:"frame.png"), for: .normal)
            keyViewFirst.addSubview(keyButton)
            keyButton.setTitleColor(.black, for: .normal)
            keyButton.setTitle((buttonTitles[i] as! String), for: .normal)
            keyButton.addTarget(self, action: #selector(firstRowButtonTouchUp), for: .touchUpInside)
            keyButton.addTarget(self, action: #selector(firstRowButtonTouchDown), for: .touchDown)
        }
        
    }
    
    //Determine when user completes gesture and return character predicted by ML model
    @objc func firstRowButtonTouchUp(sender: UIButton) {
        motionManager.stopAccelerometerUpdates()
        
        //Timer stops when user releases keyboard button
        timer.invalidate()
        cntTimer = 0
        
        let cnt = self.sequenceTargetX.count
        if cnt >= inputDim {
            cntTimer = 0
            return
        }
        
        // Pay attention to input dimension for RNN
        for _ in cnt..<lengthMax*inputDim {
            self.sequenceTargetX.append(0.0)
            self.sequenceTargetY.append(0.0)
            self.sequenceTargetZ.append(0.0)
        }

        //Pass accelerometer data to ML model 
        let output = predict(self.sequenceTargetX,self.sequenceTargetY,self.sequenceTargetZ)
        
        //Output ML model predicted gesture character
        //let title = sender.title(for: .normal)
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.insertText(output.label)
        
        
    }
    
    //Determine when user begins gesturing to start timer and collect their accelerometer data
    @objc func firstRowButtonTouchDown(sender: UIButton) {
        
        self.sequenceTargetX = []
        self.sequenceTargetY = []
        self.sequenceTargetZ = []
        
        //timer determines length of acceleration data samples
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer(tm:)), userInfo: nil, repeats: true)
        timer.fire()
        
        motionManager.startAccelerometerUpdates(to: queue, withHandler: {
            (accelerometerData, error) in
            if let e = error {
                fatalError(e.localizedDescription)
            }
            //Data consists of 3 axis accelerations provided by iOS device
            guard let data = accelerometerData else { return }
            self.sequenceTargetX.append(data.acceleration.x)
            self.sequenceTargetY.append(data.acceleration.y)
            self.sequenceTargetZ.append(data.acceleration.z)
        })
    }
    
    @objc func caseButtonTouch(sender: UIButton) {
        if caseType == "ABC" {
            caseType = "abc"
        }else{
            caseType = "ABC"
        }
        let subViews = self.view.subviews
        for subview in subViews{
            if subview.tag == 2000 {
             subview.removeFromSuperview()
            }
        }
        keyboardView()
    }
    
    @objc func spaceButtonTouch(sender: UIButton) {
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.insertText(" ")
    }
    
    @objc func chgButtonTouch(sender: UIButton) {
        self.advanceToNextInputMode()
    }
    
    @objc func delButtonTouch(sender: UIButton) {
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.deleteBackward()
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    
    // MARK:- Utils
    
    @objc private func updateTimer(tm: Timer) {
        if cntTimer >= timeMax {
//TODO: change button color
            timer.invalidate()
            cntTimer = 0
            return
        }
        cntTimer += 1
    }

    /// Convert double array type into MLMultiArray
    ///
    /// - Parameters:
    /// - arr: double array
    /// - Returns: MLMultiArray
    private func toMLMultiArray(_ arr: [Double]) -> MLMultiArray {
        guard let sequence = try? MLMultiArray(shape:[30], dataType:MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        let size = Int(truncating: sequence.shape[0])
        for i in 0..<size {
            sequence[i] = NSNumber(floatLiteral: arr[i])
        }
        return sequence
    }
    
    /// Predict class label with ML model
    ///
    /// - Parameters:3 axis acceleration sequences of 26 gesture classes
    /// - arr: Sequence
    /// - Returns: Likelihood of gesture class/character
    private func predict(_ arrX: [Double], _ arrY: [Double], _ arrZ: [Double]) -> GestureAlphabetProcessorOutput {
        guard let output = try? gestureAI.prediction(input:
            GestureAlphabetProcessorInput(accelerometerAccelerationX_G_: toMLMultiArray(arrX),
                                          accelerometerAccelerationY_G_: toMLMultiArray(arrY),
                                          accelerometerAccelerationZ_G_: toMLMultiArray(arrZ)), options: MLPredictionOptions()) else {
                fatalError("Unexpected runtime error.")
        }
        return output
    }

}

