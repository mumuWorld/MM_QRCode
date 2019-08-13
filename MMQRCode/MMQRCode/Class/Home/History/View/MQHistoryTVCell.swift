//
//  MQHistoryTVCell.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/6.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQHistoryTVCell: UITableViewCell {
    
    @IBOutlet weak var iconImg: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var separatorLineView: UIView!
    
    var _historyModel:MQHistoryScanModel?
    var historyModel: MQHistoryScanModel? {
        set {
            _historyModel = newValue
            guard let model = newValue else { return }
            
            if let remark = model.remark,remark.count > 0 {
                self.contentLabel.text = remark
            } else {
                self.contentLabel.text = model.scanContent
            }
            
            if let createTime = model.createTime, createTime.count > 0 {
                self.timeLabel.text = createTime
            }
            
            if 0 == model.contentType { //文本
                
            }
        }
        get {
            return _historyModel
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
