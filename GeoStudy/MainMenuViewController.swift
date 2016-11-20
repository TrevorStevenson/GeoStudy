//
//  MainMenuViewController.swift
//  GeoStudy
//
//  Created by Trevor Stevenson on 11/19/16.
//  Copyright © 2016 TStevensonApps. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class MainMenuViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var userIDLabel: UILabel!
    var userID = ""
    var ref: FIRDatabaseReference!
    var classInfo: [String] = []
    var classes: [String] = []
    var buttons: [UIButton] = []
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                self.userIDLabel.text = user?.displayName
                
                self.userID = user!.uid
                self.ref = FIRDatabase.database().reference()
                
                self.ref.child("users").child(self.userID).child("classes").observe(.value, with: { (snapshot) in
                    
                    if snapshot.exists()
                    {
                        
                        for c in snapshot.children.allObjects as! [FIRDataSnapshot]
                        {
                            
                            if !self.classes.contains(c.value as! String)
                            {
                                self.classInfo.append(c.key)
                                self.classes.append(c.value as! String)
                            }
                        }
                        
                    }
                    
                    if self.classes.count == 0
                    {
                        
                    }
                    else
                    {
                        self.updateButtons()
                    }
                    
                })
                
            }
            else
            {
                let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
                self.navigationController?.present(VC, animated: true, completion: nil)
            }
        }
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        self.ref.child("users").child(self.userID).child("classes").removeAllObservers()
        
    }
    
    func updateButtons()
    {
        if buttons.count > 0
        {
            for t in 0...buttons.count - 1
            {
                buttons[t].removeFromSuperview()
            }
            
            buttons.removeAll()
        }
        
        let buttonHeight = (self.view.frame.height - 100 - CGFloat(self.classes.count * 15)) / CGFloat(self.classes.count)
        
        for i in 0...self.classes.count - 1
        {
            let button = UIButton(frame: CGRect(x: 40, y: 60 + (CGFloat(i) * (buttonHeight + 15)), width: self.view.frame.width - 80, height: buttonHeight))
            
            button.setTitle(self.classes[i], for: .normal)
            
            self.view.addSubview(button)
                        
            buttons.append(button)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // 1. status is not determined
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            
            // 2. authorization were denied
        else if CLLocationManager.authorizationStatus() == .denied {
            let refreshAlert = UIAlertController(title: "Refresh", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
            // 3. we do have authorization
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
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
    @IBAction func signOut(_ sender: Any) {
        
        try! FIRAuth.auth()!.signOut()
        
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
        self.navigationController?.show(VC, sender: nil)
    }
    
    @IBAction func manageSchedules(_ sender: Any) {
        
        let SVC: ScheduleViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "schedule") as! ScheduleViewController
        
        SVC.VC = self
        
        self.navigationController?.show(SVC, sender: nil)

    }
}
