//
//  MQScanHomeVC.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/26.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class MQScanHomeVC: MQBaseViewController {
//    private var _rightItem: UIBarButtonItem?
    
    var scanBgView: UIView!
    var scanLineImgView: UIImageView!
    var scanLineImg_bottom: NSLayoutConstraint!
    
    lazy var preview: UIView = {
        let pre = UIView()
        pre.frame = self.view.bounds
        return pre
    }()
    
    var isScaning:Bool = false
    
    lazy var scanMaskView: MQScanMarkView = {
        let scanMaskView = MQScanMarkView()
        let padding: CGFloat = 44.0;
        let width = MQScreenWidth - padding * 2
        scanMaskView.scanRetangleRect = CGRect(x: padding, y: CGFloat(MQNavigationBarHeight + 100.0), width: width, height: width)
        scanMaskView.frame = self.view.bounds
        scanMaskView.photoframeLineW = 2;
        return scanMaskView
    }()
    
    var rightItem: UIBarButtonItem {
        get {
            let _rightItem = UIBarButtonItem.barButtomItem(title: "相册", selectedTitle: nil, titleColor: MQMainColor, selectedColor: nil, image: nil, selectedImg: nil, target: self, selecter: #selector(handleBtnClick(sender:)))
            return _rightItem
        }
    }
    
    var saveCheckStatus:AVAuthorizationStatus?
    lazy var scanTool:MQScanTool = {
        let tool = MQScanTool()
        return tool
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        saveCheckStatus = .notDetermined
        setupSubViews()
        self.scanTool.resultDelegate = self
        self.scanTool.scanMaskView = scanMaskView
        self.scanTool.preview = preview
        self.scanTool.checkupAuthorization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recoverNavigationBar()
        scanTool.stopScaning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarAlpha()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanTool.startScaning()
    }
    
    @objc func handleBtnClick(sender: UIButton) -> Void {
        MQPrintLog(message: "调取相册")
        MQAuthorization.checkPhotoLibraryPermission(authorizedBlock: { (success) in
            let pickerVC = UIImagePickerController()
            pickerVC.delegate = self.scanTool
            pickerVC.sourceType = .photoLibrary
            self.navigationController?.present(pickerVC, animated: true, completion: nil)
        }) { (deninit) in
            self.showSettingAlert(content: "需要开启访问相册权限")
        }
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//
//        let pickerVC = UIImagePickerController()
//        pickerVC.delegate = self
//        pickerVC.sourceType = .photoLibrary
//        self.navigationController?.present(pickerVC, animated: true, completion: nil)
//        } else {
//            self.showSettingAlert(content: "需要开启访问相册权限")
//        }
    }
}

// MARK: - 工具方法
extension MQScanHomeVC {
    func showSettingAlert(content: String) -> Void {
        let alert = UIAlertController.alert(title: "提示", content: content, confirmTitle: "去设置", confirmHandler: { (_) in
            let settingUrl = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(settingUrl!) {
                UIApplication.shared.openURL(settingUrl!)
            }
        }, cancelTitle: "取消", cancelHandler: nil)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func setupSubViews() -> Void {
        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationItem.title = "二维码/条码"
        self.view.addSubview(self.preview);
        self.view.addSubview(self.scanMaskView)
    }
    

}

// MARK: - 扫描结果代理
extension MQScanHomeVC: MQScanResultProtocol {
    
    func mqScanResult(tool: MQScanTool?, scanStatus: MQScanStatus, scanResult: [String]?, error: String?) {
        if scanStatus == .success {
            if let resultArr = scanResult, resultArr.count > 0 {
                let resultVC:MQScanResultVC = UIStoryboard(name: "MQHome", bundle: nil).instantiateViewController(withIdentifier: "MQScanResultVC") as! MQScanResultVC
                resultVC.resultData = resultArr
                resultVC.needToSaveDB = true
                self.navigationController?.pushViewController(resultVC, animated: true)
            }
        } else if scanStatus == .failed {
            let alert = UIAlertController.alertOnlyConfirm(title: "提示", content: error ?? "", confirmTitle: "确定")
            self.navigationController?.present(alert, animated: true, completion: nil)
        } else { //没有权限
            showSettingAlert(content: "需要开启相机权限才能进行扫描")
        }
    }
}

extension MQScanHomeVC {
    @objc override func naviBarPopItemStyle() -> PopItemStyle {
        return .PopItemWhite
    }
}
