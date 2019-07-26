//
//  MQImageLabelCVCell.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/25.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQImageLabelCVCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    private var _dataSource: Dictionary<String, Any>?
    var dataSource: Dictionary<String, Any>? {
        set {
            if let title = newValue!["title"] {
                titleLabel.text = title as? String
            }
            if let img = newValue!["img"] {
                imageView.image = UIImage(named: img as! String)
            }
        }
        get {
            if let data = _dataSource {
                return data
            }
            return Dictionary()
        }
    }
    
    
}
