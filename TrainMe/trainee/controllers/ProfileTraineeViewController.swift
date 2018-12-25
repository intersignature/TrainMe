//
//  ProfileTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 20/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ProfileTraineeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var headerView: UILabel!
    @IBOutlet weak var reviewProfileTraineeTableView: UITableView!
    var traineeUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ProfileTraineeViewController \(String(describing: self.traineeUid))")
        
        self.navigationController?.isNavigationBarHidden = true
        self.reviewProfileTraineeTableView.delegate = self
        self.reviewProfileTraineeTableView.dataSource = self
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewProfileTraineeTableViewCell") as! ReviewProfileTraineeTableViewCell
        return cell
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        print(offset)
        
        if offset <= 170.0 {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
}
