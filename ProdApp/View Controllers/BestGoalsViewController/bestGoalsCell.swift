//
//  bestGoalsCell.swift
//  Organiser
//
//  Created by Permindar LvL on 03/02/2022.
//

import UIKit

class bestGoalsCell: UITableViewCell {
    
    @IBOutlet var rating: UIImageView!
    @IBOutlet var goalName: UILabel!
    @IBOutlet var info: UIButton!
    
    var showPercentage = false
    
    var goal: Goal! {
        didSet {
            //Reloading cell's info
            goalName.text = goal.name

            //Calculate percentage of duration that user has completed
            if showPercentage == true {
                let percent = Int(((Float(goal.totalDuration) / Float(goal.duration)) * 100.0).rounded())
                info.setTitle("\(percent)%", for: .normal)
            } else {
                //calculating avg productivity
                let activities = goal.activities?.sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]) as? [Activity]
                
                if let completed = activities?.compactMap( { $0.productivity }) {
                    let average = (Float(goal.totalProductivity) / Float(completed.count))
                    let averageTxt = String(format: "%.1f", average)

                    info.setTitle("\(averageTxt) / 5.0", for: .normal)
                }
            } 

            //Reloading cell's design
            contentView.backgroundColor = goal.backgroundColour
            layer.cornerRadius = 5

            goalName.textColor = goal.highlightColour
            rating.tintColor = goal.highlightColour
            info.setTitleColor(goal.highlightColour, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
