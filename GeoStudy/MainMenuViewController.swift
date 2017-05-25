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

class MainMenuViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var manageScheduleButton: UIButton!
    @IBOutlet weak var whatLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var userID = ""
    var ref: FIRDatabaseReference?
    var classInfo: [String] = []
    var classes: [String] = []
    var buttons: [UIButton] = []
    var isLoginShowing: Bool = false
    var viewC: ViewController!
    var SVC: ScheduleViewController?
    var isFirst = true
    var displayName = ""
    
    var scrollView = UIScrollView()
    
    let manager = CLLocationManager()
    
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
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width-40, height: CGFloat(self.classes.count)*90)
        
        for i in 0...self.classes.count - 1
        {
            let button = UIButton(frame: CGRect(x: 0, y: (CGFloat(i) * 90), width: self.view.frame.width - 40, height: 80))
            
            button.setTitle(self.classes[i], for: .normal)
            button.titleLabel?.textColor = UIColor.white
            button.setBackgroundImage(#imageLiteral(resourceName: "gsb2"), for: .normal)
            button.layer.cornerRadius = 10.0
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(MainMenuViewController.selectSubject), for: .touchUpInside)
            
            self.scrollView.addSubview(button)
            
            buttons.append(button)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        if CLLocationManager.authorizationStatus() == .notDetermined
        {
            manager.requestWhenInUseAuthorization()
        }
        
        instructionsLabel.text = "Please Wait"
        instructionsLabel.isHidden = false
        
        self.scrollView = UIScrollView(frame: CGRect(x: 20, y: whatLabel.frame.origin.y + whatLabel.frame.height + 20, width: self.view.frame.width-40, height: self.view.frame.height-245))
        self.scrollView.delegate = self
        self.scrollView.isScrollEnabled = true
        self.scrollView.contentSize = self.scrollView.frame.size
        self.view.addSubview(self.scrollView)
        
        //self.manageScheduleButton.contentHorizontalAlignment = .left
        
        self.SVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "schedule") as? ScheduleViewController
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil
            {
                // User is signed in.
                
                self.displayName = user!.displayName!
                self.userIDLabel.text = self.displayName
                
                self.userID = user!.uid
                self.SVC?.userID = self.userID
                self.ref = FIRDatabase.database().reference()
                
                if self.isLoginShowing
                {
                    self.isLoginShowing = false
                    _ = self.viewC.navigationController?.popViewController(animated: true)
                    self.ref!.child("users").child(self.userID).child("username").setValue(self.displayName)
                }
                
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
            else
            {
                self.viewC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! ViewController
                self.navigationController?.show(self.viewC, sender: nil)
                
                self.isLoginShowing = true
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse
        {
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
        if visit.departureDate == NSDate.distantFuture
        {
            
        }
    }
    @IBAction func signOut(_ sender: Any) {
        
        isLoginShowing = true
        
        try! FIRAuth.auth()!.signOut()

    }
    
    @IBAction func manageSchedules(_ sender: Any) {
        
        self.SVC!.VC = self
        
        self.navigationController?.show(self.SVC!, sender: nil)

    }
    
    func selectSubject(sender: UIButton)
    {
        if let name = sender.titleLabel?.text
        {
            let key = self.ref!.child(name).childByAutoId().key
                                    
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chat") as! ChatViewController
            controller.className = name
            controller.myKey = key
            
            self.navigationController?.show(controller, sender: nil)
        }
        
    }
}
