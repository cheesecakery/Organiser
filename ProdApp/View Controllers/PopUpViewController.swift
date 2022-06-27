//
//  PopUpViewController.swift
//  ProductivityApp
//
//  Created by Permindar LvL on 18/08/2021.
//

import UIKit
import CoreData

class PopUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //callback to VC - changes to be made to that view
    var callbackClosure: (() -> Void)?
    var showTabBar: (() -> Void)?
    var getDesign: (() -> Void)?
    
    //parameters to change what is shown/whether it can be edited
    var isCompleted = false
    var isEditable = true

    //Correct week & day to save new activities to
    var selectedWeek: Week?
    var selectedDay: Day?
    
    //Trickery with tags/goals
    var firstPickerView = true
    var showGoals = false
    var tagsToBeShuffled = false
    
    var shuffledTags = [Tag]()
    
    //Set up for the whole screen design / info - everytime activity is updated this is as well
    var activity: Activity! {
        didSet {
            //Info of cell
            if let icon = activity?.icon {
                ActivityIconPopUp?.setTitle(icon, for: .normal)
                let icon = UIView(SVGNamed: icon)
                ActivityIcon?.subviews.forEach({ $0.removeFromSuperview() })
                ActivityIcon?.addSubview(icon)
            } else {
                ActivityIconPopUp?.setTitle("", for: .normal)
            }
            
            ActivityTitle?.text = activity?.name
            datePicker?.date = activity.time ?? Date()
            durationText?.text = " \((Int(activity.duration)).timeToString()) "
            timerSlider?.value = Float(activity.duration)
            
            var highlight: UIColor?
            var background: UIColor?
            
            if activity.goal != nil {
                tagsText?.text = "Goal"
                tagsField?.text = activity.goal?.name
                background = activity.goal?.backgroundColour
                highlight = activity.goal?.highlightColour
            } else if activity.type != nil {
                tagsField?.text = activity.type
                tagsText?.text = "Tag"
                background = activity.background
                highlight = activity.highlight
            } else {
                tagsField?.text = tags[0].activityType
                background = UIColor(named: "Default1")
                highlight = UIColor(named: "Default2")
            }
            
            //Design of cell
            popUpView?.backgroundColor = background
            ActivityTitle?.textColor = background?.darker(by: 20)
            durationText?.textColor = background

            ActivityIconEmpty?.backgroundColor = highlight
            ActivityTitle?.backgroundColor = highlight
            
            durationText?.backgroundColor = highlight
            timerSlider?.minimumTrackTintColor = highlight
            tagsText?.textColor = highlight
            tagsField?.backgroundColor = highlight
            tagsField?.textColor = background
        }
    }
    
    //Activity Icon set up
    @IBOutlet var ActivityIcon: UIView!
    @IBOutlet var ActivityIconPopUp: UIButton!
    @IBOutlet var ActivityIconEmpty: UIView! {
        didSet {
            ActivityIconEmpty.layer.cornerRadius = ActivityIconEmpty.frame.size.width / 2
            ActivityIconEmpty.layer.masksToBounds = false
            ActivityIconEmpty.clipsToBounds = true
        }
    }
    
    @IBOutlet var ActivityTitle: UITextField! {
        didSet {
            ActivityTitle.delegate = self
        }
    }
    
    @IBOutlet var datePicker: UIDatePicker!
   
    //Making the time picker + date picker.
    @IBOutlet var timerSlider: UISlider!
    @IBOutlet var durationText: UITextField! {
        didSet {
            durationText.inputView = timePicker
        }
    }

    @IBOutlet var tagsField: UITextField!
    @IBOutlet var tagsText: UILabel!
    @IBOutlet var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //makes sure it is presented over context
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.isOpaque = false
        
        //designs layout for tags
        makePickerViews()
        
        //always make time wheely
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.minuteInterval = 5
        
        //times for time slider
        timerSlider.minimumValue = 0
        timerSlider.maximumValue = 1440.0
        
        shuffledTags = tags
        
        activity = { activity }()

        if isCompleted == true || isEditable == false {
            ActivityIconPopUp.isUserInteractionEnabled = false
            ActivityTitle.isUserInteractionEnabled = false
            datePicker.isUserInteractionEnabled = false
            timerSlider.isUserInteractionEnabled = false
            tagsField.isUserInteractionEnabled = false
        }
    }
    
    //MARK: - ICONS IMPLEMENTATION
    @IBAction func iconsPopUp(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "IconsViewController") as? IconsViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            activity.name = ActivityTitle.text
            activity.time = datePicker.date
            
            if let activity = activity {
                vc.activity = activity
            }
            
            vc.selectedDay = selectedDay
            
            vc.callbackClosure = { [weak self] in
                self?.activity = { self?.activity }()
                //self?.callbackClosure?()
            }
            
            present(vc, animated: true)
        }
    }
    
    // MARK: - ACTIVITY TITLE IMPLEMENTATION
    //Max. word count for activity's name is 50 chars
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 30
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ActivityTitle.resignFirstResponder()
        activity.name = ActivityTitle.text
        return true
    }
    
    // MARK: - PICKER VIEWS
    func makePickerViews() {
        durationText.inputView = timePicker
        durationText.inputAccessoryView = toolbar2
        
        tagsField.inputView = picker
        
        picker.delegate = self
        picker.dataSource = self
        
        tagsField.inputAccessoryView = toolbar1
    }

    // MARK: - DURATION IMPLEMENTATION
    //making the picker for the date
    var timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .countDownTimer
        timePicker.minuteInterval = 5
        
        return timePicker
    }()
    //Toolbar for the time picker
    let toolbar2: UIToolbar = {
        let toolbar = UIToolbar()
        
        let zero = UIButton()
        zero.setImage(UIImage(systemName: "0.circle.fill"), for: .normal)
        zero.addTarget(self, action: #selector(selectNoTime), for: .touchUpInside)
        let zeroButton = UIBarButtonItem(customView: zero)
        
        let select = UIButton()
        select.setImage(UIImage(systemName: "checkmark"), for: .normal)
        select.addTarget(self, action: #selector(selectTime), for: .touchUpInside)
        let selectButton = UIBarButtonItem(customView: select)
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 10
        
        toolbar.frame = CGRect(x: 0, y: 0, width: 100.0, height: 44.0)
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.isUserInteractionEnabled = true
        toolbar.setItems([space, zeroButton, fixedSpace, selectButton], animated: false)
        return toolbar
    }()
    
    //tracks slider changes so that label is moved.
    @IBAction func sliderChanged(_ sender: UISlider) {
        durationText.endEditing(true)
        let timer = Int(timerSlider.value).roundedDown(toMultipleOf: 5)
        durationText.text = " \(timer.timeToString()) "
        activity.duration = Int64(timer)
    }
    
    @objc func selectTime() {
        activity.time = datePicker.date
        
        if (timePicker.countDownDuration / 60) == 1.0 {
            activity.duration = 5
        } else {
            activity.duration = Int64(round(timePicker.countDownDuration / 60))
        }
        activity = { activity }()
        durationText.endEditing(true)
    }
    
    @objc func selectNoTime() {
        activity.duration = 0
        activity = { activity }()
        durationText.endEditing(true)
    }

    // MARK: - PICKER VIEW IMPLEMENTATION
    //making the picker for the tags/goals
    var picker = UIPickerView()
    
    //Toolbar for the goal/tag picker
    let toolbar1: UIToolbar = {
        let toolbar = UIToolbar()
        let select = UIButton()
        select.setImage(UIImage(systemName: "checkmark"), for: .normal)
        select.addTarget(self, action: #selector(selectTag), for: .touchUpInside)
        let selectButton = UIBarButtonItem(customView: select)
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let shuffle = UIButton()
        shuffle.setImage(UIImage(systemName: "shuffle"), for: .normal)
        shuffle.addTarget(self, action: #selector(shuffleTags), for: .touchUpInside)
        let shuffleButton = UIBarButtonItem(customView: shuffle)
        
        toolbar.frame = CGRect(x: 0, y: 0, width: 100.0, height: 44.0)
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.isUserInteractionEnabled = true
        toolbar.setItems([shuffleButton, space, selectButton], animated: false)
        
        return toolbar
    }()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Number of rows in picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if firstPickerView {
            if selectedWeek?.goals?.count == 0 {
                return 1
            } else {
                return 2
            }
        } else {
            if showGoals {
                return selectedWeek?.goals?.count ?? 0
            } else {
                return tags.count
            }
        }
    }
    
    //User decides whether they want to pick a 'Goal' attribute or a 'Tag'.
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if firstPickerView {
            if row == 0 {
                return NSAttributedString(string: "Tags", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black as Any])
            } else {
                return NSAttributedString(string: "Goals", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black as Any])
            }
        } else {
            if showGoals {
                let goals = selectedWeek?.goals?.sortedArray(using: [NSSortDescriptor(key: "timeCreated", ascending: true)]) as? [Goal]
                guard let name = goals?[row].name else { fatalError("couldn't find goals") }
                return NSAttributedString(string: name, attributes: [NSAttributedString.Key.foregroundColor: goals?[row].backgroundColour?.darker(by: 30) as Any])
            } else {

                if tagsToBeShuffled {
                    tagsToBeShuffled = false
                    shuffledTags = tags.shuffled()
                }
                
                return NSAttributedString(string: shuffledTags[row].activityType, attributes: [NSAttributedString.Key.foregroundColor: shuffledTags[row].highlight?.darker(by: 30) as Any])
            }
        }
    }
    
    //Allow user to pick a goal or a tag
    @objc func selectTag() {
        activity.time = datePicker.date
        activity.name = ActivityTitle.text
        
        let index = picker.selectedRow(inComponent: 0)
        //Move from first screen ( Tag or Goal) to second
        if firstPickerView {
            switch index {
            case 0:
                showGoals = false
            default:
                showGoals = true
            }
            
            firstPickerView = false
            picker.reloadAllComponents()
        //Either the user has picked a goal or a tag, change colour scheme accordingly
        } else {
            if showGoals {
                let goals = selectedWeek?.goals?.sortedArray(using: [NSSortDescriptor(key: "timeCreated", ascending: true)]) as? [Goal]
                tagsField.text = goals?[index].name
                tagsField.textColor = goals?[index].backgroundColour
                tagsField.endEditing(true)

                activity.type = nil
                activity.background = nil
                activity.highlight = nil
                
                activity.goal = goals?[index]
            } else {
                tagsField.text = shuffledTags[index].activityType
                tagsField.textColor = shuffledTags[index].background
                tagsField.endEditing(true)
                
                activity.type = shuffledTags[index].activityType
                activity.background = shuffledTags[index].background
                activity.highlight = shuffledTags[index].highlight
                activity.goal = nil
            }
            
            activity = { activity }()
            
            //Reset options
            firstPickerView = true
            showGoals = false
        }
        //Save
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    @objc func shuffleTags() {
        tagsToBeShuffled = true
        picker.reloadAllComponents()
    }
    
    //MARK: - Saving info
    @IBAction func dismissPopUp(_ sender: UIButton) {
        //If there is no name for the activity, don't save the activity.
        if ActivityTitle.text == "" {
            context.delete(activity)
        }
        
        //If the user is currently trying to dismiss picker or time picker, don't dismiss whole pop up.
        if isCompleted == false && picker.superview == nil && timePicker.superview == nil {
            activity.name = ActivityTitle.text
            
            //round the date to nearest 5 mins!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            
            //Get the selected date in date form
            if let date = selectedDay?.date {
                if let currentDate = dateFormatter.date(from: date) {
                    activity.time = datePicker.date.addTimeToDate(from: currentDate)
                }
            }
            
            if ActivityIconPopUp.currentTitle != "" {
                activity.icon = ActivityIconPopUp.currentTitle
            }
            
            if activity.goal == nil && activity.background == nil {
                activity.background = UIColor(named: "Default1")
                activity.highlight = UIColor(named: "Default2")
            }
    
            let minutes = Int(timerSlider.value).roundedDown(toMultipleOf: 5)
            activity.duration = Int64(minutes)
            
            //Save all the information to Core Data store
            do {
                try context.save()
            } catch {
                print(error)
            }

            getDesign?()
            callbackClosure?()
        } else if picker.superview != nil {
            //reset the picker
            firstPickerView = true
            showGoals = false
            tagsField.endEditing(true)
            return
        }
        
        showTabBar?()
        dismiss(animated: true, completion: nil)
    }
    
}
