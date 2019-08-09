//
//  MQHistoryViewModel.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/6.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

typealias UpdataCallBack = (Array<MQHistoryScanModel>)->(Void)

class MQHistoryViewModel {
    
    var scanModel:MQHistoryScanModel?
    
    var updateModelCallBack:UpdataCallBack?
    
    lazy var resultTool = MQScanResultTool()
    
    func fetchDBData(page: Int,maxPage: Int) -> Void {
        if let callBack = updateModelCallBack  {
            let results = resultTool.fetchAll(limit: maxPage, startPage: page)
            callBack(results)
        }
    }
    
    init(callback: UpdataCallBack?) {
        if let back = callback {
            updateModelCallBack = back
        }
    }
}
