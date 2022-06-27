//
//  CalenderViewController.swift
//  ProdApp
//
//  Created by Permindar LvL on 27/08/2021.
//
import FSCalendar
import UIKit

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance, FSCalendarDataSource {
    
    @IBOutlet var calendar: FSCalendar!
    
    var changeDate: (() -> Void)?
    
    var showTabBar: (() -> Void)?
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //makes sure it is presented over context
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.isOpaque = false

        calendar.delegate = self
        calendar.dataSource = self
        calendar.firstWeekday = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Highlight the currently selected date
        let date = defaults.object(forKey: "date") as? Date
        if let date = date {
            calendar.select(date)
        }
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        let date = defaults.object(forKey: "initialUse") as? Date
        if let date = date {
            return date
        } else {
            return dateFormatter.date(from: "2021-08-01")!
        }
    }
    
    //Navigate to new date
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let newDate = date.addingTimeInterval(TimeInterval(NSTimeZone.local.secondsFromGMT()))
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            
            defaults.set(newDate, forKey: "date")

            vc.scheduleDate = newDate
            
            changeDate?()
            showTabBar?()
            dismiss(animated: true, completion: nil)
        }
    }

    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
//
//        let defaultColor = appearance.titleDefaultColor
//
//        if #available(iOS 12.0, *) {
//            if self.traitCollection.userInterfaceStyle == .dark {
//                return .darkGray
//            } else {
//                return defaultColor
//            }
//        } else {
//            return defaultColor
//        }
//
//    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
            self.calendar?.reloadData()
        }
    
    @IBAction func dismissCalendar(_ sender: UIButton) {
        showTabBar?()
        dismiss(animated: true, completion: nil)
    }
}
