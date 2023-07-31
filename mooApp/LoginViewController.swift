//
//  ViewController.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//  code complete

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: AppViewController,UITextFieldDelegate,AppServiceDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    // Mark : Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //@IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var barSignInButton: UIBarButtonItem!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var socialText: UITextView!
    var socialProvider = SocialProviderModel()
    
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
        title = NSLocalizedString("login_page_login_title",comment:"login_page_login_title")
        emailTextField.placeholder = NSLocalizedString("login_page_email_text_field",comment:"login_page_email_text_field")
        passwordTextField.placeholder = NSLocalizedString("login_page_password_text_field",comment:"login_page_password_text_field")
        forgotButton.setTitle(NSLocalizedString("login_page_forgot_password",comment:"login_page_forgot_password"), for: UIControlState())
        socialText.text = NSLocalizedString("login_page_social_text",comment:"login_page_social_text")
        emailTextField.delegate = self
        loginIndicator.stopAnimating()
        
        //check social enabled
        socialText.isHidden = true
        facebookButton.isHidden = true
        googleButton.isHidden = true
        if let facebook_login = SharedPreferencesService.sharedInstance.loadSettings(key: "mooapp_enable_facebook_login") {
            if facebook_login as! String == "1"{
                socialText.isHidden = false
                facebookButton.isHidden = false
                facebookButton.addTarget(self, action: #selector(self.btnFBLoginPressed(_:)), for: UIControlEvents.touchUpInside)
            }
        }
        if let google_login = SharedPreferencesService.sharedInstance.loadSettings(key: "mooapp_enable_google_login") {
            if google_login as! String == "1"{
                socialText.isHidden = false
                googleButton.isHidden = false
                GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
                GIDSignIn.sharedInstance().delegate = self
                GIDSignIn.sharedInstance().uiDelegate = self
                googleButton.addTarget(self, action: #selector(self.btnFGoogleLoginPressed(_:)), for: UIControlEvents.touchUpInside)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString("login_page_login_title",comment:"login_page_login_title")
    }
    
    override func viewDidLayoutSubviews() {
        self.navigationController?.navigationBar.barTintColor = AppConfigService.sharedInstance.config.navigationBar_barTintColor
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = AppConfigService.sharedInstance.config.navigationBar_textTintColor
        
        //set navi bar back button
        self.navigationController?.navigationBar.backItem?.title = ""
        
        //custom right bar button
        self.customBarButtonItem(title: NSLocalizedString("login_page_sign_in",comment:"login_page_sign_in"), barButton: barSignInButton, action: "btnLoginClick")
    }
    
    func dumpingDataForTesting(_ type:String="local"){
        if type == "local"{
            emailTextField.text = "root@local.com"
            passwordTextField.text = "1"
        }else if type == "demo"{
            emailTextField.text = "demo1@moosocial.com"
            passwordTextField.text = "123456"
        }
    }
    
    func disableFieldsWhenLoading(){
        self.emailTextField.isEnabled = false
        self.passwordTextField.isEnabled = false
        self.barSignInButton.isEnabled = false
        self.facebookButton.isEnabled = false
        self.googleButton.isEnabled = false
    }
    
    func enableFieldsAfterLoading(){
        self.emailTextField.isEnabled = true
        self.passwordTextField.isEnabled = true
        self.barSignInButton.isEnabled = true
        self.facebookButton.isEnabled = true
        self.googleButton.isEnabled = true
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        emailTextField.text = textField.text
    }
    //Mark: Actions
    @IBAction func btnLoginClick() {
        if !ValidateService.sharedInstance.isEmail(emailTextField.text!) {
            alert(ValidateService.sharedInstance.getLastMessage())
        }else if !ValidateService.sharedInstance.isPasswd(passwordTextField.text!) {
            alert(ValidateService.sharedInstance.getLastMessage())
        }
        else{
            loginIndicator.startAnimating()
            self.disableFieldsWhenLoading()
            let authenticationService = AuthenticationService()
            authenticationService.registerCallback(self).identifyUser(emailTextField.text,passwd:passwordTextField.text)
        }
    }
    
    //facebook log in
    @IBAction func btnFBLoginPressed(_ sender: AnyObject) {
        self.loginIndicator.startAnimating()
        self.disableFieldsWhenLoading()
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if let error = error {
                AlertService.sharedInstance.process("Failed to login: \(error.localizedDescription)")
                self.loginIndicator.stopAnimating()
                self.enableFieldsAfterLoading()
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                AlertService.sharedInstance.process("Failed to get access token")
                self.loginIndicator.stopAnimating()
                self.enableFieldsAfterLoading()
                return
            }
            //let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            if((FBSDKAccessToken.current()) != nil){
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture"]).start(completionHandler: { (connection, userResult, userError) -> Void in
                    if (userError != nil){
                        AlertService.sharedInstance.process("Failed to login: \(String(describing: userError?.localizedDescription))")
                        self.loginIndicator.stopAnimating()
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
        self.loginIndicator.startAnimating()
        self.disableFieldsWhenLoading()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn();
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            AlertService.sharedInstance.process(error.localizedDescription)
            self.loginIndicator.stopAnimating()
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
    
    //Mark: Validation
    func checkValidemailTextField() {
        // Disable the Save button if the text field is empty.
        //let text = emailTextField.text ?? ""
        
    }
    // Mark : AppServiceDeleage
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        switch identifier {
        case "AuthenticationService.identifyUser.forceLogin.Success":
            onIdentifyUserSuccess()
            loginIndicator.stopAnimating()
            self.enableFieldsAfterLoading()
            break
        case "AuthenticationService.identifyUser.forceLogin.Failure":
            loginIndicator.stopAnimating()
            self.enableFieldsAfterLoading()
            break
        case "AuthenticationService.identifyUser.forceRefeshToken.Failure":
            onIdentifyUserFailure()
            loginIndicator.stopAnimating()
            self.enableFieldsAfterLoading()
            break
        case "AuthenticationService.identifyUser.socialLogin.Success":
            onIdentifyUserSuccess()
            loginIndicator.stopAnimating()
            self.enableFieldsAfterLoading()
            break
        case "AuthenticationService.identifyUser.socialLogin.Failure":
            onIdentifyUserFailure()
            loginIndicator.stopAnimating()
            self.enableFieldsAfterLoading()
            break
        case "AuthenticationService.identifyUser.socialLogin.Confirm":
            onIdentifySocialConfirm()
            loginIndicator.stopAnimating()
            self.enableFieldsAfterLoading()
            break
        default: break
        }
    }
    func onIdentifyUserSuccess(){
        //self.performSegue(withIdentifier: "sequeShowContainer",sender: self)
        
        let topVC = topMostController()
        let vcToPresent = self.storyboard!.instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
        topVC.present(vcToPresent, animated: true, completion: nil)
    }
    func onIdentifyUserFailure(){
        
    }
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    func onIdentifySocialConfirm(){
        self.performSegue(withIdentifier: "sequeShowSocialConfirm",sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "sequeShowSocialConfirm") {
            //get a reference to the destination view controller
            let destinationVC = segue.destination as! SocialConfirmViewController
            
            //set properties on the destination view controller
            destinationVC.socialProvider = self.socialProvider
        }
    }
    
    
}

class LoginUITextField : UITextField {
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
