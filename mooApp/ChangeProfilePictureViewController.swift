//
//  ChangeProfilePictureViewController.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit

class ChangeProfilePictureViewController: AppViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate , AppServiceDelegate,ImageServiceAsynchronouslyDelegate{
    var imageChosen:UIImage?
    var homeTabBarController:HomeTabBarViewController?
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var meModel:UserModel?
    
    @IBOutlet weak var avatarLoading: UIActivityIndicatorView!
    @IBAction func doCancel(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBOutlet weak var tapOnThePicureLabel: UILabel!
    override func viewDidLoad() {
        // Suppports NSLocalizedString
        navigationItem.title = NSLocalizedString("menus_account_change_profile_picture",comment:"menus_account_change_profile_picture")
        tapOnThePicureLabel.text = NSLocalizedString("change_profile_picture_message_tap_on_the_picture",comment:"change_profile_picture_message_tap_on_the_picture")
        // End supports NSLocalizedString
        super.viewDidLoad()
        saveButton.isEnabled = false
        meModel = UserService.sharedInstance.get()
        if meModel != nil {
            if let avatar  = meModel?.avatar as? [String:String]{
                
                if let url = avatar["600"] {
                      ImageService.sharedInstance.getAsynchronously(avatarImageView, url: url,newWidth: CGFloat(),callback: self)
                }
            }
          
        }
    }

    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        saveButton.isEnabled = true
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        // Set photoImageView to display the selected image.
        imageChosen = ImageService.sharedInstance.resizeImage(selectedImage, newWidth: 400)
        avatarImageView.image = imageChosen
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: AnyObject) {
        
        UserService.sharedInstance.registerCallback(self).saveAvatar(imageChosen)
    }
    // Mark : AppServiceDeleage
    func serviceCallack(_ identifier: String, data: AnyObject?) {
        
        switch identifier {
        case "UserService.saveAvatar.Success":
            UserService.sharedInstance.registerCallback(homeTabBarController!).me()
            navigationController!.popViewController(animated: true)
            break
        default: break
        }
    }
    
    // Mark : ImageServiceDeleage
    func doAfterGetAsynchronously(_ img:UIImage?){
        avatarLoading.stopAnimating()
    }
}

