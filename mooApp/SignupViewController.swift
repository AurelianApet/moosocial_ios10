//
//  SignupViewController.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//  code complete

import Foundation
import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class SignupViewController: AppViewController,UITextFieldDelegate, UIPickerViewDelegate,AppServiceDelegate,UITextViewDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    // Mark : Label Properties
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var verifyPassLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    // Mark : Error Properties
    @IBOutlet weak var emailErrLabel: UILabel!
    @IBOutlet weak var nameErrLabel: UILabel!
    @IBOutlet weak var passErrLabel: UILabel!
    @IBOutlet weak var verifyPassErrLabel: UILabel!
    @IBOutlet weak var birthdayErrLabel: UILabel!
    @IBOutlet weak var genderErrLabel: UILabel!
    
    // Mark : TextField Properties
    
    @IBOutlet weak var emailTxtField: SignupUITextField!
    @IBOutlet weak var nameTextField: SignupUITextField!
    @IBOutlet weak var passTextField: SignupUITextField!
    @IBOutlet weak var verifyPassTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var genderTextField: SignupUITextField!
    //@IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var singUpNewAccountLabel: UILabel!
    
    @IBOutlet weak var itFreeAndAlwaysLabel: UILabel!
    @IBOutlet weak var createLoading: UIActivityIndicatorView!
    // Mark : View Properties
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var barSignUpButton: UIBarButtonItem!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    var socialProvider = SocialProviderModel()
    
    
    @IBOutlet weak var agreeTextView: UITextView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var socialText: UILabel!
    @IBOutlet weak var orEmailText: UILabel!
    // Hacking for performSelector
    var performSelectorValidate = false
    var linkClicked:URL?
    // Mark: Properties
    let datePickerView:UIDatePicker = UIDatePicker()
    let genderPickerView = UIPickerView()
    //let genderOption = ["Male","Female"]
    let genderOption = [NSLocalizedString("signup_page_gender_option_male_label",comment:"signup_page_gender_option_male_label"),NSLocalizedString("signup_page_gender_option_female_label",comment:"signup_page_gender_option_female_label")]
    let methodsValidation = ["email","name","password","verifyPass"]
    // ["email","name","password","verifyPass","birthday","gender"]
    func assignDelegate(){
        emailTxtField.delegate = self
        nameTextField.delegate = self
        passTextField.delegate = self
        verifyPassTextField.delegate = self
        birthdayTextField.delegate = self
        genderTextField.delegate = self
    }
    func hideAllLabelOfField(){
        //emailLabel.hidden = true
        hideObject("emailLabel")
        hideObject("nameLabel")
        hideObject("passwordLabel")
        hideObject("verifyPassLabel")
        hideObject("birthdayLabel")
        hideObject("genderLabel")
    }
    func hideAllErrorOfField(){
        hideObject("emailError")
        hideObject("nameError")
        hideObject("passwordError")
        hideObject("verifyPassError")
        hideObject("birthdayError")
        hideObject("genderError")
    }
    func hideObject(_ name:String){
        setConstraintsCustomize(name, topBottom: 0, height: 0)
    }
    func showObject(_ name:String){
        setConstraintsCustomize(name, topBottom: 8, height: 12)
    }
    func setConstraintsCustomize(_ name:String,topBottom:CGFloat,height:CGFloat){
        for constraint in contentView.constraints{
            if constraint.identifier == "\(name).top" || constraint.identifier == "\(name).bottom"{
                constraint.constant = topBottom
            }
        }
        for subview in contentView.subviews as [UIView] {
            if subview.constraints.count > 0 {
                for constraint in subview.constraints{
                    if constraint.identifier == "\(name).height"{
                        constraint.constant = height
                    }
                }
            }
        }
    }
    func customUIDatePicker(){
        
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.backgroundColor = UIColor.white
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(SignupViewController.doneBirthdayPicker(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        //let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Done, target: self, action: "cancleBirthdayPicker:")
        
        //toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        
        
        datePickerView.addTarget(self, action: #selector(SignupViewController.birthdayPickerValueChanged(_:)), for: UIControlEvents.valueChanged)
        
        birthdayTextField.inputView = datePickerView
        birthdayTextField.inputAccessoryView = toolBar
    }
    func customUIGenderPicker(){
        genderPickerView.backgroundColor = UIColor.white
        genderPickerView.delegate = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(SignupViewController.doneGenderPicker(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        //let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Done, target: self, action: "cancleBirthdayPicker:")
        
        //toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        
        genderTextField.inputView = genderPickerView
        genderTextField.inputAccessoryView = toolBar
    }
    func doneBirthdayPicker(_ sender: UIBarButtonItem){
        
        birthdayTextField.resignFirstResponder()
    }
    func doneGenderPicker(_ sender: UIBarButtonItem){
        
        genderTextField.resignFirstResponder()
    }
    func cancleBirthdayPicker(_ sender: UIBarButtonItem){
        birthdayTextField.resignFirstResponder()
    }
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
        
        // Multi-Language Support
        title = NSLocalizedString("signup_page_sign_up_title",comment:"signup_page_sign_up_title")
        
        emailTxtField.placeholder = NSLocalizedString("signup_page_email_placeholder_txtfield",comment:"signup_page_email_placeholder_txtfield")
        emailErrLabel.text = NSLocalizedString("signup_page_email_err_label",comment:"signup_page_email_err_label")
        
        nameTextField.placeholder = NSLocalizedString("signup_page_name_placeholder_txtfield",comment:"signup_page_name_placeholder_txtfield")
        nameErrLabel.text = NSLocalizedString("signup_page_name_err_label",comment:"signup_page_name_err_label")
        
        passTextField.placeholder = NSLocalizedString("signup_page_pass_placeholder_txtfield",comment:"signup_page_pass_placeholder_txtfield")
        passErrLabel.text = NSLocalizedString("signup_page_pass_err_label",comment:"signup_page_pass_err_label")
        
        verifyPassTextField.placeholder = NSLocalizedString("signup_page_verify_pass_placeholder_txtfield",comment:"signup_page_verify_pass_placeholder_txtfield")
        verifyPassErrLabel.text = NSLocalizedString("signup_page_verify_pass_err_label",comment:"signup_page_verify_pass_err_label")
        
        birthdayTextField.placeholder = NSLocalizedString("signup_page_birthday_placeholder_txtfield",comment:"signup_page_birthday_placeholder_txtfield")
        birthdayErrLabel.text = NSLocalizedString("signup_page_birthday_err_label",comment:"signup_page_birthday_err_label")
        
        genderTextField.placeholder = NSLocalizedString("signup_page_gender_placeholder_txtfield",comment:"signup_page_gender_placeholder_txtfield")
        genderErrLabel.text = NSLocalizedString("signup_page_gender_err_label",comment:"signup_page_gender_err_label")
        socialText.text = NSLocalizedString("signup_page_social_text",comment:"signup_page_social_text")
        orEmailText.text = NSLocalizedString("signup_page_or_email_text",comment:"signup_page_or_email_text")
        
        assignDelegate()
        hideAllErrorOfField()
        customUIDatePicker()
        customUIGenderPicker()
        // For create button
        createLoading.stopAnimating()
        // For terms of service
        buildAgreeTextView()
        
        //check social enabled
        if SharedPreferencesService.sharedInstance.loadSettings(key: "mooapp_enable_facebook_login") as! String == "1" || SharedPreferencesService.sharedInstance.loadSettings(key: "mooapp_enable_google_login") as! String == "1" {
            socialText.isHidden = false
            orEmailText.isHidden = false
        }
        else{
            socialText.isHidden = true
            orEmailText.isHidden = true
        }
        
        //facebook login
        if SharedPreferencesService.sharedInstance.loadSettings(key: "mooapp_enable_facebook_login") as! String == "1" {
            facebookButton.isHidden = false
            facebookButton.addTarget(self, action: #selector(self.btnFBLoginPressed(_:)), for: UIControlEvents.touchUpInside)
        }
        else{
            facebookButton.isHidden = true
        }
        
        //google login
        if SharedPreferencesService.sharedInstance.loadSettings(key: "mooapp_enable_google_login") as! String == "1" {
            //FIRApp.configure()
            GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            googleButton.addTarget(self, action: #selector(self.btnFGoogleLoginPressed(_:)), for: UIControlEvents.touchUpInside)
        }
        else{
            googleButton.isHidden = true
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollview.contentSize = CGSize(width: contentView.frame.width, height: contentView.frame.height + 100)
        
        self.navigationController?.navigationBar.barTintColor = AppConfigService.sharedInstance.config.navigationBar_barTintColor
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = AppConfigService.sharedInstance.config.navigationBar_textTintColor
        
        //set navi bar back button
        self.navigationController?.navigationBar.backItem?.title = ""
        
        //custom right bar button
        self.customBarButtonItem(title: NSLocalizedString("signup_page_create",comment:"signup_page_create"), barButton: barSignUpButton, action: "btnSignUpClick")
    }
    
    func btnLoginClick(_ sender: AnyObject) {
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.accessibilityActivate()
        let identifer = textField.accessibilityIdentifier?.replacingOccurrences(of: "TextField",with: "")
        showObject(identifer!+"Label")
        textField.accessibilityLabel = textField.placeholder
        textField.placeholder = ""
        
        if isGenderField(identifer!){
            if genderTextField.text?.characters.count == 0 {
                genderTextField.text = genderOption[0]
            }
            
            
        }
        
    }
    
    func birthdayPickerValueChanged(_ sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        //dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        //dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateFormat = "yyyy-MM-dd"
        birthdayTextField.text = dateFormatter.string(from: sender.date)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.placeholder = textField.accessibilityLabel
        hideObject((textField.accessibilityIdentifier?.replacingOccurrences(of: "TextField", with: "Label"))!)
        let identifer = textField.accessibilityIdentifier?.replacingOccurrences(of: "TextField",with: "")
        if methodsValidation.contains(identifer!) {
            if doValidate(identifer!){
                
            }
        }
        
        
        
        
    }
    func doValidate(_ identifer:String)->Bool{
        performSelectorValidate = false
        let method = identifer + "Validate"
        self.perform(Selector(method))
        if performSelectorValidate{
            hideObject(identifer+"Error")
        }else{
            showObject(identifer+"Error")
        }
        return performSelectorValidate
    }
    func emailValidate()->Bool{
        performSelectorValidate = ValidateService.sharedInstance.isEmail(emailTxtField.text!)
        return performSelectorValidate
    }
    func nameValidate()->Bool{
        performSelectorValidate = ValidateService.sharedInstance.isStringEmpty(nameTextField.text!)
        return performSelectorValidate
    }
    func passwordValidate()->Bool{
        performSelectorValidate = ValidateService.sharedInstance.isStringEmpty(passTextField.text!)
        return performSelectorValidate
    }
    func verifyPassValidate()->Bool{
        performSelectorValidate = ValidateService.sharedInstance.isStringEmpty(verifyPassTextField.text!)
        verifyPassErrLabel.text = NSLocalizedString("signup_page_verify_pass_err_label",comment:"signup_page_verify_pass_err_label")
        if (passTextField.text?.characters.count > 0) && (passTextField.text != verifyPassTextField.text){
            performSelectorValidate = false
            verifyPassErrLabel.text = NSLocalizedString("signup_page_verify_pass_err_label_2",comment:"signup_page_verify_pass_err_label_2")
        }
        return performSelectorValidate
    }
    func birthdayValidate()->Bool{
        return true
        //performSelectorValidate = ValidateService.sharedInstance.isStringEmpty(birthdayTextField.text!)
        //return performSelectorValidate
    }
    func genderValidate()->Bool{
        performSelectorValidate = ValidateService.sharedInstance.isStringEmpty(genderTextField.text!)
        return performSelectorValidate
    }
    func isGenderField( _ identifer:String)->Bool{
        
        if identifer == "gender"{
            return true
        }
        return false
    }
    
    @IBAction func btnSignUpClick() {
        var allValidated = true
        for method in methodsValidation {
            if !doValidate(method){
                allValidated = false
            }
        }
        if allValidated && !createLoading.isAnimating{
            var genderValue = ""
            // changed for new birthday apple rule
            if birthdayTextField.text == "" {
                //birthdayTextField.text = "1990-07-13"
            }
            if genderTextField.text == NSLocalizedString("signup_page_gender_option_female_label",comment:"signup_page_gender_option_female_label"){
                genderValue = "Female"
            }
            if genderTextField.text == NSLocalizedString("signup_page_gender_option_male_label",comment:"signup_page_gender_option_male_label"){
                genderValue = "Male"
            }
            UserService.sharedInstance.registerCallback(self).create(emailTxtField.text!, name: nameTextField.text!, passwd: passTextField.text!, birthday: birthdayTextField.text, gender: genderValue)
            createLoading.startAnimating()
        }
    }
    // Gender Picker View Deleage
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOption.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genderOption[row]
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOption[row]
    }
    
    // AppService Deleage
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        
        switch identifier {
        case "UserService.create.Success":
            if data != nil && data!["approve_users"]  as? String == "1" {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "login") as! LoginViewController
                self.present(nextViewController, animated:true, completion:nil)
                AlertService.sharedInstance.process(NSLocalizedString("your_account_is_pending_for_approval",comment:"your_account_is_pending_for_approval"))
            }
            else {
                createLoading.stopAnimating()
                AuthenticationService.sharedInstance.registerCallback(self).identifyUser(data!["email"] as? String,passwd:data!["password"] as? String)
            }
            break
        case "UserService.create.Failure": print("22")
        createLoading.stopAnimating()
            break
        case "AuthenticationService.identifyUser.forceLogin.Success":print("33")
        self.performSegue(withIdentifier: "sequeSingupShowContainer",sender: self)
            break
        case "AuthenticationService.identifyUser.socialLogin.Success":
            self.performSegue(withIdentifier: "sequeSingupShowContainer",sender: self)
            createLoading.stopAnimating()
            break
        case "AuthenticationService.identifyUser.socialLogin.Failure":
            createLoading.stopAnimating()
            break
        case "AuthenticationService.identifyUser.socialLogin.Confirm":
            onIdentifySocialConfirm()
            createLoading.stopAnimating()
            break
        default: break
        }
    }
    
    func onIdentifySocialConfirm(){
        self.performSegue(withIdentifier: "sequeSignupShowSocialConfirm",sender: self)
    }
    
    //
    func buildAgreeTextView()
    {
        let text = NSLocalizedString("signup_page_agree_text_view",comment:"signup_page_agree_text_view")
        let termsRange = (text as NSString).range(of: NSLocalizedString("signup_page_agree_text_view_link_string_1",comment:"signup_page_agree_text_view_link_string_1"))
        let privacyRange = (text as NSString).range(of: NSLocalizedString("signup_page_agree_text_view_link_string_2",comment:"signup_page_agree_text_view_link_string_2"))
        let attributedString = NSMutableAttributedString(string:text)
        attributedString.addAttribute(NSLinkAttributeName, value: AppConfigService.sharedInstance.getTermOfServiceURL() , range: termsRange)
        attributedString.addAttribute(NSLinkAttributeName, value: AppConfigService.sharedInstance.getPrivacyPolicyURL(), range: privacyRange)
        
        //agreeTextView.attributedText = attributedString
        //agreeTextView.delegate = self
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        linkClicked = URL
        self.performSegue(withIdentifier: "segueWebPage",sender: self)
        return false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueWebPage" {
            
            let containerViewController = segue.destination as! SearchDetailViewController
            
            
            containerViewController.webUrl = linkClicked!.absoluteString
            
        }
        else if (segue.identifier == "sequeSignupShowSocialConfirm") {
            //get a reference to the destination view controller
            let destinationVC = segue.destination as! SocialConfirmViewController
            
            //set properties on the destination view controller
            destinationVC.socialProvider = self.socialProvider
        }
    }
    
    func disableFieldsWhenLoading(){
        self.barSignUpButton.isEnabled = false
        self.facebookButton.isEnabled = false
        self.googleButton.isEnabled = false
    }
    
    func enableFieldsAfterLoading(){
        self.barSignUpButton.isEnabled = true
        self.facebookButton.isEnabled = true
        self.googleButton.isEnabled = true
    }
    
    //facebook log in
    @IBAction func btnFBLoginPressed(_ sender: AnyObject) {
        self.createLoading.startAnimating()
        self.disableFieldsWhenLoading()
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if let error = error {
                AlertService.sharedInstance.process("Failed to login: \(error.localizedDescription)")
                self.createLoading.stopAnimating()
                self.enableFieldsAfterLoading()
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                AlertService.sharedInstance.process("Failed to get access token")
                self.createLoading.stopAnimating()
                self.enableFieldsAfterLoading()
                return
            }
            //let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            if((FBSDKAccessToken.current()) != nil){
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture"]).start(completionHandler: { (connection, userResult, userError) -> Void in
                    if (userError != nil){
                        AlertService.sharedInstance.process("Failed to login: \(String(describing: userError?.localizedDescription))")
                        self.createLoading.stopAnimating()
                        self.enableFieldsAfterLoading()
                        return
                    }
                    else{
                        let user = userResult as! NSDictionary
                        let picture = user["picture"] as! NSDictionary
                        let picture_data = picture["data"] as! NSDictionary
                        
                        self.socialProvider.setData(provider: AppConstants.MOO_SOCIAL_PROVIDER_FACEBOOK, id: FBSDKAccessToken.current().userID, socialEmail: user["email"]! as! String, displayName: user["name"]! as! String, photoUrl: picture_data["url"]! as! String, accessToken: accessToken.tokenString)
                        let authenticationService = AuthenticationService()
                        authenticationService.registerCallback(self).socialAuth(socialProvider: self.socialProvider)
                    }
                    
                })
            }
        }
    }
    
    //google sign in
    @IBAction func btnFGoogleLoginPressed(_ sender: AnyObject) {
        self.createLoading.startAnimating()
        self.disableFieldsWhenLoading()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn();
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            AlertService.sharedInstance.process(error.localizedDescription)
            self.createLoading.stopAnimating()
            self.enableFieldsAfterLoading()
            return
        }
        //let authentication = user.authentication
        //let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        
        self.socialProvider.setData(provider: AppConstants.MOO_SOCIAL_PROVIDER_GOOGLE, id: (user?.userID)!, socialEmail: (user.profile.email!), displayName: (user.profile.givenName!), photoUrl: (user.profile.imageURL(withDimension: 200).absoluteString), accessToken: user.authentication.accessToken)
        let authenticationService = AuthenticationService()
        authenticationService.registerCallback(self).socialAuth(socialProvider: self.socialProvider)
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}

class SignupUITextField : UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 0, dy: 5);
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 0, dy: 5);
    }
    
    override func didAddSubview(_ subview: UIView) {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = AppConfigService.sharedInstance.config.color_fields_login_style.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder!, attributes: [NSForegroundColorAttributeName: AppConfigService.sharedInstance.config.color_fields_login_style])
    }
}
