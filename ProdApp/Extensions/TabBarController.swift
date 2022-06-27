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
    var isEditable = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedIndex = 1
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.white
        
        tabBar.standardAppearance = tabBarAppearance

    }
}


