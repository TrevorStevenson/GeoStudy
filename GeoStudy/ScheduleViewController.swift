//
//  ScheduleViewController.swift
//  GeoStudy
//
//  Created by Trevor Stevenson on 11/19/16.
//  Copyright © 2016 TStevensonApps. All rights reserved.
//

import UIKit
import Firebase

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var userID = ""
    var ref: FIRDatabaseReference!
    var classInfo: [String] = []
    var classes: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil
            {
                // User is signed in.
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
                    print("test")
                    self.tableView.reloadData()
                    
                })
            }
        
        }

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return classes.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ClassCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! ClassCell
        
        cell.classLabel.text = classes[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let deleteAlert = UIAlertController(title: "Delete", message: "Would you like to delete this class?", preferredStyle: .alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            self.ref.child("users").child(self.userID).child("classes").child(self.classInfo[indexPath.row]).removeValue()
            self.classInfo.remove(at: indexPath.row)
            self.classes.remove(at: indexPath.row)
            
            self.tableView.reloadData()
            
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func addClass(_ sender: Any) {
        
        let alert = UIAlertController(title: "Enter class name", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in }
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            let className = alert.textFields![0].text
            
            let key = self.ref.child("users").child(self.userID).child("classes").childByAutoId().key
            
            self.ref.updateChildValues(["/users/\(self.userID)/classes/\(key)" : className!])
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

}
