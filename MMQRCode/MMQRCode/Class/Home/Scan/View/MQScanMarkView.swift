//
//  MQScanMarkView.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/26.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit
import AVFoundation

enum MarkViewTouchType {
    case signleTap,twiceTap,twoFinger
}
class MQScanMarkView: UIView {
    weak var scanDelegate: ScanViewProtocol?
    /// 非识别区域颜色
    var notRecoginitonArea: UIColor?
    var scanRetangleRect: CGRect?
    
    /// 扫描四个角的宽度
    var photoframeAngleW: Float?
    var photoframeAngleH: Float?
    /// 四个角的颜色
    var colorAngle: UIColor?
    
    /// 线框线条颜色
    var colorRetangleLine: UIColor?
    
    /// 扫码区域4个角的线条宽度,默认6
    var photoframeLineW: Float?
    
    var isScaning:Bool = false

    lazy var scanLineImg:UIImageView = {
        let imgV = UIImageView(image: UIImage(named: "scan_line_img"))
        imgV.frame = CGRect(x: scanRetangleRect!.mm_x, y: scanRetangleRect!.mm_y - scanRetangleRect!.mm_height * 0.5, width: scanRetangleRect!.mm_width, height: scanRetangleRect!.mm_height)
        imgV.contentMode = ContentMode.scaleToFill;
        return imgV
    }()
    
    lazy var flashControlView: UIView = {
       let flashControlView = UIView()
        flashStatusBtn = UIButton.buttonWith(title: nil, selectedTitle: nil, titleColor: nil, selectedColor: nil, image: "flash_close_btn", selectedImg: "flash_open_btn", target: nil, selecter: nil)
        flashStatusBtn?.isUserInteractionEnabled = false
        flashStatusLabel = UILabel.labelWith(title: "开启手电筒", titleColor: .white, font: UIFont.systemFont(ofSize: 12),alignment: .center)
        flashStatusBtn?.mm_size = CGSize(width: 24, height: 24)
        flashStatusBtn?.mm_centerX = 50
        flashStatusBtn?.mm_y = 0
        flashStatusLabel?.mm_centerX = 50
        flashStatusLabel?.mm_y = flashStatusBtn!.frame.maxY + 10
        flashControlView.addSubview(flashStatusBtn!)
        flashControlView.addSubview(flashStatusLabel!)
        flashControlView.mm_size = CGSize(width: 100, height: 50)
        flashControlView.mm_y = scanRetangleRect!.mm_y + scanRetangleRect!.mm_height - 60
        flashControlView.mm_centerX = self.mm_centerX
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGes(sender:)))
        flashControlView.addGestureRecognizer(tap)
        flashControlView.isHidden = true

        self.addSubview(flashControlView)
        return flashControlView
    }()
    var flashStatusBtn: UIButton?
    var flashStatusLabel: UILabel?
    var isShowFlash: Bool = false
    var isAnimating: Bool = false
    
    
    lazy var auctionLabel: UILabel = {
        let label = UILabel.labelWith(title: "将二维码/条码放入框内，即可自动扫描", titleColor: UIColor.mm_color(red: 153, green: 153, blue: 153, alpha: 1.0), font: UIFont.systemFont(ofSize: 12), alignment: NSTextAlignment.center)
        label.mm_y = self.scanRetangleRect!.maxY + 10
        label.mm_centerX = self.mm_width * 0.5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.mm_color(red: 0, green: 0, blue: 0, alpha: 0)
        //        notRecoginitonArea = UIColor.mm_colorFromHex(color_vaule: 0x000000, alpha: 0.5)
        notRecoginitonArea = UIColor.mm_color(red: 0, green: 0, blue: 0, alpha: 0.5)
//        notRecoginitonArea = UIColor.init(white: 0.0, alpha: 0.0)
        let width = MQScreenWidth - 30.0 * 2
        scanRetangleRect = CGRect(x: 30.0 as CGFloat, y: CGFloat(MQNavigationBarHeight + 100.0), width: width, height: width)
        colorAngle = MQMainColor
        colorRetangleLine = UIColor.white
        photoframeAngleH = 20;
        photoframeAngleW = 20;
        photoframeLineW = 6;
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        //双击手势
        let zoomTouch = UITapGestureRecognizer(target: self, action: #selector(handleTwiceScalleGes(sender:)))
        zoomTouch.numberOfTapsRequired = 2;
        self.addGestureRecognizer(zoomTouch)
        //单击手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleMinScalleGes(sender:)))
        self.addGestureRecognizer(singleTap)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Drawing code
        drawScanRect()
        addSubview(self.scanLineImg)
        addSubview(self.auctionLabel)
    }
    func drawScanRect() -> Void {
        let sizeRetangle = scanRetangleRect?.size
        let minRetangleY = scanRetangleRect?.mm_y
        let maxRetangleY = scanRetangleRect?.maxY
        let retagnleLeftX = scanRetangleRect?.mm_x
        let retagnleRightX = scanRetangleRect?.maxX
        
        let context = UIGraphicsGetCurrentContext()
        //设置非扫码区域
        context?.setFillColor(notRecoginitonArea!.cgColor)
//        context?.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let rectTop = CGRect(x: 0, y: 0, width: mm_width, height: minRetangleY!)
        context?.fill(rectTop)
        let rectLeft = CGRect(x: 0, y: minRetangleY!, width: retagnleLeftX!, height: sizeRetangle!.height)
        context?.fill(rectLeft)
        let rectRight = CGRect(x: retagnleRightX!, y: minRetangleY!, width: retagnleLeftX!, height: sizeRetangle!.height)
        context?.fill(rectRight)
        let rectBottom = CGRect(x: 0, y: maxRetangleY!, width: mm_width, height: mm_height - maxRetangleY!)
        context?.fill(rectBottom)
        //执行画图
        context?.strokePath()
        
        // 中间扫描区域
        context?.setStrokeColor(colorRetangleLine!.cgColor)
        context?.setLineWidth(1)
        let lineRect = CGRect(x: retagnleLeftX!, y: minRetangleY!, width: sizeRetangle!.width, height: sizeRetangle!.height)
        context?.addRect(lineRect)
        context?.strokePath()
        
        context?.setStrokeColor(colorAngle!.cgColor)
//        context?.setFillColor(UIColor.white.cgColor)
        context?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context?.setLineWidth(CGFloat(photoframeLineW!))
        //四个角
        let deffAngle = CGFloat( -photoframeLineW!/3.0)
        let leftX = retagnleLeftX! - deffAngle
        let topY = minRetangleY! - deffAngle
        let rightX = retagnleRightX! + deffAngle
        let bottomY = maxRetangleY! + deffAngle
        context?.move(to: CGPoint(x: leftX - CGFloat(photoframeLineW!/2), y: topY))
        context?.addLine(to: CGPoint(x: leftX + CGFloat(photoframeAngleW!), y: topY))
        context?.move(to: CGPoint(x: leftX, y: topY - CGFloat(photoframeLineW!/2)))
        context?.addLine(to: CGPoint(x: leftX, y: topY + CGFloat(photoframeAngleH!)))
        
        context?.move(to: CGPoint(x: leftX - CGFloat(photoframeLineW!/2), y: bottomY))
        context?.addLine(to: CGPoint(x: leftX + CGFloat(photoframeAngleW!), y: bottomY))
        context?.move(to: CGPoint(x: leftX , y: bottomY + CGFloat(photoframeLineW!/2)))
        context?.addLine(to: CGPoint(x: leftX, y: bottomY - CGFloat(photoframeAngleH!) ))
        //右上
        context?.move(to: CGPoint(x: rightX + CGFloat(photoframeLineW!/2), y: topY))
        context?.addLine(to: CGPoint(x: rightX - CGFloat(photoframeAngleW!), y: topY))
        context?.move(to: CGPoint(x: rightX , y: topY - CGFloat(photoframeLineW!/2)))
        context?.addLine(to: CGPoint(x: rightX, y: topY + CGFloat(photoframeAngleH!) ))
        //右下
        context?.move(to: CGPoint(x: rightX + CGFloat(photoframeLineW!/2), y: bottomY))
        context?.addLine(to: CGPoint(x: rightX - CGFloat(photoframeAngleW!), y: bottomY))
        context?.move(to: CGPoint(x: rightX , y: bottomY + CGFloat(photoframeLineW!/2)))
        context?.addLine(to: CGPoint(x: rightX, y: bottomY - CGFloat(photoframeAngleH!)))
        
        context?.strokePath()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
//动画控制
extension MQScanMarkView {
    @objc func appWillEnterBackground() -> Void {
        stopScanAnimation()
    }
    
    @objc func appWillEnterForeground() -> Void {
        startScanAnimation()
    }
    
    func startScanAnimation() -> Void {
        if isScaning {
            return
        }
        isScaning = true
        self.scanLineImg.isHidden = false;
        self.scanLineImg.mm_width = self.scanRetangleRect!.mm_width
        UIView.animate(withDuration: 2.5, delay: 0.03, options: UIView.AnimationOptions.repeat, animations: {
            self.scanLineImg.mm_y = self.scanRetangleRect!.mm_y + self.scanRetangleRect!.mm_height * 0.5
        }) { (finish: Bool) in
            self.scanLineImg.mm_y = self.scanRetangleRect!.mm_y - self.scanRetangleRect!.mm_height * 0.5
        }
    }
    
    func stopScanAnimation() -> Void {
        self.scanLineImg.isHidden = true;
        self.scanLineImg.mm_y = self.scanRetangleRect!.mm_y - self.scanRetangleRect!.mm_height * 0.5
        self.scanLineImg.layer.removeAllAnimations()
        isScaning = false;
    }
    
    func showFlash() -> Void {
        if isShowFlash || isAnimating {
            return
        }
        isShowFlash = true
        isAnimating = true
        if flashControlView.isHidden {
            flashControlView.alpha = 0
            flashControlView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.flashControlView.alpha = 1
            }) { (_) in
                self.isAnimating = false
            }
        }
    }
    
    func hideFlash() -> Void {
        if !isShowFlash || isAnimating {
            return
        }
        if flashStatusBtn!.isSelected {
            return
        }
        isShowFlash = false
        isAnimating = true
        if !flashControlView.isHidden {
            self.flashControlView.alpha = 1
            UIView.animate(withDuration: 0.2, animations: {
                self.flashControlView.alpha = 0
            }) { (_) in
                self.flashControlView.isHidden = true
                self.isAnimating = false
            }
        }
    }
    
    @objc func handleTapGes(sender: UITapGestureRecognizer) -> Void {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if device == nil {
            setFlastStatus(status: 0)
            return
        }
        if device?.torchMode == AVCaptureDevice.TorchMode.off {
            do {
                try device?.lockForConfiguration()
            } catch {
                return
            }
            device?.torchMode = .on
            setFlastStatus(status: 1)
        } else {
            do {
                try device?.lockForConfiguration()
            } catch {
                return
            }
            device?.torchMode = .off
            setFlastStatus(status: 0)
        }
        device?.unlockForConfiguration()
    }
    
    func setFlastStatus(status: Int) -> Void {
        flashStatusBtn?.isSelected = status == 0 ? false : true
        flashStatusLabel?.text = status == 0 ? "打开手电筒" : "关闭手电筒"
        flashStatusLabel?.textColor = status == 0 ? .white : MQMainColor
    }
    
    @objc func handleTwiceScalleGes(sender: UITapGestureRecognizer) {
        self.scanDelegate?.scanViewGestureTouch(type: .twiceTap)

    }
    
    @objc func handleZoomScalleGes(sender: UITapGestureRecognizer) {
    }
    
    @objc func handleMinScalleGes(sender: UITapGestureRecognizer) {
    }
}

protocol ScanViewProtocol: class {
    func scanViewGestureTouch(type: MarkViewTouchType)
}
