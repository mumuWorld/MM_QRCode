//
//  MQHomeTransitionManager.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/14.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQHomeTransitionManager: NSObject {
    var transitionAnimate: MQHomeTransitionAnimated?
    
    func setParam(startRect: CGRect, topView: UIView) -> Void {
        transitionAnimate = MQHomeTransitionAnimated()
        transitionAnimate?.startRect = startRect
    }
}

extension MQHomeTransitionManager: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return transitionAnimate
        }
        return nil
    }
}
