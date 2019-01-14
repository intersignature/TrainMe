//
//  HelpTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HelpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var helpTableView: UITableView!
    
    var ref: DatabaseReference!
    var currentUser: User!
    var userRole: String!
    var helpArr: [Help] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.helpTableView.delegate = self
        self.helpTableView.dataSource = self
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.getRole()
    }
    
    func setupHelpData() {
        
        if userRole == "trainer" {
            let help1 = Help(topic: "a", desc: "", imageSource: nil)
            let help2 = Help(topic: "b", desc: "", imageSource: nil)
            self.helpArr.append(help1)
            self.helpArr.append(help2)
        } else if userRole == "trainee" {
            let help1 = Help(topic: "c", desc: "", imageSource: nil)
            let help2 = Help(topic: "d", desc: "", imageSource: nil)
            self.helpArr.append(help1)
            self.helpArr.append(help2)
            self.helpArr.append(help2)
            self.helpArr.append(help2)
        }
        self.helpTableView.reloadData()
    }
    
    func getRole() {
        
        self.ref.child("user").child(self.currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let values = snapshot.value as? NSDictionary
            self.userRole = values!["role"] as? String
            print(self.userRole)
            self.setupHelpData()
        }) { (err) in
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            print(err.localizedDescription)
            return
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.helpArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTableViewCell") as! HelpTableViewCell
        cell.topicHelp.text = self.helpArr[indexPath.row].topic
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(helpArr[indexPath.row].getData())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
