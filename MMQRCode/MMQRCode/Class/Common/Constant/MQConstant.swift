//
//  MQConstant.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/25.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

let MQScreenWidth = UIScreen.main.bounds.size.width;

let MQScreenHeight = UIScreen.main.bounds.size.height;

let MQAdaptScale = MQScreenWidth / 375.0

let MQMainColor = UIColor.mm_colorFromHex(color_vaule: 0x2882fc)

func MQPrintLog<T>(message : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    #if DEBUG
    // 1.获取文件名,包含后缀名
    let name = (file as NSString).lastPathComponent
    // 1.1 切割文件名和后缀名
    let fileArray = name.components(separatedBy: ".")
    // 1.2 获取文件名
    let fileName = fileArray[0]
    // 2.打印内容
    print("[\(fileName) \(funcName)](\(lineNum)): \(message)")
    #endif
}
