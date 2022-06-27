//
//  GoalViewController.swift
//  ProdApp
//
//  Created by Permindar LvL on 26/12/2021.
//

import UIKit
import CoreData

class GoalViewController: UIViewController {
    
    @IBOutlet var viewQButton: UIButton! {
        didSet {
            viewQButton.layer.cornerRadius = 5
            viewQButton.isHidden = true
        }
    }
    
    @IBOutlet var viewQButtonHeight: NSLayoutConstraint!
    @IBOutlet var viewQButtonGap: NSLayoutConstraint!
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UINib(nibName: "goalCell", bundle: nil), forCellReuseIdentifier: "goalCell")
            tableView.separatorStyle = .none
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 90
        }
    }
    
    @IBOutlet var addGoal: UIButton!
    @IBOutlet var starButton: UIBarButtonItem!
    
    var selectedWeek: Week?
    
    var isEditable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createCorrectTitle()

        checkIfShouldBeEditable()
        
        checkToShowStar()
        
        //makes sure tab bar is in view
        self.tabBarController?.tabBar.layer.zPosition = 0
        self.tabBarController?.tabBar.isHidden = false
        
        tableView.reloadData()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkToShowQButton()
    }
    
    //MARK: - PARAMETERS TO CHECK
    func checkIfShouldBeEditable() {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        isEditable = calendar.checkIfPastWeek(for: selectedWeek?.startDate ?? Date())
        
        if isEditable {
            addGoal.isHidden = false
        } else {
            addGoal.isHidden = true
        }
        
        let tabBarVC = self.tabBarController as! MySubclassedTabBarController
        tabBarVC.isEditable = isEditable
    }
    
    func checkToShowStar() {
        if let goals = selectedWeek?.goals?.sortedArray(using: [NSSortDescriptor(key: "timeCreated", ascending: true)]) as? [Goal] {
            if goals.filter({ $0.totalDuration != 0 && $0.duration != 0 }).count == 0 {
                navigationItem.setRightBarButton(nil, animated: false)
            } else {
                navigationItem.setRightBarButton(starButton, animated: false)
            }
        } else {
            navigationItem.setRightBarButton(nil, animated: false)
        }
    }
    
    func checkToShowQButton() {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        if let startDate = selectedWeek?.startDate {
            //Calculate the next week
            let nxtStartDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)

            if let weeks = weeks {
                let week = weeks.filter( { $0.startDate == nxtStartDate } ).first
                if week?.questionnaireCompleted == true {
                    viewQButton.isHidden = false
                    viewQButtonHeight.constant = 60
                    viewQButtonGap.constant = 15
                } else {
                    viewQButton.isHidden = true
                    viewQButtonHeight.constant = 0
                    viewQButtonGap.constant = 0
                }
            }
            
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - CALENDAR & DATES
    @IBAction func openCalendar(_ sender: UIBarButtonItem) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
            vc.changeDate = { [weak self] in
                
                let date = defaults.object(forKey: "date") as? Date

                if let date = date {
                    self?.dateThings(date: date)
                }
                
                do {
                    try context.save()
                } catch {
                    print(error)
                }
                
                DispatchQueue.main.async {
                    self?.createCorrectTitle()
                    self?.checkIfShouldBeEditable()
                    self?.checkToShowQButton()
                    self?.checkToShowStar()
                }
                    
                self?.tableView.reloadData()
            }
            
            vc.showTabBar = { [weak self] in
                self?.tabBarController?.tabBar.layer.zPosition = 0
                self?.tabBarController?.tabBar.isUserInteractionEnabled = true
            }

            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            tabBarController?.tabBar.layer.zPosition = -1
            tabBarController?.tabBar.isUserInteractionEnabled = false
            
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //TODO: Clean up -- Date manipulation
    func dateThings(date: Date) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let dateFormatter = DateFormatter()

        let dates = calendar.weekBoundary(for: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let startDate = dates?.startOfWeek! else { return }
        guard let endDate = dates?.endOfWeek! else { return }

        if let weeks = weeks {
            if let selected = weeks.filter({$0.startDate == startDate}).first {
                selectedWeek = selected
            } else {
                let newWeek = Week(context: context)
                newWeek.startDate = startDate
                newWeek.endDate = endDate
                selectedWeek = newWeek
            }
        }
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        fetchWeeks()
        
        let tabBarVC = self.tabBarController as! MySubclassedTabBarController
        tabBarVC.selectedWeek = selectedWeek
    }
    
    //Date manipulation to get the correct title
    func createCorrectTitle() {
        let tabBarVC = self.tabBarController as! MySubclassedTabBarController
        selectedWeek = tabBarVC.selectedWeek
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let startDay = calendar.component(.day, from: selectedWeek?.startDate ?? Date())
        let end = calendar.date(byAdding: .day, value: 6, to: selectedWeek?.startDate ?? Date())
        
        let endDay = calendar.component(.day, from: end ?? Date())
        
        dateFormatter.dateFormat = "LLLL"
        let startMonth = dateFormatter.string(from: selectedWeek?.startDate ?? Date())
        let startRange = startMonth.startIndex..<startMonth.index(startMonth.startIndex, offsetBy: 3)
        
        let endMonth = dateFormatter.string(from: selectedWeek?.endDate ?? Date())
        let endRange = endMonth.startIndex..<endMonth.index(endMonth.startIndex, offsetBy: 3)
        
        navigationItem.title = "\(startDay) \(startMonth[startRange]) > \(endDay) \(endMonth[endRange])"
    }
    
    //MARK: - Check goals tally?
    @IBAction func openStar(_ sender: UIBarButtonItem) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "BestGoalsViewController") as? BestGoalsViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            vc.selectedWeek = selectedWeek
            
            vc.showTabBar = { [weak self] in
                DispatchQueue.main.async {
                    self?.tabBarController?.tabBar.layer.zPosition = 0
                    self?.tabBarController?.tabBar.isUserInteractionEnabled = true
                }
            }
            
            tabBarController?.tabBar.layer.zPosition = -1
            tabBarController?.tabBar.isUserInteractionEnabled = false
            
            present(vc, animated: true)
        }
    }
    
    //MARK: - QUESTIONNAIRE
    @IBAction func viewQuestionnaire(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "reflectionViewController") as? reflectionViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            vc.isReviewing = true
            vc.selectedWeek = selectedWeek
            
            vc.showTabBar = { [weak self] in
                DispatchQueue.main.async {
                    self?.createCorrectTitle()
                    self?.checkIfShouldBeEditable()
                    self?.checkToShowQButton()
                    
                    self?.tabBarController?.tabBar.layer.zPosition = 0
                    self?.tabBarController?.tabBar.isUserInteractionEnabled = true
                }
            }
            
            tabBarController?.tabBar.layer.zPosition = -1
            tabBarController?.tabBar.isUserInteractionEnabled = false
            
            present(vc, animated: true)
        }
    }
    
    //MARK: - CREATING A GOAL (GOING TO POP UP)
    @IBAction func createGoal(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "GoalCreatorViewController") as? GoalCreatorViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            vc.showTabBar = { [weak self] in
                self?.tabBarController?.tabBar.layer.zPosition = 0
                self?.tabBarController?.tabBar.isUserInteractionEnabled = true
            }
            
            vc.closureCallback = { [weak self] in
                self?.fetchWeeks()
                self?.tableView.reloadData()
            }
            
            let newGoal = Goal(context: context)
            newGoal.timeCreated = Date()
            selectedWeek?.addToGoals(newGoal)
            vc.goal = newGoal
            vc.creatingGoal = true
            
            vc.selectedWeek = selectedWeek
            
            tabBarController?.tabBar.layer.zPosition = -1
            tabBarController?.tabBar.isUserInteractionEnabled = false
            
            present(vc, animated: true)
        }
    }
    
    //MARK: - SAVING INFO TO CORE DATA
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

//MARK: - Table view implementation
extension GoalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedWeek?.goals?.count ?? 0
    }
    
    //Design cell + find info
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell", for: indexPath) as? goalCell else { fatalError("Unable to dequeue a goal cell") }
        
        let goals = selectedWeek?.goals?.sortedArray(using: [NSSortDescriptor(key: "timeCreated", ascending: true)]) as? [Goal]
        
        if let goal = goals?[indexPath.row] {
            cell.goal = goal
        }
        return cell
    }
    
    //Deleting a row
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let ac = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let goals = self.selectedWeek?.goals?.sortedArray(using: [NSSortDescriptor(key: "timeCreated", ascending: true)]) as? [Goal]
            guard let goalToRemove = goals?[indexPath.row] else { fatalError() }
            context.delete(goalToRemove)

            //save data
            do {
                try context.save()
            } catch {
                print(error)
            }
            
            //re-fetch data
            self.fetchWeeks()
            
            self.tableView.reloadData()
        }
        
        return UISwipeActionsConfiguration(actions: [ac])
    }
}

extension GoalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let goals = selectedWeek?.goals?.sortedArray(using: [NSSortDescriptor(key: "timeCreated", ascending: true)]) as? [Goal]
        if goals?[indexPath.row].activities?.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    //If a goal is selected, show that goal's pop up
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "GoalCreatorViewController") as? GoalCreatorViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            
            let goals = selectedWeek?.goals?.sortedArray(using: [NSSortDescriptor(key: "timeCreated", ascending: true)]) as? [Goal]
            
            if let goal = goals?[indexPath.row] {
                vc.goal = goal
            }
            
            vc.closureCallback = {
                tableView.reloadData()
            }
            
            vc.showTabBar = {
                self.tabBarController?.tabBar.layer.zPosition = 0
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            vc.creatingGoal = false
            
            vc.selectedWeek = selectedWeek
            
            vc.isEditable = isEditable

            self.tabBarController?.tabBar.layer.zPosition = -1
            
            present(vc, animated: true)
        }
    }
}
