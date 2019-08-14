//
//  MQAuthorization.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/14.
//  Copyright © 2019 yangjie. All rights reserved.
//

import Foundation
import Photos

class MQAuthorization {
    
    /// 请求相册权限
    ///
    /// - Parameters:
    ///   - authorizedBlock: 同意
    ///   - deniedBlock: 拒绝
    class func checkPhotoLibraryPermission(authorizedBlock: ((PHAuthorizationStatus) -> Void)?, deniedBlock: ((PHAuthorizationStatus) -> Void)?) -> Void {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .notDetermined {
            // 第一次触发授权 alert
            PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
                if status == .authorized  {
                    if authorizedBlock != nil {
                        authorizedBlock!(status)
                    }
                } else {
                    if deniedBlock != nil {
                        deniedBlock!(status)
                    }
                }
            }
        } else if authStatus == .authorized  {
            if authorizedBlock != nil {
                authorizedBlock!(authStatus)
            }
        } else {
            if deniedBlock != nil {
                deniedBlock!(authStatus)
            }
        }
    }
}
