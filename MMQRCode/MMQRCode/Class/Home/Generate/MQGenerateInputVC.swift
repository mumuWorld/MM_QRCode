//
//  MQGenerateInputVC.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/15.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit
import IBAnimatable

class MQGenerateInputVC: MQBaseViewController {

    @IBOutlet weak var inputTextView: AnimatableTextView!
    
    @IBOutlet weak var contentView_height: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "生成二维码"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView_height.constant = view.mm_height
    }

    @IBAction func generateBtnClick(_ sender: UIButton) {
        
        let content = inputTextView.text!
        
        guard content.count > 0 else {
            MQToastView.show(message: "当前内容为空")
            return
        }
        guard content.count < 150 else {
            MQToastView.show(message: "文字太长,请保持在150个字符以内")
            return
        }
        let showVC:MQShowQRCodeVC = UIStoryboard(name: "MQHome", bundle: nil).instantiateViewController(withIdentifier: "MQShowQRCodeVC") as! MQShowQRCodeVC
            showVC.sourceContent = content
        showVC.needToSaveDB = true
        self.navigationController?.pushViewController(showVC, animated: true)
    }
}

extension MQGenerateInputVC: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
}
