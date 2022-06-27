//
//  goalCell.swift
//  ProdApp
//
//  Created by Permindar LvL on 27/12/2021.
//

import UIKit

class goalCell: UITableViewCell {

    @IBOutlet var insideView: UIView!
    @IBOutlet var name: UILabel!
    @IBOutlet var durationText: UILabel!
    @IBOutlet var duration: UISlider!
    
    var goal: Goal! {
        didSet {
            //MARK: - Reloading cell's info
            name.text = goal.name
            durationText.text = Int(goal.duration).timeToString()
            
            contentView.backgroundColor = .white
            insideView.backgroundColor = goal.backgroundColour
            
            duration.minimumValue = 0
            duration.maximumValue = 100
            
            if goal.duration == 0 {
                duration.isHidden = true
            } else {
                if goal.totalDuration == 0 {
                    duration.value = 0
                } else {
                    var percentage = ((Float(goal.totalDuration) / Float(goal.duration)) * 100.0)
                    if percentage >= 100.0 {
                        percentage = 100
                        contentView.backgroundColor = goal?.highlightColour
                        durationText.text = Int(goal.totalDuration).timeToString()
                    }
                    
                    duration.value = percentage
                }
                
                duration.isHidden = false
            }
            
            //MARK: - Reloading cell's design
            name.textColor = goal.highlightColour
            
            duration.isUserInteractionEnabled = false
            duration.maximumValue = 100
            duration.setThumbImage(UIImage(), for: .normal)
            duration.tintColor = goal.highlightColour
            
            durationText.textColor = goal.highlightColour
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
