//
//  MQHistoryModel.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/6.
//  Copyright © 2019 yangjie. All rights reserved.
//

import Foundation

struct MQHistoryScanModel {
    var createTime: String?
    var contentType: Int?
    var scanContent: String?
    var remark: String?
}

struct MQHistoryCreateModel {
    var createTime: Int?
    var createType: Int?
    var createContent: String?
    var remark: String?
}
