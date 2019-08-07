//
//  MQHistoryVC.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/5.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit
enum HistoryType {
    case ScanHistory,CreateHistory
}
class MQHistoryVC: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var tipsRightItm: UIBarButtonItem!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var viewType: HistoryType = .ScanHistory
    
    var historyViewModel: MQHistoryViewModel?
    
    var scanViewList: UITableView?
    
    var createViewList: UITableView?

    let maxPage = 20
    
    var currentPage = 0
    
    lazy var scanListArr: [MQHistoryScanModel] = Array()
    lazy var createListArr: [MQHistoryCreateModel] = Array()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainScrollView.contentSize = CGSize(width: MQScreenWidth * 2.0, height: MQScreenHeight)
        scrollToIndexView(index: segmentControl.selectedSegmentIndex)
        
        let callBack: UpdataCallBack = {[weak self] (results: Array<MQHistoryScanModel>) -> Void in
            if results.count > 0 {
                if self?.currentPage == 0 {
                    self?.scanListArr = results
                } else {
                    self?.scanListArr.append(contentsOf: results)
                }
            }
            
            self?.scanViewList?.reloadData()
        }
        self.historyViewModel = MQHistoryViewModel(callback: callBack)
        historyViewModel?.fetchDBData(page: currentPage, maxPage: maxPage)
        
//        self.navigationController?.hidesBarsOnSwipe = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tipsBtnClick(_ sender: Any) {
        MQToastView.show(message: "左滑可设置备注和删除")
    }
    
    @IBAction func segmentValueChange(_ sender: UISegmentedControl) {
        scrollToIndexView(index: sender.selectedSegmentIndex)
    }
}
extension MQHistoryVC {
    func setupSubView() -> Void {
        
    }
    func scrollToIndexView(index: Int) -> Void {
        if index == 0 {
            if scanViewList == nil {
//                self.mainScrollView.
            }
        }
    }
    
    func createTableViewWith(index:Int) -> UITableView {
        let tableView = UITableView.tableViewWith(nibCells: [], classCells: nil, delegate: self)
        return tableView
    }
}
extension MQHistoryVC: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        CGFloat
//        if <#condition#> {
//            <#code#>
//        }
//    }
}

