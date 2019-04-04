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
            let help1 = Help(topic: "help1_topic_trainee".localized(), desc: "help1_trainee".localized(), imageSource: nil)
            self.helpArr.append(help1)
        } else if userRole == "trainee" {
            let help1 = Help(topic: "help1_topic_trainee".localized(), desc: "help1_trainee".localized(), imageSource: nil)
            self.helpArr.append(help1)
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
        
        performSegue(withIdentifier: "HelpToViewHelp", sender: self.helpArr[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "HelpToViewHelp") {
            
            guard let selectedHelp = sender as? Help else { return }
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ViewHelpViewController
            containVc.selectedHelp = selectedHelp
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.setupNavigationStyle()

        self.title = "help".localized()
        
        self.helpTableView.tableFooterView = UIView()

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
