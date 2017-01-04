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
    var username = ""
    
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
        self.scrollField = UIScrollView(frame: CGRect(x: 0, y: 75, width: self.view.frame.width, height: self.view.frame.height - 113))
        self.scrollField.delegate = self
        self.scrollField.isScrollEnabled = true
        self.scrollField.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - 98)
        self.view.addSubview(self.scrollField)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTap))
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        self.textField.delegate = self
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil
            {
                // User is signed in.
                self.userID = user!.uid
                self.ref = FIRDatabase.database().reference()
                self.username = user!.displayName!
                self.ref!.child(self.className).child("messages").observe(.value, with: { (snapshot) in
                    
                    if snapshot.exists()
                    {
                        self.messages = []
                        for sub in self.scrollField.subviews
                        {
                            sub.removeFromSuperview()
                        }
                        self.currentY = 0
                        for c in snapshot.children.allObjects as! [FIRDataSnapshot]
                        {
                            self.messages.append(c.value as! String)
                            self.messageInfo.append(c.key)
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

    func screenTap()
    {
        if (textField.isEditing == true)
        {
            textField.endEditing(true)
        }
    }
    
    func displayMessage(message: String)
    {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
        messageLabel.text = self.username
        messageLabel.font = UIFont(name: "OpenSans-Regular", size: 4.0)
        messageLabel.textColor = UIColor.white
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        let textLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 0, height: 40))
        textLabel.text = message
        textLabel.font = UIFont(name: "OpenSans-Regular", size: 20)
        textLabel.textColor = UIColor.black
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.frame.size.width = self.view.frame.width - 40
        textLabel.sizeToFit()

        let messageView = UIView(frame: CGRect(x: 20, y: currentY, width: Int(self.view.frame.width - 40), height: Int(messageLabel.frame.height + textLabel.frame.height + 20)))
        messageView.addSubview(messageLabel)
        
        let bubble = UIView()
        bubble.frame = CGRect(x: 0, y: messageLabel.frame.height + 2, width: textLabel.frame.width + 20, height: textLabel.frame.height + 20)
        bubble.backgroundColor = UIColor.white
        bubble.layer.borderColor = UIColor.black.cgColor
        bubble.layer.cornerRadius = 10
        bubble.layer.borderWidth = 2
        messageView.addSubview(bubble)
        
        bubble.addSubview(textLabel)
        
        currentY += Int(messageView.frame.height) + 20

        self.scrollField.contentSize = CGSize(width: self.view.frame.width, height: CGFloat(currentY))
        let bottom = CGPoint(x: 0, y: self.scrollField.contentSize.height-self.scrollField.frame.height)
        self.scrollField.setContentOffset(bottom, animated: false)
        
        self.scrollField.addSubview(messageView)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.resignFirstResponder()
        
        animateViewMoving(up: false, moveValue: CGFloat(self.keyHeight))

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
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
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // Lifting the view up
    func animateViewMoving (up:Bool, moveValue :CGFloat)
    {
        let movement: CGFloat = (up ? -moveValue : moveValue)
        let movementDuration: TimeInterval = ( up ? 0.3 : 0.3)

        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    @IBAction func back(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }

}
