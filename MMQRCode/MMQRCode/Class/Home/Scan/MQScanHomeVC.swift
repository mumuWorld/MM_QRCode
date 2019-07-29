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
    
    lazy var session:AVCaptureSession = {
        let session = AVCaptureSession()
        return session
    }()
    /// 预览图层
    lazy var preLayer:AVCaptureVideoPreviewLayer = {
        return AVCaptureVideoPreviewLayer(session: session)
    }()
    
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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        saveCheckStatus = .notDetermined
        setupSubViews()
        checkupAuthorization()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recoverNavigationBar()
        stopScanAnimation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarAlpha()
        startScanAnimation()
    }
    @objc func handleBtnClick(sender: UIButton) -> Void {
        MQPrintLog(message: "调取相册")
    }
    
    func startScanAnimation() -> Void {
        session.startRunning()
        scanMaskView.startScanAnimation()
        isScaning = true;
    }
    func stopScanAnimation() -> Void {
        session.stopRunning()
        scanMaskView.stopScanAnimation()
        isScaning = false;
    }
}
extension MQScanHomeVC {
    func showSettingAlert() -> Void {
        let alert = UIAlertController.alert(title: "提示", content: "需要开启相机权限才能进行扫描", confirmTitle: "去设置", confirmHandler: { (_) in
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
    func checkupAuthorization() -> Void {
        if saveCheckStatus == .authorized {
            shouldScan()
            return
        } else if saveCheckStatus == AVAuthorizationStatus.denied {
            showSettingAlert()
            return
        }
        saveCheckStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if saveCheckStatus == AVAuthorizationStatus.notDetermined {
            // 第一次触发授权 alert
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.saveCheckStatus = .authorized
                     DispatchQueue.main.async {
                    self.shouldScan()
                    }
                    
                } else {
                    self.saveCheckStatus = .denied
                    self.showSettingAlert()
                }
//                self.cameraPermissions(authorizedBlock: authorizedBlock, deniedBlock: deniedBlock)
            })
        } else if saveCheckStatus == AVAuthorizationStatus.authorized {
            MQPrintLog(message: "status=\(saveCheckStatus!.rawValue)")
        } else {
            showSettingAlert()
            return
        }
        shouldScan()
    }
    func shouldScan() -> Void {
        if !isScaning {
            self.startScan()
        }
    }
    func startScan() -> Void {
        //1 设置输入
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        var input:AVCaptureInput?
        do {
            try input = AVCaptureDeviceInput(device: device!)
        } catch let err {
            print("err= \(err)")
        }
        //2 设置输出
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //3 创建会话，链接输入和输出
        if session.canAddInput(input!) && session.canAddOutput(output) {
            session.addInput(input!)
            session.addOutput(output)
        }
        //3.1 设置二维码可以识别的码制。
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        //3.2 添加视频预览图层
        preLayer.frame = self.view.bounds
        self.preview.layer.insertSublayer(preLayer, at: 0)
//        self.scanMaskView.layer.insertSublayer(preLayer, at: 0)
        //3.3 设置兴趣区域
        // 注意, 此处需要填的rect, 是以右上角为(0, 0), 也就是横屏状态
        // 值域范围: 0->1
        let sWidth = MQScreenWidth
        let sHeight = MQScreenHeight
        let x = 30.0/sWidth
        let y = CGFloat(MQNavigationBarHeight + 100)/sHeight
        let widthT = MQScreenWidth - 30 * 2.0
        
        let width = widthT/sWidth
        let height = widthT/sHeight
        //设置采集扫描区域的比例 默认全屏是（0，0，1，1）
        //rectOfInterest 填写的是一个比例，输出流视图preview.frame为 x , y, w, h, 要设置的矩形快的scanFrame 为 x1, y1, w1, h1. 那么rectOfInterest 应该设置为 CGRectMake(y1/y, x1/x, h1/h, w1/w)。
        output.rectOfInterest = CGRect(x: y, y: x, width: height, height: width)
        
        //4 启动会话 （让输入开始采集数据，输出对象处理数据）
//        session.startRunning()
    }
}
extension MQScanHomeVC: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //画之前 ，移除上一次绘制的 frame
        removeQRcodeFrame()
        //直接要第一个
        
        //遍历输出数组
        for metaObject in metadataObjects {
            if metaObject.isKind(of: AVMetadataMachineReadableCodeObject.self) {
                let resultObj = preLayer.transformedMetadataObject(for: metaObject)
                
                let obj = resultObj as! AVMetadataMachineReadableCodeObject
                MQPrintLog(message: "message \(obj.stringValue ?? "")")
                //                corners代表二维码的四个角，但是需要预览图层，转换成我们需要的可用的坐标。
                //                [(50.52805463348426, 240.47635589036352), (52.81510895931001, 311.85075811638114), (124.59585025601314, 315.18543130468424), (125.05869720092755, 244.04843359876355)]
                MQPrintLog(message: "corners: \(obj.corners)")
                
                drawFrame(codeObj: obj)
            }
            
        }
        
    }
    func drawFrame(codeObj:AVMetadataMachineReadableCodeObject) -> Void {
        let corners = codeObj.corners
        
        //1 借助一个图形层来绘制
        let shapLayer = CAShapeLayer()
        shapLayer.lineWidth = 3
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.strokeColor = UIColor.red.cgColor
        
        //        var index = 0
        let path = UIBezierPath()
        //2 根据四个点 创建路径
        for index in 0..<corners.count {
            let point = corners[index]
            //            let point = CGPoint(dictionaryRepresentation: pointDic)!
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        
        shapLayer.path = path.cgPath
        preLayer.addSublayer(shapLayer)
    }
    func removeQRcodeFrame() -> Void {
        guard let subLayers = preLayer.sublayers else { return }
        for layer in subLayers {
            if layer.isKind(of: CAShapeLayer.self) {
                layer.removeFromSuperlayer()
            }
        }
    }
}
extension MQScanHomeVC {
    @objc override func naviBarPopItemStyle() -> PopItemStyle {
        return .PopItemWhite
    }
}
