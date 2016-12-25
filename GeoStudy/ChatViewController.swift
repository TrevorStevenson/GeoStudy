//
//  ChatViewController.swift
//  GeoStudy
//
//  Created by Trevor Stevenson on 11/25/16.
//  Copyright © 2016 TStevensonApps. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    var userID = ""
    var ref: FIRDatabaseReference?
    var className = ""
    
    var currentY = 40
    
    var messages: [String] = []
    var messageInfo: [String] = []
    var myKey = ""
    var scrollField = UIScrollView()
    
    var keyHeight = 400
    
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.scrollField = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 38))
        self.scrollField.delegate = self
        self.scrollField.isScrollEnabled = true
        self.scrollField.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - 38)
        self.view.addSubview(self.scrollField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        self.textField.delegate = self
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil
            {
                // User is signed in.
                self.userID = user!.uid
                self.ref = FIRDatabase.database().reference()
                
                self.ref!.child(self.className).child("messages").observe(.value, with: { (snapshot) in
                    
                    if snapshot.exists()
                    {
                        self.messages = []
                        for sub in self.scrollField.subviews
                        {
                            sub.removeFromSuperview()
                        }
                        for c in snapshot.children.allObjects as! [FIRDataSnapshot]
                        {
                            self.messages.append(c.value as! String)
                            self.displayMessage(message: c.value as! String)
                        }
                    }
                    
                })
                
            }
            else
            {
                
            }
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.ref?.child(self.className).child(self.myKey).removeValue()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyHeight = Int(keyboardSize.height)
        }
        
        animateViewMoving(up: true, moveValue: CGFloat(self.keyHeight))
    }

    func displayMessage(message: String)
    {
        self.scrollField.contentSize = CGSize(width: self.view.frame.width, height: CGFloat(messages.count * 80))
        
        let messageView = UIView(frame: CGRect(x: 20, y: currentY, width: Int(self.view.frame.width - 40), height: 60))
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "OpenSans-Regular", size: 20)
        messageLabel.textColor = UIColor.white
        messageView.addSubview(messageLabel)
        
        self.scrollField.addSubview(messageView)
        
        currentY += 80
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        animateViewMoving(up: false, moveValue: CGFloat(self.keyHeight))
        
        let key = self.ref?.child(self.className).child("messages").childByAutoId().key
        
        self.ref?.updateChildValues(["/\(self.className)/messages/\(key!)" : textField.text!])
        
        messageInfo.append(key!)
        textField.text = ""
        
        if (messages.count >= 100)
        {
            self.ref?.child(self.className).child("messages").child(messageInfo[0]).removeValue()
            self.messages.removeFirst()
            self.messageInfo.removeFirst()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    // Lifting the view up
    func animateViewMoving (up:Bool, moveValue :CGFloat)
    {
        let movement: CGFloat = ( up ? -moveValue : moveValue)
        let movementDuration: TimeInterval = ( up ? 0.2 : 0.1)

        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }

}
