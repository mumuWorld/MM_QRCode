//
//  MQScanTool.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/29.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit
import AVFoundation

enum MQScanStatus {
    case success, failed, denied
}

class MQScanTool: NSObject {
    
    var scanMaskView: MQScanMarkView? {
        willSet {
            if let tmpScan = newValue {
                tmpScan.scanDelegate = self
            }
        }
    }
    
    lazy var dector:CIDetector = {
        let _dector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        return _dector
    }()
    
    weak var resultDelegate: MQScanResultProtocol?
    
    /// 保存权限状态
    var saveCheckStatus:AVAuthorizationStatus?
    
    /// 是否正在扫描
    var isScaning:Bool = false

    var preview: UIView?
    
    /// 预览图层
    lazy var preLayer:AVCaptureVideoPreviewLayer = {
        return AVCaptureVideoPreviewLayer(session: session)
    }()
    
    lazy var session:AVCaptureSession = {
        let session = AVCaptureSession()
        return session
    }()
    
    /// 储存device属性
    var device: AVCaptureDevice?
    
    var isFouce: Bool = false
    
    func scanImg(sourceImg: UIImage?,successResult: (([String]) ->Void)?,failed:((String)->())?) {
        guard let _sourceImg = sourceImg else {
            if failed != nil {
                failed!("image 不能为空")
            }
            return
        }
        let ciImg = CIImage(image: _sourceImg)
        guard let sourceCIImg = ciImg else {
            if failed != nil {
                failed!("image 识别失败")
            }
            return
        }
        let results = self.dector.features(in: sourceCIImg)
        if results.count <= 0 {
            if failed != nil {
                failed!("未识别到有效二维码")
            }
            return
        }
        var messages:[String] = Array()

        for result in results {
            let qrFeature = result as! CIQRCodeFeature
            if let message = qrFeature.messageString {
                messages.append(message)
            }
        }
        if successResult != nil {
            successResult!(messages)
        }
    }
}

// MARK: - 扫描方法
extension MQScanTool {
    func checkupAuthorization() -> Void {
        //多加了一层缓存检查权限。就不用再去请求权限了。
        if saveCheckStatus == .authorized {
            shouldScan()
            return
        } else if saveCheckStatus == AVAuthorizationStatus.denied {
            self.sendResult(scanStatus: .denied, scanResult: nil, error: nil)
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
                    self.sendResult(scanStatus: .denied, scanResult: nil, error: nil)
                }
                //                self.cameraPermissions(authorizedBlock: authorizedBlock, deniedBlock: deniedBlock)
            })
        } else if saveCheckStatus == AVAuthorizationStatus.authorized {
            MQPrintLog(message: "status=\(saveCheckStatus!.rawValue)")
        } else {
            self.sendResult(scanStatus: .denied, scanResult: nil, error: nil)
            return
        }
        shouldScan()
    }
    
    func shouldScan() -> Void {
        if !isScaning {
            self.setupScanQRCode()
        }
    }
    
    /// 初始化device
    func setupScanQRCode() -> Void {
        //1 设置输入
        device = AVCaptureDevice.default(for: AVMediaType.video)
        var input:AVCaptureInput?
        do {
            try input = AVCaptureDeviceInput(device: device!)
        } catch let err {
            print("err= \(err)")
        }
        
        //2 设置输出
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // 设置光感
        let buffer = AVCaptureVideoDataOutput()
        buffer.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        if session.canAddOutput(buffer) {
            session.addOutput(buffer)
        }
        //3 创建会话，链接输入和输出
        if session.canAddInput(input!) && session.canAddOutput(output) {
            session.addInput(input!)
            session.addOutput(output)
        }
        //3.1 设置二维码可以识别的码制。
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        //3.2 添加视频预览图层
        if let tPreview = preview {
            preLayer.frame = tPreview.bounds
//            UIView.animate(withDuration: 0.2) {
                tPreview.layer.insertSublayer(self.preLayer, at: 0)
            tPreview.alpha = 0
            UIView.animate(withDuration: 0.2) {
                tPreview.alpha = 1
            }
//            }
        }
        
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
    }
}

extension MQScanTool {
    public func startScaning() {
        session.startRunning()
        if let scanMaskView = scanMaskView {
            scanMaskView.startScanAnimation()
        }
        isScaning = true;
    }
    
    public func stopScaning() {
        session.stopRunning()
        if let scanMaskView = scanMaskView {
            scanMaskView.stopScanAnimation()
        }
        isScaning = false;
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension MQScanTool: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let source = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.scanImg(sourceImg: source, successResult: { [weak self] (result: [String]) in
            if result.count > 0 {
                self?.sendResult(scanStatus: .success, scanResult: result, error: nil)
            }
        }) { [weak self] (failed) in
            self?.sendResult(scanStatus: .failed, scanResult: nil, error: failed)
        }
    }
}

extension MQScanTool: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //画之前 ，移除上一次绘制的 frame
        removeQRcodeFrame()
        //直接要第一个
        //        wxp://f2f0mmJRwn23YosIHu4CWtasONMV1oTMoLDg
        if metadataObjects.count > 0 {
            var resultArr = Array<String>()
            //遍历输出数组
            for metaObject in metadataObjects {
                if metaObject.isKind(of: AVMetadataMachineReadableCodeObject.self) {
                    let resultObj = preLayer.transformedMetadataObject(for: metaObject)
                    
                    let obj = resultObj as! AVMetadataMachineReadableCodeObject
                    MQPrintLog(message: "message \(obj.stringValue ?? "")")
                    if let value = obj.stringValue {
                        resultArr.append(value)
                    }
                    //                corners代表二维码的四个角，但是需要预览图层，转换成我们需要的可用的坐标。
                    //                [(50.52805463348426, 240.47635589036352), (52.81510895931001, 311.85075811638114), (124.59585025601314, 315.18543130468424), (125.05869720092755, 244.04843359876355)]
                    MQPrintLog(message: "corners: \(obj.corners)")
                    drawFrame(codeObj: obj)
                }
            }
            self.sendResult(scanStatus: .success, scanResult: resultArr, error: nil)
            return
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
    
    func sendResult(scanStatus: MQScanStatus, scanResult: [String]?,error: String?) -> Void {
        stopScaning()
        removeQRcodeFrame()
        self.resultDelegate?.mqScanResult(tool: self, scanStatus: scanStatus, scanResult: scanResult, error: error)
    }
}

extension MQScanTool: ScanViewProtocol {
    func scanViewGestureTouch(type: MarkViewTouchType) {
        if type == .twiceTap { //操作device 时 要先 加锁 在解锁
            device?.unlockForConfiguration()
            if let tmpDevice = device {
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                    let purpose = CATransform3DScale(self.preLayer.transform, 1.2, 1.2, 1)
                    self.preLayer.transform = self.isFouce ? CATransform3DIdentity : purpose
                }) { (_) in
                }
                do {
                    try tmpDevice.lockForConfiguration()
                        tmpDevice.focusPointOfInterest = self.preview?.center ?? UIApplication.shared.keyWindow!.center
                        tmpDevice.focusMode = AVCaptureDevice.FocusMode.autoFocus
                        tmpDevice.videoZoomFactor = self.isFouce ? 1.0 : 1.5
                } catch {
                    
                }
                self.isFouce = !self.isFouce
                tmpDevice.unlockForConfiguration()
            }
        }
    }
}

// MARK: - 光感监听
extension MQScanTool: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let metadataDic = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let metadata = NSDictionary.init(dictionary: metadataDic as! [AnyHashable : Any], copyItems: true)
        let exifMetadata:NSDictionary = NSDictionary.init(dictionary: metadata.object(forKey: kCGImagePropertyExifDictionary as String) as! [AnyHashable : Any], copyItems: true)
        let brightnessValue:CGFloat = exifMetadata[kCGImagePropertyExifBrightnessValue] as! CGFloat
//        MQPrintLog(message: "光线*****  \(brightnessValue)")
        if brightnessValue < 0 {
            scanMaskView?.showFlash()
        } else if brightnessValue > 0 {
            scanMaskView?.hideFlash()
        }
    }
}

protocol MQScanResultProtocol: class {
    func mqScanResult(tool: MQScanTool?, scanStatus: MQScanStatus, scanResult: [String]?,error: String?)
}
