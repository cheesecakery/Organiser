//
//  StatisticsViewController.swift
//  Organiser
//
//  Created by Permindar LvL on 25/01/2022.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController {
    
    var selectedWeek: Week?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBarVC = self.tabBarController as! MySubclassedTabBarController
        selectedWeek = tabBarVC.selectedWeek
        
        createCorrectTitle()
    }
    
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
                
                self?.createCorrectTitle()
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
    
    @IBAction func openPieChartView(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "GraphsViewController") as? GraphsViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            vc.selectedWeek = selectedWeek
            
            vc.callbackClosure = { [weak self] in
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
    
    @IBAction func openBarChartView(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "BarChartViewController") as? BarChartViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            
            vc.selectedWeek = selectedWeek
            
            vc.moveToSecondTab = { [weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self?.tabBarController?.selectedIndex = 1
                }
            }
            
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
        tabBarVC.selectedWeek = selectedWeek
        
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
