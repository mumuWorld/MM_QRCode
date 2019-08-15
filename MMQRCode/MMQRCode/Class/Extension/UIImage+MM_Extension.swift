//
//  UIImage+MM_Extension.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/15.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func mm_imageWithView(view: UIView) -> UIImage? {
        let rect: CGRect = view.bounds
        if rect.isEmpty || rect.isNull || rect.isInfinite || view.superview == nil || view.window == nil || view.window!.isHidden {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(rect.size, view.isOpaque, 0.0);
        
        var snapImg: UIImage?
        let drawSuccess: Bool = view.drawHierarchy(in: rect, afterScreenUpdates: false)
        if drawSuccess {
            snapImg = UIGraphicsGetImageFromCurrentImageContext()
        } else {
            view.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        snapImg = UIGraphicsGetImageFromCurrentImageContext()
        return snapImg
    }
    
    @objc func test(in: Int, sefsef: UIView) -> Void {
        
    }
}
