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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.helpTv.scrollRangeToVisible(NSRange(location:0, length:0))
        self.helpTv.text = self.selectedHelp.desc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.setupNavigationStyle()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        self.helpTv.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        self.helpTv.layer.cornerRadius = 5
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
