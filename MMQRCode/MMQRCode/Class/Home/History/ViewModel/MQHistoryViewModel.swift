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
    
    
    func fetchDBData() -> Void {
        
        if let callBack = updateModelCallBack  {
//            callBack(<#Array<MQHistoryScanModel>#>)
        }
    }
}
