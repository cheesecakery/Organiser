//
//  PaddingLabel.swift
//  
//
//  Created by Permindar LvL on 04/11/2021.
//

import UIKit

@IBDesignable class PaddingLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0
    @IBInspectable var borderColor : UIColor = UIColor.black
    @IBInspectable var borderWidth : CGFloat = 1
    @IBInspectable var cornerRadius : CGFloat = 5
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
              height: size.height + topInset + bottomInset)
    }

    override func textRect(forBounds bounds:CGRect,
                       limitedToNumberOfLines n:Int) -> CGRect {
        let b = bounds
        let UIEI = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        let tr = b.inset(by: UIEI)
        let ctr = super.textRect(forBounds: tr, limitedToNumberOfLines: 0)
        // that line of code MUST be LAST in this function, NOT first
        return ctr
    }
}
