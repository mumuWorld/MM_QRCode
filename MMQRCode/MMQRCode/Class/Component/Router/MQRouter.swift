//
//  MQRouter.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/2.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQRouter {
    public static var `shareRouter`: MQRouter = MQRouter()

    lazy var cacheTarget:[String: Any] = Dictionary()
    
    func performTarget(target: String, action: String, params: Dictionary<String, Any>, shouldCacheTarget: Bool = false) -> Any {
        
        
        return 0
    }
}
