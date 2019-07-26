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
            return ["MQScanHomeVC","MQScanHomeVC","MQScanHomeVC","MQScanHomeVC"]
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
        setupLayout()
    }
    func setupLayout() -> () {
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
