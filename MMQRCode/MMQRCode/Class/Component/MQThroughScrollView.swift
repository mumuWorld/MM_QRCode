//
//  MQThroughScrollView.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/9.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQThroughScrollView: UIScrollView,UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.state.rawValue != 0 {
            return true
        }
//        let gesture = String(describing: type(of: otherGestureRecognizer))
//        if "_UISwipeActionPanGestureRecognizer" == gesture {
//            return true
//        }
        return false
    }
}
