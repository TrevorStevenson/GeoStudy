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

    @IBOutlet weak var addClassButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var userID = ""
    var ref: FIRDatabaseReference!
    var classInfo: [String] = []
    var classes: [String] = []
    var VC = MainMenuViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        titleLabel.font = UIFont(name: "BebasNeue", size: 30)
        addClassButton.titleLabel!.font = UIFont(name: "BebasNeue", size: 25)
        
        //let waitAlert = UIAlertController(title: "Please Wait", message: nil, preferredStyle: .alert)
        //present(waitAlert, animated: true, completion: nil)
        self.ref = FIRDatabase.database().reference()

        self.tableView.reloadData()
        
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
            print("delete")
            self.ref.child("users").child(self.userID).child("classes").child(self.classInfo[indexPath.row]).removeValue()
            self.classInfo.remove(at: indexPath.row)
            self.classes.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.none)
            //let indx = IndexSet(integer: indexPath.section)
            //self.tableView.deleteSections(indx, with: .none)
            
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
            
            self.tableView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }

}
