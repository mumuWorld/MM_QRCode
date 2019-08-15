//
//  MQShowQRCodeVC.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/15.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit
import Photos

class MQShowQRCodeVC: MQBaseViewController {
    
    var sourceContent: String?
    
    @IBOutlet weak var showQRImg: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var contentTypeIcon: UIImageView!
    
    var rightItem: UIBarButtonItem {
        get {
            let _rightItem = UIBarButtonItem.barButtomItem(title: nil, selectedTitle: nil, titleColor: nil, selectedColor: nil, image: "more_navi_btn", selectedImg: nil, target: self, selecter: #selector(handleBtnClick(sender:)))
            return _rightItem
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "生成二维码"
        self.navigationItem.rightBarButtonItem = rightItem
        DispatchQueue.main.async {
            self.handleSourceContent()
        }
    }
    
    @IBAction func editCurrentTitle(_ sender: Any) {
        
    }
    
}

extension MQShowQRCodeVC {
    @objc func handleBtnClick(sender: UIButton) -> Void {
        let moreArr: [String] = ["保存到相册"]
        
        let alert = UIAlertController.alertSheet(title: "更多", message: nil, content: moreArr, cancelTitle: "取消", confirmHandler: { (index) in
            MQAuthorization.checkPhotoLibraryPermission(authorizedBlock: { (status) in
                DispatchQueue.main.async {
                    self.saveToLibraryCollection()
                }
            }, deniedBlock: { (status) in
                DispatchQueue.main.async {
                    self.showAlert()
                }
            })
        }, cancelHandler: nil)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func showAlert() -> Void {
        let alert = UIAlertController.alert(title: "提示", content: "需要开启访问相册权限", confirmTitle: "去设置", confirmHandler: { (_) in
            let settingUrl = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(settingUrl!) {
                UIApplication.shared.openURL(settingUrl!)
            }
        }, cancelTitle: "取消", cancelHandler: nil)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func saveToLibraryCollection() -> Void {
        
        guard self.showQRImg.image != nil else { return }
        
        guard let saveImg = UIImage.mm_imageWithView(view: self.showQRImg) else {
            return
        }
        var placeholder: PHObjectPlaceholder?
            PHPhotoLibrary.shared().performChanges({
                placeholder = PHAssetChangeRequest.creationRequestForAsset(from: saveImg).placeholderForCreatedAsset
            }) { (complete, error) in
                if complete {
                    DispatchQueue.main.async {
                        self.saveToCollection(placeholder: placeholder)
                    }
                } else {
                    MQPrintLog(message: error)
                }
            }
    }
    func saveToCollection(placeholder: PHObjectPlaceholder?) -> Void {
        //判断是否创建图片库成功
        guard let photoObject = placeholder else { return }
        
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        var existCollection: PHAssetCollection?
        collections.enumerateObjects { (collection, type, stop) in
            if collection.localizedTitle == MQPhotoLibraryName {
                existCollection = collection
                stop.pointee = true
            }
        }
        //没有相册 创建相册
        if let _ = existCollection {
            
        } else {
            var collectionID: String?
            do {
                try PHPhotoLibrary.shared().performChangesAndWait {
                    collectionID = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: MQPhotoLibraryName).placeholderForCreatedAssetCollection.localIdentifier
                }
            } catch {
                MQPrintLog(message: error)
            }
            guard (collectionID != nil) else { return }
            existCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [collectionID!], options: nil).firstObject
        }
        //此时相册创建成功，添加到图库
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                let request = PHAssetCollectionChangeRequest(for: existCollection!)
                request?.insertAssets([photoObject] as NSFastEnumeration, at: IndexSet.init(integer: 0))
            }
        } catch {
            MQPrintLog(message: error)
        }
        MQToastView.show(message: "保存成功")
    }
    
    func handleSourceContent() -> Void {
        guard let sourceData = sourceContent else { return }
        
        contentLabel.text = sourceData
        //判断类型
        let type = MQGenerateTool.judgeCodeType(content: sourceData)
        if type == .OnlyStr {
            contentTypeIcon.image = UIImage.init(named: "text_type_img")
        } else if type == .NetPage {
            contentTypeIcon.image = UIImage.init(named: "net_type_img")
        }
        
        let img = MQGenerateTool.generateImg(content: sourceData)
        self.showQRImg.image = img
    }
}
