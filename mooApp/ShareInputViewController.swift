//
//  ShareInputViewController.swift
//  mooApp
//
//  Created by tuan on 6/21/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import UIKit

// protocol used for sending data back
protocol ShareInputDataDelegate: class {
    func getText(text : String)
}

class ShareInputViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var selectItemTextView: UITextView!
    weak var delegate: ShareInputDataDelegate? = nil
    var emailText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectItemTextView.delegate = self
        //self.selectItemTextView.textContainerInset = UIEdgeInsets.zero;
        //self.selectItemTextView.textContainer.lineFragmentPadding = 0;
        self.automaticallyAdjustsScrollViewInsets = false
        
        if emailText == ""{
            self.selectItemTextView.textColor = UIColor.lightGray
            self.selectItemTextView.text = NSLocalizedString("post_feeds_select_email_placeholder",comment:"post_feeds_select_email_placeholder")
        }
        else{
            self.selectItemTextView.text = self.emailText
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.self.selectItemTextView.layoutIfNeeded()
        if self.selectItemTextView.textColor == UIColor.lightGray {
            self.selectItemTextView.text = nil
            self.selectItemTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.selectItemTextView.text.isEmpty {
            self.selectItemTextView.text = NSLocalizedString("post_feeds_select_email_placeholder",comment:"post_feeds_select_email_placeholder")
            self.selectItemTextView.textColor = UIColor.lightGray
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.getText(text: self.selectItemTextView.text)
    }
}
