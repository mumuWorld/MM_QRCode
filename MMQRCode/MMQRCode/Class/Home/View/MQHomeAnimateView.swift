//
//  MQHomeAnimateView.swift
//  MMQRCode
//
//  Created by mumu on 2019/8/21.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQHomeAnimateView: UIView {

    var imageView: UIImageView = UIImageView()
    
    var image: UIImage? {
        set {
            guard let newImage = newValue else { return }
            imageView.image = newImage
        }
        get {
            return imageView.image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        self.layer.cornerRadius = 2
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.mm_size = CGSize(width: mm_width - 10, height: mm_height - 10)
        imageView.center = CGPoint(x: mm_width * 0.5, y: mm_height * 0.5)
    }
    
    func startAnimate() -> Void {
        UIView.animate(withDuration: 2) {
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.mm_y = MQScreenHeight - MQHomeIndicatorHeight - 44 - 48 - 80
        }
    }
    
    func stopAnimate() -> Void {
        self.layer.removeAllAnimations()
    }
}
