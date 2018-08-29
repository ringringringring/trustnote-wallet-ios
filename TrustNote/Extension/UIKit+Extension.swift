//
//  UIKit+Extension.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ViewRadiusCornerProtocol {
    
    func setupRadiusCorner(radius: CGFloat)
    
    func setupShadow(Offset: CGSize, opacity: Float, radius: CGFloat)
    
}

extension UIView: ViewRadiusCornerProtocol {
    
    func setupShadow(Offset: CGSize, opacity: Float, radius: CGFloat) {
        layer.shadowColor = kGlobalColor.cgColor
        layer.shadowOffset = Offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
    
    
    func setupRadiusCorner(radius: CGFloat) {
        self.layer.cornerRadius = radius
      //  self.layer.masksToBounds = true
    }
    
    
    /// x
    var x: CGFloat {
        get { return frame.origin.x }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.x    = newValue
            frame                 = tempFrame
        }
    }
    
    /// y
    var y: CGFloat {
        get { return frame.origin.y }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.y    = newValue
            frame                 = tempFrame
        }
    }
    
    /// height
    var height: CGFloat {
        get { return frame.size.height }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.height = newValue
            frame                 = tempFrame
        }
    }
    
    /// width
    var width: CGFloat {
        get { return frame.size.width }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.width  = newValue
            frame = tempFrame
        }
    }
    
    /// size
    var size: CGSize {
        get { return frame.size }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size        = newValue
            frame                 = tempFrame
        }
    }
    
    /// centerX
    var centerX: CGFloat {
        get { return center.x }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.x            = newValue
            center                  = tempCenter
        }
    }
    
    /// centerY
    var centerY: CGFloat {
        get { return center.y }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.y            = newValue
            center                  = tempCenter;
        }
    }
}

/// MARK: load nib
protocol TNNibLoadable {}

extension TNNibLoadable {
    static func loadViewFromNib() -> Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! Self
    }
}

/// MARK: register cell
protocol RegisterCellFromNib {}

extension RegisterCellFromNib {
    
    static var identifier: String { return "\(self)" }
    
    static var nib: UINib? { return UINib(nibName: "\(self)", bundle: nil) }
}

extension UITableView {
    
    /// Register Cell
    func tn_registerCell<T: UITableViewCell>(cell: T.Type) where T: RegisterCellFromNib {
        if let nib = T.nib { register(nib, forCellReuseIdentifier: T.identifier) }
        else { register(cell, forCellReuseIdentifier: T.identifier) }
    }
    
    /// Reusing Cell
    func tn_dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: RegisterCellFromNib {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }
}

extension UICollectionView {
    func tn_registerCell<T: UICollectionViewCell>(cell: T.Type) where T: RegisterCellFromNib {
        if let nib = T.nib { register(nib, forCellWithReuseIdentifier: T.identifier) }
        else { register(cell, forCellWithReuseIdentifier: T.identifier) }
    }
    
    func tn_dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T where T: RegisterCellFromNib {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
}

extension UILabel {
    
     static func textSize(text: String , font: UIFont , maxSize: CGSize) -> CGSize {
        return text.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font : font], context: nil).size  
    }
    
    func getAttributeStringWithString(_ string: String, lineSpace: CGFloat
        ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        let paragraphStye = NSMutableParagraphStyle()
        paragraphStye.lineSpacing = lineSpace
        let rang = NSMakeRange(0, CFStringGetLength(string as CFString!))
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStye, range: rang)
        return attributedString
    }
    
    static func textSizeWithLinespace(text: String , font: UIFont , maxSize: CGSize, lineSpace: CGFloat) -> CGSize {
        let paragraphStye = NSMutableParagraphStyle()
        paragraphStye.lineSpacing = lineSpace
        return text.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.paragraphStyle: paragraphStye], context: nil).size
    }
}

extension UIView {
    
    var rx_HighlightState: AnyObserver<Bool> {
        return Binder(self) { view, hightlight in
            view.height = hightlight ? 2.0 : 1.0
            view.backgroundColor = hightlight ? kGlobalColor : UIColor.hexColor(rgbValue: 0xdddddd)
            }.asObserver()
    }
    
    func setupLineView(_ isHightlight: Bool) {
        self.height = isHightlight ? 2.0 : 1.0
        self.backgroundColor = isHightlight ? kGlobalColor : kLineViewColor
    }
}

extension UITextView {
    
    func contentSizeToFit() {
        
        if(self.text.length > 0) {
            var contentSize = self.contentSize
            var offset: UIEdgeInsets = UIEdgeInsets.zero
            var newSize = contentSize
            if contentSize.height <= self.frame.size.height {
                let offsetY = (self.frame.size.height - contentSize.height) / 2
                offset = UIEdgeInsetsMake(offsetY, 0, 0, 0)
            } else {
                newSize = self.frame.size;
                offset = UIEdgeInsets.zero
                var fontSize = 18
                while (contentSize.height > self.frame.size.height)
                {
                    fontSize -= 1
                    self.font = UIFont(name: "PingFangSC-Regular", size: CGFloat(fontSize))
                    contentSize = self.contentSize
                }
                newSize = contentSize
            }
            self.contentSize = newSize
            self.contentInset = offset
        }
    }
}
