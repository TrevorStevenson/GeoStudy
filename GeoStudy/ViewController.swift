//
//  ViewController.swift
//  GeoStudy
//
//  Created by Trevor Stevenson on 11/19/16.
//  Copyright © 2016 TStevensonApps. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.isNavigationBarHidden = true
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                self.dismiss(animated: true, completion: nil)
            } 
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        //GIDSignIn.sharedInstance().signInSilently()
        
        let signInButton = GIDSignInButton()
        signInButton.frame.origin.x = self.view.frame.width/2 - signInButton.frame.width/2
        signInButton.frame.origin.y = self.view.frame.height/2 - signInButton.frame.height/2
        self.view.addSubview(signInButton)
        
    }

    @IBAction func signOut(_ sender: Any) {
        
        let alert = UIAlertController(title: "Sign Out", message: "Would you like to completely sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            GIDSignIn.sharedInstance().signOut()

        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }

}

