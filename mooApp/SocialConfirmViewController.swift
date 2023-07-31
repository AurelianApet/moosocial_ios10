//
//  SocialConfirmViewController.swift
//  mooApp
//
//  Created by tuan on 5/26/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import UIKit

class SocialConfirmViewController: AppViewController,UITextFieldDelegate,AppServiceDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var barConfirmButton: UIBarButtonItem!
    @IBOutlet weak var confimDescription: UITextView!
    var socialProvider : SocialProviderModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confimDescription.text = NSLocalizedString("login_page_social_confirm_description",comment:"login_page_social_confirm_description")
        loadingIndicator.stopAnimating()

        //set background
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "login.background")
        self.view.insertSubview(backgroundImage, at: 0)
        
        //set navigation background
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidLayoutSubviews() {
        self.navigationController?.navigationBar.barTintColor = AppConfigService.sharedInstance.config.navigationBar_barTintColor
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = AppConfigService.sharedInstance.config.navigationBar_textTintColor
        
        //set navi bar back button
        self.navigationController?.navigationBar.backItem?.title = ""
        
        //custom right bar button
        self.customBarButtonItem(title: NSLocalizedString("login_page_social_confirm",comment:"login_page_social_confirm"), barButton: barConfirmButton, action: "btnConfirmClick")
    }
    
    //Mark: Actions
    @IBAction func btnConfirmClick() {
        self.disableFieldsWhenLoading()
        if !ValidateService.sharedInstance.isPasswd(passwordTextField.text!) {
            alert(ValidateService.sharedInstance.getLastMessage())
            self.enableFieldsAfterLoading()
        }
        else{
            loadingIndicator.startAnimating()
            AuthenticationService.sharedInstance.registerCallback(self).socialAuth(socialProvider: self.socialProvider!, password: passwordTextField.text, confirm_password: true)
        }
    }
    
    func disableFieldsWhenLoading(){
        self.barConfirmButton.isEnabled = false
    }
    
    func enableFieldsAfterLoading(){
        self.barConfirmButton.isEnabled = true
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //emailTextField.text = textField.text
    }
    
    // Mark : AppServiceDeleage
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        switch identifier {
        case "AuthenticationService.identifyUser.socialLogin.Success":
            onIdentifyUserSuccess()
            loadingIndicator.stopAnimating()
            self.enableFieldsAfterLoading()
            break
        case "AuthenticationService.identifyUser.socialLogin.Failure":
            onIdentifyUserFailure()
            loadingIndicator.stopAnimating()
            self.enableFieldsAfterLoading()
            break
        default: break
        }
    }
    
    func onIdentifyUserSuccess(){
        self.performSegue(withIdentifier: "sequeSocialShowContainer",sender: self)
    }
    
    func onIdentifyUserFailure(){
        
    }
}

class SocialConfirmUITextField : UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 0, dy: 5);
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 0, dy: 5);
    }
    
    override func didAddSubview(_ subview: UIView) {
        let border = CALayer()
        let width = CGFloat(2.0)
        self.textColor = AppConfigService.sharedInstance.config.color_fields_login_style
        border.borderColor = AppConfigService.sharedInstance.config.color_fields_login_style.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        tintColor = AppConfigService.sharedInstance.config.color_fields_login_style
        
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder!, attributes: [NSForegroundColorAttributeName: AppConfigService.sharedInstance.config.color_fields_login_style])
    }
}
