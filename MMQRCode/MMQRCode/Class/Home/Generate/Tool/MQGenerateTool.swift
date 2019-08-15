//
//  MQGenerateTool.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/15.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQGenerateTool {
    class func generateImg(content: String) -> UIImage {
        //1.创建滤镜
        let filter:CIFilter = CIFilter(name: "CIQRCodeGenerator")!
        //1.1 恢复滤镜默认设置
        filter.setDefaults()
        //2. 设置滤镜输入数据
        //2.1 将数据转成nsdata
        let data = content.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        //2.2 设置二维码纠错率
        filter.setValue("H", forKey: "inputCorrectionLevel")
        //3. 从二维码滤镜里面q获取结果图片
        var outputImage = filter.outputImage
        //3.1 放大20倍。高清二维码
        let transform = CGAffineTransform(scaleX: 8, y: 8)
        outputImage = outputImage?.transformed(by: transform)
        let image = UIImage.init(ciImage: outputImage!)
        return image
    }
    
    class func judgeCodeType(content: String) -> ResultType {
        if content.hasPrefix("http://") || content.hasPrefix("https://") {
            return .NetPage
        } else {
            return .OnlyStr
        }
    }
}
