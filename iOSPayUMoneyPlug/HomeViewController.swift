//
//  ViewController.swift
//  iOSPayUMoneyPlug
//
//  Created by macbook pro on 27/02/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import SystemConfiguration
import PayUMoneyCoreSDK
import PlugNPlay
import CryptoSwift

class HomeViewController: UIViewController {
    
    // MARK:- Outlets and variable declaration.
    
    @IBOutlet weak var txtForName : UITextField!
    @IBOutlet weak var txtForEmail : UITextField!
    @IBOutlet weak var txtForMobileNumber : UITextField!
    @IBOutlet weak var txtForAmount : UITextField!
    @IBOutlet weak var btnForPay : UIButton!
    @IBOutlet weak var switchForMode : UISwitch!
    
    @IBOutlet weak var errLblForName : UILabel!
    @IBOutlet weak var errLblForEmail : UILabel!
    @IBOutlet weak var errLblForMobileNumber : UILabel!
    @IBOutlet weak var errLblForAmount : UILabel!
    
    let kMerchantKey = "DR7WcSiy"
    let kMerchantID = "6646801"
    let kMerchantSalt = "cz84LBiAY7"
    
    let NETWORK_ERR_TITLE = "Network failure!"
    let NETWORK_ERR_MESSAGE = "No internet available. Please check your connection."
    
    let paymentParam = PUMTxnParam()
    
    let themeColor = UIColor.purple
    let themeTextColor = UIColor.white
    
    // MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.txtForName.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        self.txtForEmail.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        self.txtForMobileNumber.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        self.txtForAmount.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // MARK:- Button action methods
    
    @IBAction func payPressed(_ sender: Any) {
        if self.isConnectedToNetwork(){
            self.configurePaymentParameters()
            //Set UI level customisations in PnP
            PlugNPlay.setButtonColor(themeColor)
            PlugNPlay.setTopBarColor(themeColor)
            PlugNPlay.setIndicatorTintColor(themeColor)
            PlugNPlay.setButtonTextColor(themeTextColor)
            PlugNPlay.setTopTitleTextColor(themeTextColor)
            
            PlugNPlay.presentPaymentViewController(withTxnParams: paymentParam, on: self) { (response, erroe, extraParam) in
                if let respDict = response as NSDictionary?{
                    if ((respDict.value(forKey: "result") as! NSDictionary).value(forKey: "status") as? String ?? "") == "success"{
                        self.txtForName.text = ""
                        self.txtForEmail.text = ""
                        self.txtForMobileNumber.text = ""
                        self.txtForAmount.text = ""
                    }
                }
            }
        }else{
            self.showNetworkUnavailableAlert()
        }
    }
    
    /// Used to show network alert message
    private func showNetworkUnavailableAlert(){
        let alertVc = UIAlertController(title: self.NETWORK_ERR_TITLE, message: self.NETWORK_ERR_MESSAGE, preferredStyle: UIAlertController.Style.alert)
        alertVc.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertVc, animated: true, completion: nil)
    }
    
    // MARK:- PayUMoney configuration methods
    
    /// Used to configure all payment parameters
    private func configurePaymentParameters(){
        paymentParam.firstname = self.txtForName.text ?? ""
        paymentParam.email = self.txtForEmail.text ?? ""
        paymentParam.phone = self.txtForMobileNumber.text ?? ""
        paymentParam.amount = self.txtForAmount.text ?? ""
        paymentParam.key =  kMerchantKey
        paymentParam.merchantid = kMerchantID
        paymentParam.txnID = "\(Int(Date().timeIntervalSince1970) * 1000)"
        paymentParam.surl = "https://www.payumoney.com/mobileapp/payumoney/success.php"
        paymentParam.furl = "https://www.payumoney.com/mobileapp/payumoney/failure.php"
        paymentParam.productInfo = UIDevice.current.name
        if self.switchForMode.isOn{
            paymentParam.environment = PUMEnvironment.production
        }else{
            paymentParam.environment = PUMEnvironment.test
        }
        paymentParam.udf1 = ""
        paymentParam.udf2 = ""
        paymentParam.udf3 = ""
        paymentParam.udf4 = ""
        paymentParam.udf5 = ""
        paymentParam.udf6 = ""
        paymentParam.udf7 = ""
        paymentParam.udf8 = ""
        paymentParam.udf9 = ""
        paymentParam.udf10 = ""
        paymentParam.hashValue = self.generateHash()
    }
    
    
    /// Used to generate PayUMoney HASH value
    ///
    /// - Returns: HASH value
    func generateHash() -> String{
        
        let hashSequence : String = "\(paymentParam.key!)|\(paymentParam.txnID!)|\(paymentParam.amount!)|\(paymentParam.productInfo!)|\(paymentParam.firstname!)|\(paymentParam.email!)|\(paymentParam.udf1!)|\(paymentParam.udf2!)|\(paymentParam.udf3!)|\(paymentParam.udf4!)|\(paymentParam.udf5!)|\(paymentParam.udf6!)|\(paymentParam.udf7!)|\(paymentParam.udf8!)|\(paymentParam.udf9!)|\(paymentParam.udf10!)|\(kMerchantSalt)"
        
        let hash = "\(hashSequence)".replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "").sha512()
        return hash
    }
    
    // MARK:- Validating methods
    
    /// Used to locally validate enter email adress.
    ///
    /// - Parameter testStr: email address
    /// - Returns: result
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    /// Used to locally validate enter email adress.
    ///
    /// - Parameter testStr: email address
    /// - Returns: result
    func isValidMobileNumber(mobNoStr:String) -> Bool {
        let mobNoRegEx = "^[987]\\d{9}$"
        let mobNoTest = NSPredicate(format:"SELF MATCHES %@", mobNoRegEx)
        return mobNoTest.evaluate(with: mobNoStr)
    }
    
     /// Hide/Show error message for name field
    func handlingErrorMessageForName(){
        if ((self.txtForName.text ?? "").replacingOccurrences(of: " ", with: "").count >= 3) && ((self.txtForName.text ?? "").replacingOccurrences(of: " ", with: "").count <= 25) {
            self.errLblForName.isHidden = true
        }else{
            self.errLblForName.isHidden = false
        }
    }
    
     /// Hide/Show error message for email address field
    func handlingErrorMessageForEmail(){
        if self.isValidEmail(testStr: (self.txtForEmail.text ?? "")){
            self.errLblForEmail.isHidden = true
        }else{
            self.errLblForEmail.isHidden = false
        }
    }
    
     /// Hide/Show error message for moble number field
    func handlingErrorMessageForMobileNumber(){
        if (self.isValidMobileNumber(mobNoStr: self.txtForMobileNumber.text ?? "")) {
            self.errLblForMobileNumber.isHidden = true
        }else{
            self.errLblForMobileNumber.isHidden = false
        }
    }
    
    /// Hide/Show error message for amount field
    func handlingErrorMessageForAmount(){
        if ((self.txtForAmount.text ?? "").count != 0 && (((self.txtForAmount.text ?? "") as NSString).floatValue >= 1) && ((self.txtForAmount.text ?? "") as NSString).floatValue <= 9999){
            self.errLblForAmount.isHidden = true
        }else{
            self.errLblForAmount.isHidden = false
        }
    }
    /// Used to validate all input field locally
    ///
    /// - Returns: result
    func allInputFileAreValid()->Bool{
        if self.isValidEmail(testStr: (self.txtForEmail.text ?? "")) && ((self.txtForName.text ?? "").replacingOccurrences(of: " ", with: "").count >= 3) && (self.isValidMobileNumber(mobNoStr: self.txtForMobileNumber.text ?? "")) && ((self.txtForAmount.text ?? "").count != 0 && (((self.txtForAmount.text ?? "") as NSString).floatValue >= 1) && ((self.txtForAmount.text ?? "") as NSString).floatValue <= 9999){
            return true
        }
        return false
    }
    
    /// Used to check connectivity
    ///
    /// - Returns: flag
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let isConnected = (isReachable && !needsConnection)
        
        return isConnected
    }
}

// MARK: - UITextFieldDelegate
extension HomeViewController :UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1{
            return (txtForName.text?.count)! - range.length + string.count <= 25
        }else if textField.tag == 3{
            return (txtForMobileNumber.text?.count)! - range.length + string.count <= 10
        }else if textField.tag == 4 {
            let dotString = "."
            if string == "0" && (textField.text ?? "") == "0"{
                return false
            }else if (textField.text ?? "").contains(dotString) && string == "."{
                return false
            }else if !(textField.text ?? "").contains(dotString) && string != dotString{
                if textField.text?.first == "0"{
                    return (txtForAmount.text?.count ?? 0)! - range.length + string.count <= 5
                }else{
                    return (txtForAmount.text?.count ?? 0)! - range.length + string.count <= 4
                }
            }
            if let text = textField.text{
                let isDeleteKey = string.isEmpty
                if !isDeleteKey {
                    if text.contains(dotString) {
                        if text.components(separatedBy: dotString)[1].count == 2 {
                            return false
                        }
                    }
                }
            }
        }
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        switch textField.tag {
        case 1:
            self.handlingErrorMessageForName()
        case 2:
            self.handlingErrorMessageForEmail()
        case 3:
            self.handlingErrorMessageForMobileNumber()
        case 4:
            self.handlingErrorMessageForAmount()
        default:
            print("Invalid")
        }
        if self.allInputFileAreValid() {
            self.btnForPay.isEnabled = true
            self.btnForPay.layer.backgroundColor = themeColor.cgColor
            self.btnForPay.titleLabel?.textColor = themeTextColor
        }else{
            self.btnForPay.isEnabled = false
            self.btnForPay.layer.backgroundColor = UIColor.lightGray.cgColor
            self.btnForPay.titleLabel?.textColor = UIColor.white
        }
    }
}

// MARK: - Touch events
extension HomeViewController{
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
