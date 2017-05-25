//
//  ClassViewController.swift
//  GeoStudy
//
//  Created by Trevor Stevenson on 11/20/16.
//  Copyright © 2016 TStevensonApps. All rights reserved.
//

import UIKit
import Firebase

class ClassViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var ref: FIRDatabaseReference?
    
    var names: [String] = []
    var userID = ""
    var name = ""
    var myKey = ""
    var displayName = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        classNameLabel.font = UIFont(name: "OpenSans-Regular", size: 32)
        classNameLabel.text = self.name
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil
            {
                self.ref = FIRDatabase.database().reference()
                self.userID = user!.uid
                self.displayName = user!.displayName!
                
                self.ref!.child(self.name).observe(.value, with: { (snapshot) in
                        
                    if snapshot.exists()
                    {
                        self.names = []
                        
                        for c in snapshot.children.allObjects as! [FIRDataSnapshot]
                        {
                            self.names.append(c.value as! String)
                        }
                        
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.ref?.updateChildValues(["/\(self.name)/\(self.myKey)" : self.displayName])
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.ref?.child(self.name).child(self.myKey).removeValue()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : StudyCell = self.tableView.dequeueReusableCell(withIdentifier: "cell2") as! StudyCell
        
        cell.nameLabel.text = names[indexPath.row]
        
        return cell
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }

}
