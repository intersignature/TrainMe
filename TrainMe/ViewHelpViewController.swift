//
//  ViewHelpViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 15/1/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import UIKit

class ViewHelpViewController: UIViewController {

    @IBOutlet weak var helpTv: UITextView!
    
    var selectedHelp: Help!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.selectedHelp.topic
        self.helpTv.text = self.selectedHelp.desc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
