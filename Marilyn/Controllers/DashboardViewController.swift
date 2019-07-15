//
//  DashboardViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 4/18/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit

class DashbardViewController: UIViewController {

    @IBOutlet weak var marilynImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        marilynImage.layer.cornerRadius = 20
        marilynImage.layer.masksToBounds = true
    }


}

