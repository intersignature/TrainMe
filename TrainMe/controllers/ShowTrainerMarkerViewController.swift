//
//  ShowTrainerMarkerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 11/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseAuth
import FirebaseDatabase

class ShowTrainerMarkerViewController: UIViewController {

    var ref: DatabaseReference!
    var currentUser: User?
    var placeId: String!
    var bookPlaceDict = [String: [BookPlaceDetail]]()
    var PlaceTrainerIdList = [String: [String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        currentUser = Auth.auth().currentUser

        getBookPlaceDict()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTrainerIdList() { // [placeId: [trainerId]]
        var tempTrainerId = [String]()
        
            tempTrainerId = []
            bookPlaceDict.forEach({ (trainerId, bookPlaceDetails) in
                
                bookPlaceDetails.forEach({ (bookPlaceDetail) in
                    
                    if placeId == bookPlaceDetail.placeId {
                        
                        if !tempTrainerId.contains(trainerId){
                            tempTrainerId.append(trainerId)
                        }
                    }
                })
            })
        PlaceTrainerIdList[placeId] = tempTrainerId
        PlaceTrainerIdList.forEach { (placeId, trainIds) in
            trainIds.forEach({ print($0) })
        }

    }

    func getBookPlaceDict() {
        
        ref.child("schedule_place_books").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String: [String: NSDictionary]]
            value?.forEach({ (key, eachValue) in
                var bookPlaceDetails = [BookPlaceDetail]()
                eachValue.forEach({ (bookPlaceKey, bookPlaceValue) in
                    let bookPlaceDetail = BookPlaceDetail(key: bookPlaceKey, placeId: bookPlaceValue["place_id"] as! String, startTrainDate: bookPlaceValue["start_train_date"] as! String, startTrainTime: bookPlaceValue["start_train_time"] as! String)
                    bookPlaceDetails.append(bookPlaceDetail)
                })
                self.bookPlaceDict[key] = bookPlaceDetails
            })
            self.getTrainerIdList()
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
