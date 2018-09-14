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

class ShowTrainerMarkerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var showTrainerTableView: UITableView!
    var ref: DatabaseReference!
    var currentUser: User?
    var placeId: String!
    var bookPlaceDict = [String: [BookPlaceDetail]]()
    var PlaceTrainerIdList = [String: [String]]()
    var trainerProfiles = [UserProfile]()
    var selectedTrainerId: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        currentUser = Auth.auth().currentUser
        
        getBookPlaceDict()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (PlaceTrainerIdList[placeId]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainerSelected") as! TrainerSelectedTableViewCell
        cell.setDataToCell(trainerProfile: trainerProfiles.reversed()[indexPath.row])
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
//        var i = tempTrainerId[0]
//        PlaceTrainerIdList.forEach { (placeId, trainerIds) in
//            trainerIds.forEach({ print($0) })
//        }
        
        getTrainerInfo()
        
        
    }
    
    func getTrainerInfo() {
        var trainerProfile = UserProfile()
        PlaceTrainerIdList.forEach { (placeId, trainerIds) in
            trainerIds.forEach({ (trainerId) in
                //TODO: get trainer info by trainerId in database

                ref.child("user").child(trainerId).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
//                    print(value!["name"])
                    trainerProfile.fullName = value!["name"] as! String
                    trainerProfile.email = value!["email"] as! String
                    trainerProfile.dateOfBirth = value!["dateOfBirth"] as! String
                    trainerProfile.weight = value!["weight"] as! String
                    trainerProfile.height = value!["height"] as! String
                    trainerProfile.gender = value!["gender"] as! String
                    trainerProfile.role = value!["role"] as! String
                    trainerProfile.profileImageUrl = value!["profileImageUrl"] as! String
                    self.trainerProfiles.append(trainerProfile)
                    if self.trainerProfiles.count == self.PlaceTrainerIdList[placeId]?.count {
                        self.showTrainerTableView.delegate = self
                        self.showTrainerTableView.dataSource = self
                        self.showTrainerTableView.reloadData()
                    }
                }, withCancel: { (err) in
                    print(err.localizedDescription)
                    self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                    return
                })
                
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedTrainerId = PlaceTrainerIdList[placeId]!.reversed()[indexPath.row]
        print(indexPath.row)
        print(PlaceTrainerIdList[placeId]!.reversed()[indexPath.row])
        performSegue(withIdentifier: "ShowTrainerMarkerToShowCourseTrainerSpecified", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //ShowCourseTrainerSpecifiedViewController
        if(segue.identifier == "ShowTrainerMarkerToShowCourseTrainerSpecified") {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ShowCourseTrainerSpecifiedViewController
            containVc.trainerId = self.selectedTrainerId
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
