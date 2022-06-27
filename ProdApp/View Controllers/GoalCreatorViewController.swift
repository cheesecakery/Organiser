//
//  GoalCreatorViewController.swift
//  ProdApp
//
//  Created by Permindar LvL on 28/12/2021.
//

import UIKit

class GoalCreatorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var closureCallback: (() -> Void)?
    var showTabBar: (() -> Void)?
    
    var selectedWeek: Week?
    var goal: Goal!
    
    var creatingGoal = true

    @IBOutlet var popupView: UIView! {
        didSet {
            popupView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet var popUpTitle: UILabel!
    @IBOutlet var goalName: UITextField! {
        didSet {
            goalName.delegate = self
        }
    }
    @IBOutlet var completionButton: UIButton!
    
    @IBOutlet var durationText: UIButton! {
        didSet {
            durationText.layer.cornerRadius = 3
        }
    }
    @IBOutlet var tagsField: UITextField!
    @IBOutlet var tagsText: UILabel!
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(UINib(nibName: "colourCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        }
    }
    
    var indexOfPicker = Int()
    let picker = UIPickerView()
    let toolbar = UIToolbar()
    var tagsToBeShuffled = false
    
    var isEditable = true
    
    var previousRow = 0
    var selectedCell = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //makes sure it is presented over context
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.isOpaque = false
        
        //Hide until the goal is ready to be completed
        completionButton.isHidden = true
        
        makePickerView()
    }
    
    //Reload the pop up
    override func viewWillAppear(_ animated: Bool) {
        if creatingGoal {
            reloadDesign(background: UIColor(named: "Default1")!, highlight: UIColor(named: "Default2")!)
            popUpTitle.text = "Create Goal"
        } else {
            reloadDesign(background: goal.backgroundColour, highlight: goal.highlightColour)
            popUpTitle.text = "Edit Goal"
        }
        
        reloadInfo(goal: goal)
        
        for i in 0..<colours.count {
            if goal.backgroundColour == UIColor(named: colours[i].background) {
                selectedCell = i
                previousRow = i
            }
        }
        
        if isEditable == false {
            goalName.isUserInteractionEnabled = false
            collectionView.isUserInteractionEnabled = false
            tagsField.isUserInteractionEnabled = false
        }
        
        let index = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: index, animated: true, scrollPosition: .bottom)
    }
    
    //Make sure colour schemes are on point
    func reloadDesign(background: UIColor?, highlight: UIColor?) {
        popupView.backgroundColor = background
        goalName.textColor = background?.darker(by: 20)
        durationText.setTitleColor(background, for: .normal)
        
        popUpTitle.textColor = highlight
        completionButton.tintColor = highlight
        goalName.backgroundColor = highlight
        durationText.backgroundColor = highlight
        collectionView.backgroundColor = highlight
        tagsText.textColor = highlight
        tagsField.backgroundColor = highlight
    }
    
    //+ Info is correct
    func reloadInfo(goal: Goal) {
        goalName.text = goal.name
        
        let duration = Int(goal.duration)
        durationText.setTitle(" \(duration.timeToString()) ", for: .normal)

        tagsField.text = goal.goalTag
        
        if let tag = tags.filter({ $0.activityType == tagsField.text }).first {
            tagsField.textColor = tag.highlight
        }
        
        collectionView.reloadData()
        
        if creatingGoal == false {
            completionButton.isHidden = false
        }
    }
    
    @IBAction func openDurationView(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "durationViewController") as? durationViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            
            vc.selectedWeek = selectedWeek
            vc.goal = goal
            
            vc.background = popupView.backgroundColor
            vc.highlight = popUpTitle.textColor
            
            vc.callbackClosure = { [weak self] in
                self?.durationText.setTitle(" \(Int(self?.goal.duration ?? 0).timeToString()) ", for: .normal)
            }
            
            present(vc, animated: true)
        }
    }
    
    
    // Picker View Implementation
    func makePickerView() {
        picker.dataSource = self
        picker.delegate = self
        tagsField.inputView = picker
        
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
        
        tagsField.inputAccessoryView = toolbar
    }
    
    @objc func shuffleTags() {
        tagsToBeShuffled = true
        picker.reloadAllComponents()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tags.count
    }
    
    //Gets title and colour of each tag
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if tagsToBeShuffled == true {
            tagsToBeShuffled = false
            tags.shuffle()
        }

        return NSAttributedString(string: tags[row].activityType, attributes: [NSAttributedString.Key.foregroundColor: tags[row].highlight?.darker(by: 20) as Any])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        indexOfPicker = row
    }
    
    @objc func selectTag() {
        if indexOfPicker < tags.count {
            tagsField.text = tags[indexOfPicker].activityType
            tagsField.textColor = tags[indexOfPicker].background
            tagsField.endEditing(true)
        }
        
        
        checkToShowCompletionButton()
    }
    
    //Check every time information is changed whether the user should be able to create the goal
    func checkToShowCompletionButton() {
        if goalName.text != "" && tagsField.text != "" {
            completionButton.isHidden = false
        }
    }
    
    //Create the goal
    @IBAction func createGoal(_ sender: UIButton) {
        if goalName.text == "" {
            context.delete(goal)
        } else {
            saveInfo(goal: goal)
        }
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        closureCallback?()
        
        showTabBar?()
        dismiss(animated: true, completion: nil)
    }
    
    func saveInfo(goal: Goal) {
        goal.name = goalName.text
        
        goal.backgroundColour = UIColor(named: colours[selectedCell].background)
        goal.highlightColour = UIColor(named: colours[selectedCell].highlight)
        
        if let tag = tags.filter( { $0.activityType == tagsField.text }).first {
            goal.goalTag = tag.activityType
        }
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        //if editing the cell, can apply more edits purely by dismissing the view.
        
        if creatingGoal == false {
            saveInfo(goal: goal)
            closureCallback?()
        }
        showTabBar?()
        dismiss(animated: true, completion: nil)
    }
}


extension GoalCreatorViewController: UITextFieldDelegate {
    //Max number of characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 35
    }
    
    //If there is text, then user can save.
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            checkToShowCompletionButton()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goalName.resignFirstResponder()
        return true
    }
}

extension GoalCreatorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //accounts for if not header
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            //creates default incase something goes wrong
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            guard let header = headerView as? Header else { return headerView }
            
            //sets correct header text & returns
            header.header.text = "Pick 2"
            header.header.textColor = popupView.backgroundColor
            
            return header
        default:
            assert(false, "Invalid element type")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! colourCell
        
        cell.backgroundColor = UIColor(named:colours[indexPath.row].background)?.darker(by: 20)
        cell.colour.backgroundColor = UIColor(named: colours[indexPath.row].background)
        
        if indexPath.row == selectedCell {
            cell.layer.borderWidth = 4
            cell.layer.borderColor = UIColor.white.cgColor
        } else {
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        return cell
    }
}

extension GoalCreatorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCell = indexPath.row

        reloadDesign(background: UIColor(named: colours[indexPath.row].background), highlight: UIColor(named: colours[indexPath.row].highlight))

        collectionView.reloadData()
        
        previousRow = indexPath.row
        
        checkToShowCompletionButton()
    }
}
