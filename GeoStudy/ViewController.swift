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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

