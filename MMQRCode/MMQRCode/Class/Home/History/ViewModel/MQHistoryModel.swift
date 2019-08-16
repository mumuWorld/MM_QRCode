//
//  MQHistoryModel.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/6.
//  Copyright © 2019 yangjie. All rights reserved.
//

import Foundation

struct MQHistoryScanModel {
    var scanID: Int?
    var createTime: String?
    var contentType: Int?
    var scanContent: String?
    var remark: String?
}

struct MQHistoryGenerateModel {
    var generateID: Int?
    var createTime: String?
    var contentType: Int?
    var createContent: String?
    var remark: String?
    var saveImgName: String?  //默认要加后缀 .png
    
}
