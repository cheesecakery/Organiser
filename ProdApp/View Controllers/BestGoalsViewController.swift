//
//  BestGoalsViewController.swift
//  Organiser
//
//  Created by Permindar LvL on 03/02/2022.
//

import UIKit

class BestGoalsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var showTabBar: (() -> Void)?
    
    var selectedWeek: Week?
    
    @IBOutlet var switchInfo: UISegmentedControl!
    
    var rankedGoals: [Goal]?
    var showPercentage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //makes sure it is presented over context
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.isOpaque = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "bestGoalsCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.separatorStyle = .none
        tableView.isUserInteractionEnabled = false
        
        changeRanking()
    }
    
    func changeRanking() {
        if let goals = selectedWeek?.goals?.sortedArray(using: [NSSortDescriptor(key: "timeCreated", ascending: true)]) as? [Goal] {
            if showPercentage {
                //make sure no division by 0 is happening
                rankedGoals = goals.filter( {$0.totalDuration != 0 && $0.duration != 0 })
                
                rankedGoals?.sort(by: {
                    (Float($0.totalDuration) / Float($0.duration)) > (Float($1.totalDuration) / Float($1.duration))
                })
            } else {
                rankedGoals = goals.filter( { $0.totalProductivity != 0 && $0.activities?.count != 0})
                
                rankedGoals?.sort(by: {
                    let prod1 = Float($0.totalProductivity)
                    let prod2 = Float($1.totalProductivity)
                    
                    let count1 = Float($0.activities?.count ?? 0)
                    let count2 = Float($1.activities?.count ?? 0)
                    
                    return (prod1 / count1) > (prod2 / count2)
                })
            }
        }
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch switchInfo.selectedSegmentIndex {
        
        case 0:
            showPercentage = false
            changeRanking()
            tableView?.reloadSections([0], with: .right)
        case 1:
            showPercentage = true
            changeRanking()
            tableView?.reloadSections([0], with: .left)
        default:
            break
        }
        
        //tableView.reloadData()
    }
    
    
    @IBAction func dismiss(_ sender: Any) {
        showTabBar?()
        dismiss(animated: true)
    }
    
}

extension BestGoalsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankedGoals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? bestGoalsCell else { fatalError("No cell found.")}
        
        cell.showPercentage = showPercentage
        cell.goal = rankedGoals?[indexPath.row]
        print(indexPath.row + 1)
        cell.rating?.image = UIImage(systemName: "\(indexPath.row + 1).circle.fill")
        
        return cell
    }
}

extension BestGoalsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
