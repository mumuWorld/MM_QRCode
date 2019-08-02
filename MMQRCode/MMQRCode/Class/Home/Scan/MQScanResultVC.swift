//
//  MQScanResultVC.swift
//  MMQRCode
//
//  Created by yangjie on 2019/7/29.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit
import IBAnimatable

enum ResultType {
    case NetPage,WeChat,Alipay,OnlyStr
}
class MQScanResultVC: MQBaseViewController {
    
    var resultData: [String]?
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var resultContentView: AnimatableTextView!
    
    @IBOutlet weak var handleBtn: AnimatableButton!
    
    
    var rightItem: UIBarButtonItem {
        get {
            let _rightItem = UIBarButtonItem.barButtomItem(title: nil, selectedTitle: nil, titleColor: MQMainColor, selectedColor: nil, image: "btn_tip_navi", selectedImg: nil, target: self, selecter: #selector(handleBtnClick(sender:)))
            return _rightItem
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.title = "扫描结果"
        self.navigationItem.rightBarButtonItem = self.rightItem;
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: MQMainTitleColor]

        if let result = resultData {
            judgeResult(results: result)
        }
        
    }
    @IBAction func handleResultClick(_ sender: AnimatableButton) {
        
    }
}

extension MQScanResultVC {
    @objc func handleBtnClick(sender: UIButton) {
        
    }
    func judgeResult(results: [String]) -> Void {
        if results.count > 0 {
            let resultStr = results.first!
            
            resultContentView.text = resultStr
            //判断识别类型。
            if resultStr.hasPrefix("http://") || resultStr.hasPrefix("https://") {
                self.handleResultType(result: resultStr, type: .NetPage)
            } else {
                self.handleResultType(result: resultStr, type: .OnlyStr)
            }
        }
        //多余结果 列表展示。
        if results.count > 1 {
            for i in 1...results.count {
                MQPrintLog(message: results[i])
            }
        }
    }
    func handleResultType(result: String,type: ResultType) -> Void {
        switch type {
        case .NetPage:
            self.handleBtn.setTitle("打开网址", for: .normal)
        case .OnlyStr:
            self.handleBtn.setTitle("复制文字", for: .normal)
        default:
            break
        }
    }
}
