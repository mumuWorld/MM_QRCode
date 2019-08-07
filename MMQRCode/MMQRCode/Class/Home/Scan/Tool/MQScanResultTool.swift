//
//  MQScanResultTool.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/7.
//  Copyright © 2019 yangjie. All rights reserved.
//

import Foundation
import SQLite

let _time = Expression<Int>("create_time")
let _remark = Expression<String>("remark_name")
let _contentType = Expression<Int>("content_type")
let _content = Expression<String>("scan_content")
let _id = Expression<Int>("id")

class MQScanResultTool {
    var table: Table?
    
    init() {
        table = MQDBManager.shareManager.createTable(name: "scanResult") { (builder) in
            builder.column(_id,primaryKey: true)
            builder.column(_content)
            builder.column(_contentType)
            builder.column(_remark)
            builder.column(_time)
        }
    }
    
    func saveScanHistory(content: String, type: Int,remark: String = "") -> Void {
        let isExist = exist(content: content, type: type)
        let time = Date.currentTimeStamp()
        if isExist { //更新时间
            let update = table?.filter(_content == content && _contentType == type)
            
            if let count = try? MQDBManager.shareManager.shareDB?.run((update?.update(_time <- time, _remark <- remark))!) {
                MQPrintLog(message: "更新g成功=\(count)")
            } else {
                MQPrintLog(message: "更新失败")
            }
        } else {
            let insert = table?.insert(_content <- content, _contentType <- type, _remark <- remark, _time <- time)
            if let rowID = try? MQDBManager.shareManager.shareDB?.run(insert!) {
                MQPrintLog(message: "插入成功=\(rowID)")
            } else {
                MQPrintLog(message: "插入失败")
            }
        }
        
    }
    
    func exist(content: String, type: Int) -> Bool {
        let query = table?.filter(_content == content && _contentType == type)
        do {
            let count = try MQDBManager.shareManager.shareDB?.scalar(query!.count)
            return count != 0
        } catch {
            MQPrintLog(message: error)
        }
        return true
    }
    
    func fetchAll(limit: Int = 20, startPage: Int = 0) -> [MQHistoryScanModel] {
        let query = table?.order(_time.desc).limit(limit, offset: startPage * limit)
        var resultArr: [MQHistoryScanModel] = Array()
        
        do {
            let results = try MQDBManager.shareManager.shareDB?.prepare(query!)
            if let tResults = results {
                for result in tResults {
                    var model = MQHistoryScanModel()
                    model.contentType = result[_contentType]
                    model.remark = result[_remark]
                    model.scanContent = result[_content]
                    model.createTime = Date.dateStr(timeStamp: result[_time], formatter: kDateFormatterKey.ShortYMDHM)
                    resultArr.append(model)
                }
            }
        } catch {
            MQPrintLog(message: error)
        }
        return resultArr
    }
}
