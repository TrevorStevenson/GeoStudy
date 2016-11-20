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
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var manageScheduleButton: UIButton!
    
    
    var userID = ""
    var ref: FIRDatabaseReference?
    var classInfo: [String] = []
    var classes: [String] = []
    var buttons: [UIButton] = []
    var isLoginShowing: Bool = false
    var viewC: ViewController!
    var SVC: ScheduleViewController?
    var isFirst = true
    
    var locationManager = CLLocationManager()
    
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
        
        let buttonHeight = (self.view.frame.height - 280 - CGFloat(self.classes.count * 15)) / CGFloat(self.classes.count)
        
        for i in 0...self.classes.count - 1
        {
            let button = UIButton(frame: CGRect(x: 20, y: 180 + (CGFloat(i) * (buttonHeight + 10)), width: self.view.frame.width - 40, height: buttonHeight))
            
            button.setTitle(self.classes[i], for: .normal)
            button.titleLabel?.font = UIFont(name: "BebasNeue", size: 30)
            button.titleLabel?.textColor = UIColor.white
            button.backgroundColor = UIColor.darkGray
            button.layer.cornerRadius = 10.0
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(MainMenuViewController.selectSubject), for: .touchUpInside)
            
            self.view.addSubview(button)
            
            buttons.append(button)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        signOutButton.titleLabel!.font = UIFont(name: "BebasNeue", size: 25)
        manageScheduleButton.titleLabel!.font = UIFont(name: "BebasNeue", size: 25)
        instructionsLabel.font = UIFont(name: "BebasNeue", size: 60)
        instructionsLabel.text = "Please Wait"
        instructionsLabel.isHidden = false
        userIDLabel.font = UIFont(name: "BebasNeue", size: 30)
        
        self.SVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "schedule") as? ScheduleViewController
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil
            {
                // User is signed in.
                if self.isLoginShowing
                {
                    self.isLoginShowing = false
                    _ = self.viewC.navigationController?.popViewController(animated: true)
                }
                else
                {
                    self.userIDLabel.text = "Welcome " + (user?.displayName)!
                    
                    self.userID = user!.uid
                    self.SVC?.userID = self.userID
                    self.ref = FIRDatabase.database().reference()
                    
                    self.ref!.child("users").child(self.userID).child("classes").observe(.value, with: { (snapshot) in
                        
                        self.classInfo = []
                        self.classes = []

                        if snapshot.exists()
                        {
                            self.classInfo = []
                            self.classes = []
                            
                            for c in snapshot.children.allObjects as! [FIRDataSnapshot]
                            {
                                self.classInfo.append(c.key)
                                self.classes.append(c.value as! String)
                            }
                            
                            self.SVC!.classes = self.classes
                            self.SVC!.classInfo = self.classInfo
                            
                            if let table = self.SVC?.tableView
                            {
                                table.reloadData()
                            }
                        }
                        
                        if self.classes.count == 0
                        {
                            for button in self.buttons
                            {
                                button.removeFromSuperview()
                            }
                            self.buttons.removeAll()
                            
                            self.instructionsLabel.isHidden = false

                            if self.isFirst
                            {
                                self.isFirst = false
                            }
                            else
                            {
                                
                                self.instructionsLabel.text = "No Classes"
                            }
                        }
                        else
                        {
                            self.updateButtons()
                            self.instructionsLabel.isHidden = true
                        }
                    })
                }
            }
            else
            {
                self.viewC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! ViewController
                self.navigationController?.show(self.viewC, sender: nil)
            }
        }
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
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
        
        isLoginShowing = true
        
        try! FIRAuth.auth()!.signOut()

    }
    
    @IBAction func manageSchedules(_ sender: Any) {
        
        self.SVC!.VC = self
        
        self.navigationController?.show(self.SVC!, sender: nil)

    }
    
    func selectSubject()
    {
        
    }
}
