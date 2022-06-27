//
//  context.swift
//  ProductivityApp
//
//  Created by Permindar LvL on 19/08/2021.
//

import UIKit
import CoreData

//Saves all core data to users PHONE
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

var days: [Day]?
var weeks: [Week]?

let defaults = UserDefaults.standard
