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
    var isLoginShowing = false
    weak var viewC: ViewController!
    weak var SVC: ScheduleViewController?
    var isFirst = true
    var displayName = ""
    
    lazy var scrollView = UIScrollView()
    let manager = CLLocationManager()

    func updateButtons()
    {
        if buttons.count > 0
        {
            for button in buttons { button.removeFromSuperview() }
            buttons.removeAll()
        }
        
        scrollView.contentSize = CGSize(width: self.view.frame.width - 40, height: CGFloat(self.classes.count) * 90)
        
        for (i, myClass) in classes.enumerated()
        {
            let button = UIButton(frame: CGRect(x: 0, y: (CGFloat(i) * 90), width: self.view.frame.width - 40, height: 80))
            
            button.setTitle(myClass, for: .normal)
            
            if let titleLabel = button.titleLabel { titleLabel.textColor = .white }
            button.setBackgroundImage(#imageLiteral(resourceName: "gsb2"), for: .normal)
            button.layer.cornerRadius = 10.0
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(MainMenuViewController.selectSubject), for: .touchUpInside)
            
            scrollView.addSubview(button)
            buttons.append(button)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        
        manager.requestAlwaysAuthorization()
        
        instructionsLabel.text = "Please Wait"
        instructionsLabel.isHidden = false
        
        scrollView = UIScrollView(frame: CGRect(x: 20, y: whatLabel.frame.origin.y + whatLabel.frame.height + 20, width: self.view.frame.width-40, height: self.view.frame.height-245))
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.contentSize = self.scrollView.frame.size
        view.addSubview(self.scrollView)
        
        SVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "schedule") as? ScheduleViewController
        
        guard let auth = FIRAuth.auth() else { return }
        
        auth.addStateDidChangeListener { auth, optionalUser in
            
            if let user = optionalUser
            {
                // User is signed in.
                
                if let name = user.displayName { self.displayName = name }
                self.userIDLabel.text = self.displayName
                
                self.userID = user.uid
                self.SVC?.userID = self.userID
                self.ref = FIRDatabase.database().reference()
                
                if self.isLoginShowing
                {
                    self.isLoginShowing = false
                    self.viewC.navigationController?.popViewController(animated: true)
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
                        
                        if let table = self.SVC?.tableView { table.reloadData() }
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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        
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
