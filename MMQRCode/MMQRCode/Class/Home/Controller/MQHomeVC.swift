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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MQImageLabelCVCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
}
