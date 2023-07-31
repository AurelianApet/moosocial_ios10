//
//  ForgotPasswordViewController.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//  code complete

import UIKit

class ForgotPasswordViewController: AppViewController,UITextFieldDelegate,AppServiceDelegate {

    @IBOutlet weak var barSendButton: UIBarButtonItem!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var forgotTextView: UITextView!
    @IBOutlet weak var forgotIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set background
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "login.background")
        self.view.insertSubview(backgroundImage, at: 0)
        
        //set navigation background
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // Layout improvement
        forgotIndicator.stopAnimating()
        title = NSLocalizedString("forgot_page_title",comment:"forgot_page_title")
        forgotTextView.text = NSLocalizedString("forgot_page_text",comment:"forgot_page_text")
        emailTextField.placeholder = NSLocalizedString("forgot_page_email_text_field",comment:"forgot_page_email_text_field")
    }

    override func viewDidLayoutSubviews() {
        self.navigationController?.navigationBar.barTintColor = AppConfigService.sharedInstance.config.navigationBar_barTintColor
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = AppConfigService.sharedInstance.config.navigationBar_textTintColor
        
        //set navi bar back button
        self.navigationController?.navigationBar.backItem?.title = ""
        
        //custom right bar button
        self.customBarButtonItem(title: NSLocalizedString("forgot_page_send",comment:"forgot_page_send"), barButton: barSendButton, action: "btnSendClick")
    }
    
    func btnSendClick(){
        if !ValidateService.sharedInstance.isEmail(emailTextField.text!) {
            alert(ValidateService.sharedInstance.getLastMessage())
        }
        else{
            forgotIndicator.startAnimating()
            UserService.sharedInstance.registerCallback(self).forgotPassword(emailTextField.text!)
        }
    }
    
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        
        switch identifier {
        case "UserService.forgot.Success":
            forgotIndicator.stopAnimating()
            emailTextField.text = ""
            //btSubmit.isHidden = true
            alert(NSLocalizedString("forgot_page_success",comment:"forgot_page_success"))
            break
        case "UserService.forgot.Failure":
            forgotIndicator.stopAnimating()
            break
        default: break
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class ForgotUITextField : UITextField {
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
