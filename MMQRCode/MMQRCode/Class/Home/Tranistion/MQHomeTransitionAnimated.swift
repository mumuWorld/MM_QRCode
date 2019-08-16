//
//  MQHomeTransitionAnimated.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/14.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQHomeTransitionAnimated: NSObject, UIViewControllerAnimatedTransitioning {
    var startRect: CGRect?
    
    var tmpToView: UIView?
    
    var maskLayer: CAShapeLayer = CAShapeLayer()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let toVC = transitionContext.viewController(forKey: .to)

        
        let fromView = transitionContext.viewController(forKey: .from)?.view
        fromView?.frame = containerView.bounds
        containerView.addSubview(fromView!)
        
        let toView = toVC?.view
        toView?.frame = containerView.bounds
        containerView.addSubview(toView!)
        
//        tmpToView = UIView(frame: containerView.bounds)
//        tmpToView!.backgroundColor = UIColor.mm_colorFromHex(color_vaule: 0x2882fc, alpha: 0.6)
//        containerView.addSubview(tmpToView!)
        
        guard let tStartRect = startRect else {
            return
        }
        let center_x = tStartRect.mm_x + tStartRect.mm_width * 0.5
        let center_y = tStartRect.mm_y + tStartRect.mm_width * 0.5
        let maxX = max(center_x, containerView.mm_width - center_x)
        let maxY = max(center_y, containerView.mm_height - center_y)
        // x^2 + y^2 开根号
        let radius = sqrt(pow(maxX, 2) + pow(maxY, 2))
        
        let startPath: UIBezierPath = UIBezierPath(roundedRect: tStartRect, cornerRadius: tStartRect.mm_width)
        let endPath = UIBezierPath(arcCenter: CGPoint(x: center_x, y: center_y), radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        maskLayer = CAShapeLayer()
//        tmpToView!.layer.mask = maskLayer
        toView?.layer.mask = maskLayer
        
        let maskLayerAnimate: CABasicAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimate.fromValue = startPath.cgPath
        maskLayerAnimate.toValue = endPath.cgPath
        maskLayerAnimate.duration = 0.4
        maskLayerAnimate.delegate = self
        maskLayerAnimate.isRemovedOnCompletion = false
        maskLayerAnimate.fillMode = CAMediaTimingFillMode.forwards
        maskLayerAnimate.timingFunction = .easeIn
        maskLayerAnimate.setValue(transitionContext, forKey: "transitionContext")
        maskLayerAnimate.setValue(fromView, forKey: "fromView")

        maskLayer.add(maskLayerAnimate, forKey: "maskLayerAnimate")
    }
}

extension MQHomeTransitionAnimated: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if maskLayer.animation(forKey: "maskLayerAnimate") == anim {
//            let fromView = anim.value(forKey: "fromView") as? UIView
            
            UIView.animate(withDuration: 0.2, animations: {
//                self.tmpToView?.alpha = 0
//                fromView!.alpha = 0
            }) { (_) in
//                self.maskLayer.removeAllAnimations()
//                self.tmpToView?.removeFromSuperview()
//                self.tmpToView = nil
                self.maskLayer.removeFromSuperlayer()
                if let context = anim.value(forKey: "transitionContext") as? UIViewControllerContextTransitioning {
                    context.completeTransition(true)
                }
//                fromView!.alpha = 1
            }
        }
    }
}
