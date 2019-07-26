//
//  UIBarButtonItem+MM_Extension.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/26.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func barButtomItem(title: String?, selectedTitle: String?, titleColor: UIColor?, selectedColor: UIColor?, image: String?, selectedImg: String?, target: Any?, selecter: Selector?, tag: UInt = 10) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        if let tmpTit = title {
            button .setTitle(tmpTit, for: .normal)
            if let tmpColor = titleColor {
                button.setTitleColor(tmpColor, for: .normal)
            }
        }
        if let tmpTit = selectedTitle {
            if let tmpColor = selectedColor {
                button.setTitleColor(tmpColor, for: .selected)
            }
            button .setTitle(tmpTit, for: .selected)
        }
        if let tmpImg = image {
            button.setImage(UIImage.init(named: tmpImg), for: .normal)
        }
        if let tmpImg = selectedImg {
            button.setImage(UIImage.init(named: tmpImg), for: .selected)
        }
        if let tmpTarget = target,let tmpSel = selecter {
            button.addTarget(tmpTarget, action: tmpSel, for: .touchUpInside)
        }
        button.tag = Int(bitPattern: tag)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let item = UIBarButtonItem(customView: button)
        return item
    }
}
