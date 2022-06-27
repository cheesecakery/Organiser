//
//  ViewController.swift
//  ProdApp
//
//  Created by Permindar LvL on 23/08/2021.
//

import UIKit
import CoreData
import SwiftSVG

class ViewController: UITableViewController, UITableViewDragDelegate {
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    let notifications = ["Simple Local Notification", "Local Notification with Action", "Local Notification with Content"]
    
    var scheduleDate: Date?
    var dateOfSchedule: String?
    
    var selectedDay: Day?
    var selectedWeek: Week?
    
    var sectionShouldBeHidden = true
    
    var startOfWeek: Date?
    
    var isEditable = true
    
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    fileprivate lazy var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }()
    
    //MARK: - 'View Did ...'s
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInsetAdjustmentBehavior = .never
        
        //Test for whether it is the first launch or subsequent ones.
        if defaults.bool(forKey: "First Launch") == true {
            print("Second+")
            defaults.set(true, forKey: "First Launch")
        } else {
            print("First")
            do {
                try context.save()
            } catch {
                print(error)
            }
            
            defaults.set(dateFormatter1.date(from: "2021/11/01"), forKey: "initialUse")
            
            defaults.set(true, forKey: "First Launch")
        }
        
        //register the table view
        tableView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "ActivityCell")
        tableView.separatorStyle = .none
        tableView.allowsSelectionDuringEditing = true
        tableView.clipsToBounds = true
        
        //Making sure there is no gap before 'Show/hide completed'
        tableView.sectionFooterHeight = 0
        
        //For moving a cell
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        
        //So table view does not extend over tab bar
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = [.left, .right]

        UIColorValueTransformer.register()
        
        getActivityDesigns()
        
        //Get items from core data
        fetchWeeks()
        
        //Load VC's features
        defaults.setValue(Date(), forKey: "date")
        dateThings(date: Date())
        loadActivityIcons()
    }

    override func viewWillAppear(_ animated: Bool) {
        //Change date to coincide with other VCs
        if let date = defaults.object(forKey: "date") as? Date {
            dateThings(date: date)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createActivity))
        
        checkIfShouldBeEditable()
        
        //makes sure tab bar is in view
        self.tabBarController?.tabBar.layer.zPosition = 0
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        let dates = calendar.weekBoundary(for: Date())

        //Check whether to show the current week's questionnaire or not.
        if let weeks = weeks {
            if dates?.startOfWeek == selectedWeek?.startDate && selectedWeek?.questionnaireCompleted == false {
                for i in 0..<weeks.count {
                    //if previous week has no activities in it, no point assigning a questionnaire - haven't done anything to reflect on.
                    if weeks[i].startDate == selectedWeek?.startDate {
                        if i > 0 && weeks[i - 1].totalActivities?.count != 0 {
                            let ac = UIAlertController(title: "Self Reflection", message: "Would you like to complete the questionnaire?", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: beginQuestionnaire))
                            present(ac, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Dates
    //TODO: Clean up -- Creating the title and the selected week + day
    func dateThings(date: Date) {
        let dates = calendar.weekBoundary(for: date)
        guard let startDate = dates?.startOfWeek! else { return }
        guard let endDate = dates?.endOfWeek! else { return }
        
        let dateString = dateFormatter1.string(from: date)
        let day = calendar.component(.day, from: date)
        let dateFormatter = DateFormatter()
        
        //Making the title - getting month and day through the date formatter
        dateFormatter.dateFormat = "LLLL"
        let month = dateFormatter.string(from: date)
        let monthRange = month.startIndex..<month.index(month.startIndex, offsetBy: 3)
            
        dateFormatter.dateFormat = "EEEE"
        let dayOfTheWeek = dateFormatter.string(from: date)
        let range = dayOfTheWeek.startIndex..<dayOfTheWeek.index(dayOfTheWeek.startIndex, offsetBy: 3)

        navigationItem.title = "\(dayOfTheWeek[range]) \(day) \(month[monthRange])"
        
        //Figuring out the current day / week
        let newDay = Day(context: context)
        newDay.date = dateString
        
        if let weeks = weeks {
            if let selected = weeks.filter({$0.startDate == startDate}).first {
                selectedWeek = selected
            } else {
                let newWeek = Week(context: context)
                newWeek.startDate = startDate
                newWeek.endDate = endDate
                selectedWeek = newWeek
            }
            
            selectedWeek?.addToDays(newDay)
            
            do {
                try context.save()
            } catch {
                print(error)
            }
            
            fetchWeeks()
            
            for week in weeks {
                if let days = week.days?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true)]) as? [Day] {
                    if let day = days.filter( { $0.date == dateString }).first {
                        selectedDay = day
                        break
                    }
                }
            }
        }
        
        tableView.reloadData()
        
        let tabBarVC = self.tabBarController as! MySubclassedTabBarController
        tabBarVC.selectedWeek = selectedWeek
    }

    func checkIfShouldBeEditable() {
        isEditable = calendar.checkIfPastWeek(for: selectedWeek?.startDate ?? Date())
        
        if isEditable {
            tableView.isUserInteractionEnabled = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createActivity))
        } else {
            //tableView.setEditing(true, animated: false)
            navigationItem.setRightBarButton(nil, animated: true)
        }
        
        let tabBarVC = self.tabBarController as! MySubclassedTabBarController
        tabBarVC.isEditable = isEditable
    }
    
    func beginQuestionnaire(action: UIAlertAction) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "reflectionViewController") as? reflectionViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext

            vc.selectedWeek = selectedWeek
            
            vc.showTabBar = { [weak self] in
                self?.tabBarController?.tabBar.layer.zPosition = 0
                self?.tabBarController?.tabBar.isUserInteractionEnabled = true
            }

            vc.callbackClosure = { [weak self] in
                self?.fetchWeeks()
            }
            
            tabBarController?.tabBar.layer.zPosition = -1
            tabBarController?.tabBar.isUserInteractionEnabled = false
            
            present(vc, animated: true)
        }
    }
    
    @objc func notifyEndOfTask(timer: Timer) {
        if let userInfo = timer.userInfo as? Int {
            let activities = selectedDay?.activities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity]
            
            if let activity = activities?[userInfo] {
                if activity.timerCompleted == false {
                    let type = notifications[0]

                    if let name = activity.name {
                        self.appDelegate?.scheduleNotification(type: type, activity: name)
                    }
                    
                    activities?[userInfo].timerCompleted = true
                    
                    do {
                        try context.save()
                    } catch {
                        print(error)
                    }
                    
                    fetchWeeks()
                }
            }
        }
    }

    //MARK: - Loading tags / icons
    func getActivityDesigns() {
        let Default = Tag(activityType: "Default", background: UIColor(named: "Default1"), highlight: UIColor(named: "Default2"))
        let Fitness = Tag(activityType: "Fitness", background: UIColor(named: "Fitness1"), highlight: UIColor(named: "Fitness2"))
        let Work = Tag(activityType: "Work", background: UIColor(named: "Work1"), highlight: UIColor(named: "Work2"))
        let Social = Tag(activityType: "Social", background: UIColor(named: "Social1"), highlight: UIColor(named: "Social2"))
        let General = Tag(activityType: "Creativity", background: UIColor(red: 0, green: 162/255.0, blue: 81/255.0, alpha: 1.0), highlight: UIColor.systemGreen)
        let Relaxation = Tag(activityType: "Relaxation", background: UIColor(named: "Relaxation1"), highlight: UIColor(named: "Relaxation2"))
        let Study = Tag(activityType: "Study", background: UIColor(named: "Study2"), highlight: UIColor(named: "Study1"))
        let Entertainment = Tag(activityType: "Entertainment", background: UIColor(named: "Entertainment1"), highlight: UIColor(named: "Entertainment2"))
        tags = [Default, Fitness, Work, Social, General, Relaxation, Study, Entertainment]
    }
    
    func loadActivityIcons() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
            
        for item in items {
            if item.hasPrefix("icon") && item.hasSuffix(".svg") {
                if let item = item.components(separatedBy: ".").first {
                    icons.append(item)
                }
            }
        }
    }

    //MARK: - Creating / editing an activity
    @objc func createActivity() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpViewController") as? PopUpViewController {
            
            vc.callbackClosure = { [weak self] in
                
                self?.fetchWeeks()
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            
            vc.showTabBar = { [weak self] in
                DispatchQueue.main.async {
                    self?.tabBarController?.tabBar.layer.zPosition = 0
                    self?.tabBarController?.tabBar.isUserInteractionEnabled = true
                }
            }
            
            let newActivity = Activity(context: context)
            selectedDay?.addToActivities(newActivity)
            selectedWeek?.addToTotalActivities(newActivity)
            vc.activity = newActivity
            
            vc.selectedDay = selectedDay
            vc.selectedWeek = selectedWeek
            
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            tabBarController?.tabBar.layer.zPosition = -1
            tabBarController?.tabBar.isUserInteractionEnabled = false
            
            present(vc, animated: true, completion: nil)
        }
    }
    
    //if user selects row, gets pop up for that row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpViewController") as? PopUpViewController {

            //pass on date
            vc.selectedDay = selectedDay
            vc.selectedWeek = selectedWeek
            
            vc.isEditable = isEditable
            
            //when pop up dismissed, reload info
            vc.callbackClosure = { [weak self] in
                self?.fetchWeeks()
                self?.tableView.reloadData()
            }
            
            vc.showTabBar = { [weak self] in
                DispatchQueue.main.async {
                    self?.tabBarController?.tabBar.layer.zPosition = 0
                    self?.tabBarController?.tabBar.isUserInteractionEnabled = true
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            }
            
            var activities: [Activity]?
            
            //if uncompleted
            if indexPath.section == 0 {
                vc.isCompleted = false
                activities = selectedDay?.activities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity]
            } else {
                vc.isCompleted = true
                activities = selectedDay?.completedActivities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity]
            }
            
            if let activity = activities?[indexPath.row] {
                vc.activity = activity
            }
            
            vc.getDesign = {
                tableView.reloadData()
            }
            
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            tabBarController?.tabBar.layer.zPosition = -1
            tabBarController?.tabBar.isUserInteractionEnabled = false
            
            present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: - Table View Base Implementation
    //Adding an empty message when there are no activities
    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedDay?.activities?.count == 0 && selectedDay?.completedActivities?.count == 0 {
            tableView.setEmptyMessage("Silence is not empty.\n\nIt is the loudest answer\n\n\n")
        } else {
            tableView.restore()
        }
        
        
        return 2
    }
    
    //How many rows to show - depends on whether it is a completed activity or not and whether the second section should be hidden.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if sectionShouldBeHidden {
                return 0
            }
            return selectedDay?.completedActivities?.count ?? 0
        } else {
            return selectedDay?.activities?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 50
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    // Show / Hide button
    @objc func showAndHideCompleted(sender: UIButton) {
        sectionShouldBeHidden.toggle()
        tableView.reloadSections([1], with: .fade)
    }

    //To make the 'Show completed/Hide completed' button
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        view.translatesAutoresizingMaskIntoConstraints = false
        if section == 1 && selectedDay?.completedActivities?.count ?? 0 > 0 {
            var showButton: UIButton? = nil
            
            // Check for existing button - otherwise might create several
            for i in 0..<view.subviews.count {
                if view.subviews[i] is UIButton {
                    showButton = view.subviews[i] as? UIButton
                }
            }
                
            //if no button exists, can create new one
            if showButton == nil {
                showButton = UIButton(type: .system)
                view.addSubview(showButton!)
            }
                
            //create button
            showButton?.frame = CGRect(x: 15, y: 0, width: 150, height: view.frame.height)
            if sectionShouldBeHidden {
                showButton?.setAttributedTitle(NSAttributedString(string: "Show completed", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Default1")!, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]), for: .normal)
            } else {
                showButton?.setAttributedTitle(NSAttributedString(string: "Hide completed", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Default1")!, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]), for: .normal)
            }
            
            showButton?.tag = section
            showButton?.contentHorizontalAlignment = .left

            showButton?.addTarget(self, action: #selector(showAndHideCompleted(sender:)), for: .touchUpInside)
        }
        return view
    }

    //Displaying table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as? ActivityCell else { fatalError("Unable to dequeue an activity cell") }
 
        var activities: [Activity]?
        
        if indexPath.section == 0 {
            cell.isCompleted = false
            activities = selectedDay?.activities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity]
            
            if let time = activities?[indexPath.row].time {
                let info = indexPath.row
                
                //means that timer will only run once.
                if activities![indexPath.row].timerCompleted == false {
                    if time > Date() {
                        let timer = Timer(fireAt: time, interval: 0, target: self, selector: #selector(notifyEndOfTask), userInfo: info, repeats: false)
                        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
                    }
                }
            }
        } else {
            cell.isCompleted = true
            activities = selectedDay?.completedActivities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity]
        }
        
        if let activity = activities?[indexPath.row] {
            cell.activity = activity
        }

        //set up checkbox button
        cell.checkingBox = { [weak self] in
            //access both uncompleted & completed activities
            if let activity = activities?[indexPath.row] {
                //if it is uncompleted -> completed
                if indexPath.section == 0 {
                    activity.timerCompleted = true
                    
                    if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "productivityPopUpViewController") as? productivityPopUpViewController {
                        vc.modalPresentationStyle = .overCurrentContext
                        vc.modalTransitionStyle = .crossDissolve
                        
                        vc.selectedDay = self?.selectedDay
                        vc.selectedPopUpPosition = indexPath.row
                        vc.activity = activity
                        
                        vc.showTabBar = {
                            DispatchQueue.main.async {
                                self?.tabBarController?.tabBar.layer.zPosition = 0
                                self?.tabBarController?.tabBar.isUserInteractionEnabled = true
                            }
                        }
                        
                        vc.ifSaved = {
                            self?.selectedDay?.addToCompletedActivities(activity)
                            self?.selectedDay?.removeFromActivities(activity)
                            
                            activity.goal?.totalDuration += activity.duration
                            activity.goal?.totalProductivity += Int64(activity.productivity ?? "0") ?? 0
                            
                            do {
                                try context.save()
                            } catch {
                                print(error)
                            }
                            
                            self?.fetchWeeks()
                            tableView.reloadData()
                        }
                        
                        self?.tabBarController?.tabBar.layer.zPosition = -1
                        self?.tabBarController?.tabBar.isUserInteractionEnabled = false
                        
                        self?.present(vc, animated: true)
                    }
                }
            }
        }
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
////        if indexPath.section == 0 {
////            return true
////        } else {
////            return false
////        }
//    }
    
    //deleting row
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let ac = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            var activities: [Activity]?
            
            //Check if activity is completed or not
            if indexPath.section == 0 {
                activities = self.selectedDay?.activities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity]
            } else {
                activities = self.selectedDay?.completedActivities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity]
                
                //takes away values so doesn't affect score
                if let activity = activities?[indexPath.row] {
                    activity.goal?.totalDuration -= activity.duration
                    activity.goal?.totalProductivity -= Int64(activity.productivity ?? "0") ?? 0
                }
            }
            
            //Remove activity
            guard let activityToRemove = activities?[indexPath.row] else { fatalError() }
            context.delete(activityToRemove)
            
            //Save changes & re-fetch data
            do {
                try context.save()
            } catch {
                print(error)
            }

            self.fetchWeeks()
            
            self.tableView.reloadData() 
        }
        
        return UISwipeActionsConfiguration(actions: [ac])
    }
    
    //MARK: - Table View Drag Implementation
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        
        if let activities = selectedDay?.activities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity] {
              dragItem.localObject = activities[indexPath.row]
        }

        return [ dragItem ]
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        if let activities = selectedDay?.activities?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as? [Activity] {
            
            guard let destinationTime = activities[destinationIndexPath.row].time else { fatalError("No destination time") }
            
            //Convert to time before or after depending if before or after in table view.
            if sourceIndexPath.row < destinationIndexPath.row {
                activities[sourceIndexPath.row].time = calendar.date(byAdding: .minute, value: 5, to: destinationTime)
            } else {
                activities[sourceIndexPath.row].time = calendar.date(byAdding: .minute, value: -5, to: destinationTime)
            }
            
            do {
                try context.save()
            } catch {
                print(error)
            }
            
            fetchWeeks()
            
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    //MARK: - Calendar
    @IBAction func openCalendar(_ sender: UIBarButtonItem) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController {
            
            vc.changeDate = { [weak self] in

                if let date = defaults.object(forKey: "date") as? Date {
                    self?.dateThings(date: date)
                }
                
                do {
                    try context.save()
                } catch {
                    print(error)
                }
                    
                self?.tableView.reloadData()
                
                self?.checkIfShouldBeEditable()
            }
            
            vc.showTabBar = { [weak self] in
                DispatchQueue.main.async {
                    self?.tabBarController?.tabBar.layer.zPosition = 0
                    self?.tabBarController?.tabBar.isUserInteractionEnabled = true
                }
            }

            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            tabBarController?.tabBar.layer.zPosition = -1
            tabBarController?.tabBar.isUserInteractionEnabled = false
            
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Saving data
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
