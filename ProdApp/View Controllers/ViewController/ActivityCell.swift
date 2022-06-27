//
//  ActivityCell.swift
//  OrganisationApp
//
//  Created by Permindar LvL on 13/08/2021.
//

import UIKit

//customisation of default table cell!
class ActivityCell: UITableViewCell {
    
    @IBOutlet var ActivityTitle: UILabel!
    @IBOutlet var TimeText: UIDatePicker!
    @IBOutlet var Timer: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var view: UIView!
    @IBOutlet var checkBox: UIButton!
    @IBOutlet var productivity: UIImageView!
    
    var checkingBox: (() -> Void)?
    
    var isCompleted = false
    
    var activity: Activity! {
        didSet {
            ActivityTitle.text = activity.name
            if let image = activity.icon {
                icon.image = UIImage(named: image)
            } else {
                icon.image = nil
            }
            
            TimeText.date = activity.time ?? Date()
            Timer.text = { () -> String in
                let calendar = Calendar.current
                let timerText = Int(activity.duration).timeToString()
                if activity.duration == 0 {
                    return ""
                }
                let endDate = calendar.date(byAdding: .minute, value: Int(activity.duration), to: activity.time ?? Date())
                let text = endDate?.dateToString()
                return "\(timerText) -> \(text ?? "")"
            }()
  
            var background: UIColor?
            var highlight: UIColor?
            
            if activity.goal != nil {
                background = activity.goal?.backgroundColour
                highlight = activity.goal?.highlightColour
            } else if activity.background != nil {
                background = activity.background
                highlight = activity.highlight
            }
            
            view.backgroundColor = background
            ActivityTitle.textColor = highlight
            checkBox.tintColor = highlight
            checkBox.isUserInteractionEnabled = true
            
            if Timer.text == "" {
                Timer.backgroundColor = .clear
            } else {
                Timer.backgroundColor = highlight?.withAlphaComponent(0.2)
            }
            Timer.textColor = highlight
            Timer.font = Timer.font.withSize(16)
            
            TimeText.tintColor = highlight
            productivity.tintColor = highlight
            
            if isCompleted {
                checkBox.setImage(UIImage(systemName: "square.fill"), for: .normal)
                contentView.layer.opacity = 0.4
                checkBox.isUserInteractionEnabled = false
                if let prod = activity.productivity {
                    productivity.isHidden = false
                    productivity.image = UIImage(systemName: "\(prod).circle.fill")
                } else {
                    productivity.isHidden = true
                }
            } else {
                productivity.isHidden = true
                checkBox.setImage(UIImage(systemName: "square"), for: .normal)
                contentView.layer.opacity = 1.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        TimeText.isUserInteractionEnabled = false
        // Configure the view for the selected state
    }
    
    @IBAction func boxChecked(_ sender: UIButton) {
        checkBox.isSelected.toggle()
        if let checkingBox = checkingBox { checkingBox() }
    }
}
