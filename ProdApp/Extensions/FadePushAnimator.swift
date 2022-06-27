//
//  FadePushAnimator.swift
//  ProdApp
//
//  Created by Permindar LvL on 04/09/2021.
//

import Foundation
import UIKit

class MySubclassedTabBarController: UITabBarController {
    
    var selectedWeek: Week?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Moves to correct index
        self.selectedIndex = 1
    }

}
