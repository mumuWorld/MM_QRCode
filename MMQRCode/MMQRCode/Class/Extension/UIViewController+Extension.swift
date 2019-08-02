//
//  UIViewController+Extension.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/29.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

protocol MQViewLoadSubViewProtocol {
    func initSubViews() -> Void
}

extension UIViewController {
    func setNavigationBarAlpha() -> Void {
        if self.navigationController != nil {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
    func recoverNavigationBar() -> Void {
        if self.navigationController != nil {
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//            self.navigationController?.navigationBar.shadowImage = nil
        }
    }
}
