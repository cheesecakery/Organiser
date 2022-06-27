//
//  reflectionViewController.swift
//  ProdApp
//
//  Created by Permindar LvL on 25/12/2021.
//

import UIKit
import CoreData

class reflectionViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var question1buttons: [UIButton]!
    @IBOutlet var question2buttons: [UIButton]!
    @IBOutlet var question3buttons: [UIButton]!
    @IBOutlet var question4buttons: [UIButton]!
    
    var buttons = [[UIButton]]()
    
    @IBOutlet var dismissButton: UIButton!
    
    var answers = ["","","","",""]

    @IBOutlet var completeButton: UIButton!
    
    var selectedWeek: Week?
    var callbackClosure: (() -> Void)?
    var showTabBar: (() -> Void)?
    
    var isReviewing = false
    
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hides tab bar
        
        buttons = [question1buttons, question2buttons, question3buttons, question4buttons]

        //makes background transparent
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.isOpaque = false
        
        //Text view implementation
        textView.delegate = self
        textView.textContainer.heightTracksTextView = true
        textView.isScrollEnabled = false
        textView.textContainer.maximumNumberOfLines = 6
        textView.textAlignment = .center
        
        //This is to move the text box so that it is still visible when the keyboard is open
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Initially uncompleted
        completeButton.setImage(UIImage(systemName: "circle"), for: .normal)
        
        for buttons in buttons {
            for button in buttons {
                let tag = button.tag.digits
                let last = tag[1]
                
                button.setImage(UIImage(systemName: "\(last).circle"), for: .normal)
                button.setImage(UIImage(systemName: "\(last).circle.fill"), for: .selected)
            }
        }
        
        if isReviewing {
            textView.isUserInteractionEnabled = false
            for buttons in buttons {
                buttons.forEach( { $0.isUserInteractionEnabled = false })
            }

            completeButton.isHidden = true
            showPreviousAnswers()
        }
    }

    //Display the week's answers
    func showPreviousAnswers() {
        question1buttons[(Int(selectedWeek?.question1 ?? "1") ?? 1) - 1].isSelected = true
        question2buttons[(Int(selectedWeek?.question1 ?? "1") ?? 1) - 1].isSelected = true
        question3buttons[(Int(selectedWeek?.question1 ?? "1") ?? 1) - 1].isSelected = true
        question4buttons[(Int(selectedWeek?.question1 ?? "1") ?? 1) - 1].isSelected = true
        textView.text = selectedWeek?.question5
    }
    
    //Answer the multiple choice questions
    @IBAction func question1to4(_ sender: UIButton) {
        let tag = sender.tag.digits
        let first = tag[0]
        let last = tag[1]
        
        buttons[first - 1].forEach { button in
            button.isSelected = false
        }
        
        sender.isSelected = true
        
        answers[first - 1] = "\(last)"
        
        //If all questions have been answered, allow user to complete the Q
        if answers.allSatisfy( { $0 != "" }) {
            completeButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
    }

    //Answer the final text box
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text {
            if text != "" {
                answers[4] = "\(text)"
            }
            
            //If all questions have been answered, allow user to complete the Q
            if answers.allSatisfy( { $0 != "" }) {
                completeButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            }
            
        }
    }
    
    //Save the answers the user has inputted and dismiss VC
    @IBAction func completeQuestions(_ sender: UIButton) {
        if answers.count == 5 && answers.allSatisfy( { $0 != "" }) {
            selectedWeek?.questionnaireCompleted = true

            var calendar = Calendar.current
            calendar.firstWeekday = 2
            
            let dates = calendar.weekBoundary(for: Date())
            guard let start = dates?.startOfWeek else { return }
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: start)
            let endDate = Calendar.current.date(byAdding: .day, value: -1, to: start)

            let newWeek = Week(context: context)
            newWeek.startDate = startDate
            newWeek.endDate = endDate

            newWeek.question1 = answers[0]
            newWeek.question2 = answers[1]
            newWeek.question3 = answers[2]
            newWeek.question4 = answers[3]
            newWeek.question5 = answers[4]
            
            do {
                try context.save()
            } catch {
                print(error)
            }
            
            callbackClosure?()
            showTabBar?()

            dismiss(animated: true, completion: nil)
        }
    }
    
    //Extra stuff for text box
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0 {                       self.view.frame.origin.y -= keyboardFrame.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y != 0{                       self.view.frame.origin.y += keyboardFrame.height
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }

        let currentText = textView.text ?? ""
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        // make sure the result is under 200 characters
        return updatedText.count <= 200
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        showTabBar?()
        dismiss(animated: true, completion: nil)
    }
    
    //Fetch info from core data
    func fetchWeeks() {
        do {
            let request = Week.fetchRequest() as NSFetchRequest<Week>
            let sort = NSSortDescriptor(key: "startDate", ascending: true)
            request.sortDescriptors = [sort]
            weeks = try context.fetch(request)
        } catch {
            print(error)
        }
    }
}
