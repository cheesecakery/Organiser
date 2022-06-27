//
//  productivityPopUpViewController.swift
//  ProdApp
//
//  Created by Permindar LvL on 25/12/2021.
//

import UIKit

class productivityPopUpViewController: UIViewController {
    
    var ifSaved: (() -> Void)?
    var showTabBar: (() -> Void)?
    
    var selectedPopUpPosition: Int?
    var selectedDay: Day?
    var activity: Activity!
    
    @IBOutlet var popupView: UIView!
    @IBOutlet var popupTitle: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var doesntMatterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.isOpaque = false
        
        //Create a dismiss button
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        button.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        view.addSubview(button)
        view.sendSubviewToBack(button)
        
        //Set the view's colour scheme to match that of the cell
        var background: UIColor?
        var highlight: UIColor?
        
        if activity.goal != nil {
            background = activity.goal?.backgroundColour
            highlight = activity.goal?.highlightColour
        } else if activity.background != nil {
            background = activity.background
            highlight = activity.highlight
        } else {
            background = UIColor(named: "Default1")
            highlight = UIColor(named: "Default2")
        }
            
        popupView.backgroundColor = background
        popupTitle.textColor = highlight
        doesntMatterButton.setTitleColor(highlight, for: .normal)
        buttons.forEach { $0.tintColor = highlight }
    }

    //Assign how productive the activity was and save information
    @IBAction func selectNumber(_ sender: UIButton) {
        activity.productivity = "\(sender.tag)"
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        ifSaved?()
        showTabBar?()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doesntMatter(_ sender: UIButton) {
        ifSaved?()
        showTabBar?()
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func dismissPopup() {
        showTabBar?()
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
