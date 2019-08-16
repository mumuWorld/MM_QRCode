//
//  MQHistoryViewModel.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/6.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

typealias UpdataCallBack = (Array<MQHistoryScanModel>?, Array<MQHistoryGenerateModel>?)->(Void)

class MQHistoryViewModel {
    
    var scanModel:MQHistoryScanModel?
    
    var updateModelCallBack:UpdataCallBack?
    
    lazy var resultTool = MQScanResultTool()
    
    lazy var generateTool = MQGenerateTool()
    
    func fetchDBData(page: Int,maxPage: Int) -> Void {
        if let callBack = updateModelCallBack  {
            let results = resultTool.fetchAll(limit: maxPage, startPage: page)
            callBack(results,nil)
        }
    }
    
    func fetchGenerateData(page: Int, maxPage: Int) -> Void {
        if let callBack = updateModelCallBack  {
            let results = generateTool.fetchAll(limit: maxPage, startPage: page)
            callBack(nil,results)
        }
    }
    
    init(callback: UpdataCallBack?) {
        if let back = callback {
            updateModelCallBack = back
        }
    }
}
