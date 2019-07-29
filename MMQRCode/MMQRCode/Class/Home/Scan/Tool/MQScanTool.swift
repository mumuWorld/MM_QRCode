//
//  MQScanTool.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/29.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQScanTool {
    lazy var dector:CIDetector = {
        let _dector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        return _dector
    }()
    
    func scanImg(sourceImg: UIImage?,successResult: (([String]) ->Void)?,failed:((String)->())? ) {
        guard let _sourceImg = sourceImg else {
            if failed != nil {
                failed!("image 不能为空")
            }
            return
        }
        let ciImg = CIImage(image: _sourceImg)
        guard let sourceCIImg = ciImg else {
            if failed != nil {
                failed!("image 识别失败")
            }
            return
        }
        let results = self.dector.features(in: sourceCIImg)
        if results.count <= 0 {
            if failed != nil {
                failed!("未识别到有效二维码")
            }
            return
        }
        var messages:[String] = Array()

        for result in results {
            let qrFeature = result as! CIQRCodeFeature
            if let message = qrFeature.messageString {
                messages.append(message)
            }
        }
        if successResult != nil {
            successResult!(messages)
        }
    }
}
