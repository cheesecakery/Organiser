//
//  durationViewController.swift
//  Organiser
//
//  Created by Permindar LvL on 18/01/2022.
//

import UIKit

class durationViewController: UIViewController {


    @IBOutlet var popupView: UIView!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var noDurationButton: UIButton!
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var durationPicker: UIDatePicker!
    
    var callbackClosure: (() -> Void)?
    
    var goal: Goal!
    
    var selectedWeek: Week?
    var selectedPopUpPosition: Int?
    
    var background: UIColor?
    var highlight: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.isOpaque = false
        
        popupView.layer.cornerRadius = 10
        
        popupView.backgroundColor = background
        titleText.textColor = highlight
        selectButton.tintColor = highlight
        noDurationButton.tintColor = highlight
        durationPicker.setValue(highlight, forKeyPath: "textColor")
    }
    
    @IBAction func pickNoDuration(_ sender: UIButton) {
        goal.duration = 0
        callbackClosure?()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectDuration(_ sender: UIButton) {
        goal?.duration = Int64(durationPicker.countDownDuration / 60)
        callbackClosure?()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func dismissPopup(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
