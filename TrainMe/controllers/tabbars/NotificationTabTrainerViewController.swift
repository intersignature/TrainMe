//
//  NotificationTabTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 26/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import SWRevealViewController

class NotificationTabTrainerViewController: UIViewController {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSideMenu()
        self.title = NSLocalizedString("notification", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationStyle()
    }
    
    func initSideMenu() {
        
        if revealViewController() != nil {
            revealViewController().rearViewRevealWidth = 275
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            menuBtn.target = revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
