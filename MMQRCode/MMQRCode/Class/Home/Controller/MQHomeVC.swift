//
//  MQHomeVC.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/25.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQHomeVC: MQBaseViewController {

    @IBOutlet weak var mainCollectionView: UICollectionView!
    var pushArray: Array<String> {
        get {
            return ["MQScanHomeVC","MQHistoryVC","MQScanHomeVC","MQScanHomeVC"]
        }
    }
    
    var itemArray: Array<Dictionary<String, Any>> {
        get {
            let arr = [["img":"scan_icon_btn","title":"扫一扫"],
                       ["img":"scan_icon_btn","title":"扫描记录"],
                       ["img":"scan_icon_btn","title":"生成二维码"],
                       ["img":"scan_icon_btn","title":"生成记录"],
                       ]
            return arr
        }
    }
    
    var scanClickView: MQScanClickView?

    var transitionMan: MQHomeTransitionManager?
    
    lazy var photoLibraryBtn: UIButton = {
        let btn = createBtn(type: 0)
        return btn
    }()
    
    lazy var generateQRBtn: UIButton = {
        let btn = createBtn(type: 1)
        return btn
    }()
    
    lazy var scanTool: MQScanTool = {
        let tool = MQScanTool()
        tool.resultDelegate = self
        return tool
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.barTintColor = UIColor.mm_colorFromHex(color_vaule: 0x2882fc,alpha: 0.0)
        setupSubView()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIColor.mm_colorImgHex(color_vaule: 0x2882fc,alpha: 0.1), for: UIBarPosition.any, barMetrics: .default)
        self.navigationController?.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = nil
    }
    
    func setupLayout() -> () {
        if #available(iOS 11.0, *) {
            self.mainCollectionView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        let layout = self.mainCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let width = MQScreenWidth / 4.0
        layout.itemSize = CGSize(width: width, height: 100)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
    }
    
    /// 处理点击事件
    ///
    /// - Parameter sender: btn
    @objc func handleBtnClick(sender: UIButton) -> Void {
        if sender.tag == 10 {
            MQAuthorization.checkPhotoLibraryPermission(authorizedBlock: { (success) in
                let pickerVC = UIImagePickerController()
                pickerVC.delegate = self.scanTool
                pickerVC.sourceType = .photoLibrary
                self.navigationController?.present(pickerVC, animated: true, completion: nil)
            }) { (deninit) in
                self.showSettingAlert(content: "需要开启访问相册权限")
            }
        } else {
            let showVC:MQGenerateInputVC = UIStoryboard(name: "MQHome", bundle: nil).instantiateViewController(withIdentifier: "MQGenerateInputVC") as! MQGenerateInputVC
            self.navigationController?.pushViewController(showVC, animated: true)
        }
    }
    
    func showSettingAlert(content: String) -> Void {
        let alert = UIAlertController.alert(title: "提示", content: content, confirmTitle: "去设置", confirmHandler: { (_) in
            let settingUrl = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(settingUrl!) {
                UIApplication.shared.openURL(settingUrl!)
            }
        }, cancelTitle: "取消", cancelHandler: nil)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension MQHomeVC {
    func setupSubView() -> Void {
        scanClickView = MQScanClickView()
        scanClickView?.frame = CGRect(x: 0, y: view.mm_height - 200, width: 50, height: 200)
        scanClickView?.mm_centerX = view.mm_width * 0.5
        scanClickView?.callBack = { [weak self] (type) in
            self?.transitionMan = MQHomeTransitionManager()
            let tView = self?.scanClickView!.scanBtn
            let fitRect = tView!.convert(tView!.frame, to: UIApplication.shared.keyWindow)
            self?.transitionMan?.setParam(startRect: fitRect, topView: tView!)
            self?.navigationController?.delegate = self?.transitionMan
            self?.pushToVC(index: 0)
        }
        view.addSubview(scanClickView!)
        view.addSubview(photoLibraryBtn)
        view.addSubview(generateQRBtn)
    }
    
    func pushToVC(index: Int) -> Void {
        guard index < pushArray.count else {
            return
        }
        let vcStr = pushArray[index]
        let vc = UIStoryboard(name: "MQHome", bundle: nil).instantiateViewController(withIdentifier: vcStr)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func createBtn(type: Int) -> UIButton {
        let btn = UIButton.buttonWith(title: nil, selectedTitle: nil, titleColor: nil, selectedColor: nil, image: type == 0 ? "photo_library_btn" : "generate_qrcode_btn", selectedImg: nil, target: self, selecter: #selector(handleBtnClick(sender:)), tag: type == 0 ? 10 : 11)
        let y = MQScreenHeight - MQHomeIndicatorHeight - 44 - 48
        btn.frame = CGRect(x: 0, y: y, width: 48, height: 48)
        btn.mm_centerX = type == 0 ? self.view.mm_width * 0.25 : self.view.mm_width * 0.75
        btn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        btn.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
        btn.layer.cornerRadius = 24
        return btn
    }
}

extension MQHomeVC: MQScanResultProtocol {
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

extension MQHomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MQImageLabelCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MQImageLabelCVCell", for: indexPath) as! MQImageLabelCVCell
        cell.dataSource = itemArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemArray.count
    }
}

extension MQHomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vcStr = pushArray[indexPath.row]
        let vc = UIStoryboard(name: "MQHome", bundle: nil).instantiateViewController(withIdentifier: vcStr)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
