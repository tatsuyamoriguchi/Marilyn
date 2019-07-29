//
//  SOMDetailsViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 5/11/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit

class SOMDetailsViewController: UIViewController {

    var wordToSwipe: StateOfMind?
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var StateOfMindLabel: UILabel!
    @IBOutlet weak var StateOfMindRateLabel: UILabel!
    
    @IBOutlet weak var CauseDescLabel: UILabel!
    @IBOutlet weak var CauseTypeLabel: UILabel!
    @IBOutlet weak var TimeStampLabel: UILabel!
    @IBOutlet weak var LocationNameLabel: UILabel!
    @IBOutlet weak var LocationAddressLabel: UILabel!
    
    @IBOutlet weak var BackButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        popUpView.layer.cornerRadius = 20
        popUpView.layer.masksToBounds = true
        
        StateOfMindLabel.layer.masksToBounds = true
        StateOfMindLabel.layer.cornerRadius = 10
        StateOfMindRateLabel.layer.masksToBounds = true
        StateOfMindRateLabel.layer.cornerRadius = 10
        CauseDescLabel.layer.masksToBounds = true
        CauseDescLabel.layer.cornerRadius = 10
        CauseTypeLabel.layer.masksToBounds = true
        CauseTypeLabel.layer.cornerRadius = 10
        TimeStampLabel.layer.masksToBounds = true
        TimeStampLabel.layer.cornerRadius = 10
        LocationNameLabel.layer.masksToBounds = true
        LocationNameLabel.layer.cornerRadius = 10
        LocationAddressLabel.layer.masksToBounds = true
        LocationAddressLabel.layer.cornerRadius = 10
        
        
        
        StateOfMindLabel.text = wordToSwipe?.stateOfMindDesc?.adjective

        let rateString = String(wordToSwipe!.stateOfMindDesc!.rate)
        StateOfMindRateLabel.text = rateString

        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium //"yyyy-MM-dd HH:mm:ss"
        let timeStampString = formatter.string(from: (wordToSwipe?.timeStamp)!)
        TimeStampLabel.text = timeStampString
        print("++++++++++++++++")
        print(timeStampString)
        
        CauseDescLabel.text = wordToSwipe?.cause?.causeDesc
        CauseTypeLabel.text = wordToSwipe?.causeType?.type
        LocationNameLabel.text = wordToSwipe?.location?.locationName
        LocationAddressLabel.text = wordToSwipe?.location?.address
        
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
