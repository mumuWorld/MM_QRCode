//
//  MQGenerateTool.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/15.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit
import SQLite

class MQGenerateTool {
    var table: Table?

    init() {
        table = MQDBManager.shareManager.createTable(name: "generateResult") { (builder) in
            builder.column(_id,primaryKey: true)
            builder.column(_content)
            builder.column(_contentType)
            builder.column(_remark)
            builder.column(_time)
            builder.column(_saveImg)
        }
    }
    
    func saveGenerateHistory(content: String, type: Int,remark: String = "", saveImg: UIImage) -> Void {
        let time = Date.currentTimeStamp()
        let imgName = String(time)
        
        let result = MQFileManager.share.saveFileToDisk(saveData: saveImg, saveName: imgName)
        MQPrintLog(message: "保存图片 -> \(result ? " 成功" : "失败")")
//        if isExist { //更新时间
//            let update = table?.filter(_content == content && _contentType == type)
//
//            if let count = try? MQDBManager.shareManager.shareDB?.run((update?.update(_time <- time, _remark <- remark))!) {
//                MQPrintLog(message: "更新成功=\(count)")
//            } else {
//                MQPrintLog(message: "更新失败")
//            }
//        } else {
            let insert = table?.insert(_content <- content, _contentType <- type, _remark <- remark, _time <- time, _saveImg <- imgName)
            if let rowID = try? MQDBManager.shareManager.shareDB?.run(insert!) {
                MQPrintLog(message: "插入成功=\(rowID)")
            } else {
                MQPrintLog(message: "插入失败")
            }
//        }
    }
    
    func fetchAll(limit: Int = 20, startPage: Int = 0) -> [MQHistoryGenerateModel] {
        let query = table?.order(_time.desc).limit(limit, offset: startPage * limit)
        var resultArr: [MQHistoryGenerateModel] = Array()
        
        do {
            let results = try MQDBManager.shareManager.shareDB?.prepare(query!)
            if let tResults = results {
                for result in tResults {
                    var model = MQHistoryGenerateModel()
                    model.generateID = result[_id]
                    model.contentType = result[_contentType]
                    model.remark = result[_remark]
                    model.createContent = result[_content]
                    model.createTime = Date.dateStr(timeStamp: result[_time], formatter: kDateFormatterKey.ShortYMDHM)
                    model.saveImgName = result[_saveImg]
                    resultArr.append(model)
                }
            }
        } catch {
            MQPrintLog(message: error)
        }
        return resultArr
    }

    
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
