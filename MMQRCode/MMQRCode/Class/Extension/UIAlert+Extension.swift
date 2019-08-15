//
//  UIAlert+Extension.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/26.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func alert(title: String?, content: String?, confirmTitle: String?, confirmHandler: ((UIAlertAction) -> Void)? = nil, cancelTitle: String?, cancelHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertC = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmTitle ?? "确定", style: .default) { (action: UIAlertAction) in
            guard let confirm = confirmHandler else {
                return
            }
            confirm(action)
        }
        let cancelAction = UIAlertAction(title: cancelTitle ?? "取消", style: .cancel) { (action: UIAlertAction) in
            guard let cancel = cancelHandler else {
                return
            }
            cancel(action)
        }
        alertC.addAction(confirmAction)
        alertC.addAction(cancelAction)
        return alertC
    }
    
    class func alertOnlyConfirm(title: String?, content: String?, confirmTitle: String?, confirmHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertC = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmTitle ?? "确定", style: .default) { (action: UIAlertAction) in
            guard let confirm = confirmHandler else {
                return
            }
            confirm(action)
        }
        alertC.addAction(confirmAction)
        return alertC
    }
    
    class func alertSheet(title: String?, message: String?, content: [String], cancelTitle: String?, confirmHandler: ((Int) -> Void)? = nil, cancelHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        var index = 0
        for tStr in content {
            let action = UIAlertAction(title: tStr, style: .default) { (_) in
                guard let confirm = confirmHandler else {
                    return
                }
                confirm(index)
            }
            index += 1
            alert.addAction(action)
        }
        
        if let cancelT = cancelTitle {
            let action = UIAlertAction(title: cancelT, style: .cancel) { (act) in
                guard let cancel = cancelHandler else {
                    return
                }
                cancel(act)
            }
            alert.addAction(action)
        }
        
        return alert
    }
}
