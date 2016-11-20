//
//  MainMenuViewController.swift
//  GeoStudy
//
//  Created by Trevor Stevenson on 11/19/16.
//  Copyright © 2016 TStevensonApps. All rights reserved.
//

import UIKit
import Firebase

class MainMenuViewController: UIViewController {

    @IBOutlet weak var userIDLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                self.userIDLabel.text = user?.displayName
            }
            else
            {
                let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
                
                self.navigationController?.present(VC, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func signOut(_ sender: Any) {
        
        try! FIRAuth.auth()!.signOut()
        
        _ = self.navigationController?.popToRootViewController(animated: true)

    }
}
