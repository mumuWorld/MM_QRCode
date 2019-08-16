//
//  MQLoadingView.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/16.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQLoadingView: UIView {

    @IBOutlet weak var conntentView: UIView!
    @IBOutlet weak var loadingImgView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!

    @IBOutlet weak var loadingImg_centerY: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let text = loadingLabel.text, text.count > 0 {
            loadingImg_centerY.constant = -10
        }
    }
}

extension MQLoadingView {
    class func showLoadingView(label: String? = nil) -> Void {
        
    }
    
    
}
