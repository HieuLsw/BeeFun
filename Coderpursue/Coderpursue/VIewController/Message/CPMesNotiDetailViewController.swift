//
//  CPMesNotiDetailViewController.swift
//  Coderpursue
//
//  Created by WengHengcong on 3/15/16.
//  Copyright © 2016 JungleSong. All rights reserved.
//

import UIKit

class CPMesNotiDetailViewController: CPBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override func leftItemAction(sender: UIButton?) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
