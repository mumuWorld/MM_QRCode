//
//  NSDate+MM_Extension.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/6.
//  Copyright © 2019 yangjie. All rights reserved.
//

import Foundation

enum kDateFormatterKey: String {
    case Default = "yyyy-MM-dd HH:mm:ss"
    case ShortYMD = "yyyy-MM-dd"
}

extension Date {
    static let shareFormatter: DateFormatter = DateFormatter()
}
