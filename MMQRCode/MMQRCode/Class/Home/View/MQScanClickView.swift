//
//  MQScanClickView.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/14.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

class MQScanClickView: UIView {
    
    var scanBtn: UIButton?
    
    var callBack: ((_ type: Int) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        scanBtn = UIButton.buttonWith(title: nil, selectedTitle: nil, titleColor: nil, selectedColor: nil, image: nil, selectedImg: nil, target: self, selecter: #selector(handleClick(sender:)))
        scanBtn?.setBackgroundImage(UIImage(named: "scan_btn_circle"), for: .normal)
        self.addSubview(scanBtn!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scanBtn?.frame = CGRect(x: 2, y: 2 , width: mm_width - 4, height: mm_width - 4)
        scanBtn?.layer.cornerRadius = (mm_width - 4) * 0.5
        scanBtn?.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        
        let drawPath = UIBezierPath()
        drawPath.lineWidth = 1
        drawPath.lineJoinStyle = CGLineJoin.round
        context?.setStrokeColor(UIColor.mm_colorFromHex(color_vaule: 0x2882fc, alpha: 0.6).cgColor)
        drawPath.move(to: CGPoint(x: 1, y: height))
        //到圆弧左边
        drawPath.addLine(to: CGPoint(x: 1, y: width * 0.5))
        drawPath.addArc(withCenter: CGPoint(x: width * 0.5, y: width * 0.5), radius: width * 0.5 - 1, startAngle: CGFloat(-Double.pi), endAngle: 0, clockwise: true)
        drawPath.addLine(to: CGPoint(x: width - 1, y: height))
        drawPath.stroke()
        
//        context?.setStrokeColor(UIColor.white.cgColor)
//        drawPath.move(to: CGPoint(x: width, y: height))
//        drawPath.addLine(to: CGPoint(x: 0, y: height))
//        drawPath.stroke()
        drawPath.fill()
        
        layer.shadowColor = UIColor.mm_colorFromHex(color_vaule: 0xD0d0d0, alpha: 0.6).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 1
        layer.shadowPath = drawPath.cgPath
    }

    @objc func handleClick(sender: UIButton) -> Void {
        if let tCall = callBack {
            tCall(0)
        }
    }
}
