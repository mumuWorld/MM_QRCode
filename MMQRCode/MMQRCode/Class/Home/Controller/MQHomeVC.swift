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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.barTintColor = UIColor.mm_colorFromHex(color_vaule: 0x2882fc,alpha: 0.0)
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIColor.mm_colorImgHex(color_vaule: 0x2882fc,alpha: 0.1), for: UIBarPosition.any, barMetrics: .default)
//        let naviImg = self.getNaviBarBackgroundImg()
//        naviImg?.image = UIColor.mm_colorImgHex(color_vaule: 0x2882fc,alpha: 0.5)
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
