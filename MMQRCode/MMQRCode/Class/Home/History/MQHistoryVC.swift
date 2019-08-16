//
//  MQHistoryVC.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/5.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit
enum HistoryType: Int {
    case ScanHistory = 0,CreateHistory
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
    var currentCreatePage = 0
    
    lazy var scanListArr: [MQHistoryScanModel] = Array()
    lazy var createListArr: [MQHistoryGenerateModel] = Array()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainScrollView.contentSize = CGSize(width: MQScreenWidth * 2.0, height: MQScreenHeight)
        mainScrollView.bounces = false
        mainScrollView.isScrollEnabled = false
        
        
        let callBack: UpdataCallBack = {[weak self] (results: Array<MQHistoryScanModel>?, generateR: Array<MQHistoryGenerateModel>?) -> Void in
            if let scanResult = results, scanResult.count > 0 {
                if self?.currentPage == 0 {
                    self?.scanListArr = scanResult
                } else {
                    self?.scanListArr.append(contentsOf: scanResult)
                }
                self?.scanViewList?.reloadData()
            } else if let generateResult = generateR, generateResult.count > 0 {
                if self?.currentPage == 0 {
                    self?.createListArr = generateResult
                } else {
                    self?.createListArr.append(contentsOf: generateResult)
                }
                self?.createViewList?.reloadData()
            }
        }
        self.historyViewModel = MQHistoryViewModel(callback: callBack)
        scrollToIndexView(index: viewType.rawValue, changeSegment: true)

    }
    
    @IBAction func tipsBtnClick(_ sender: Any) {
        MQToastView.show(message: "左滑可设置备注和删除")
    }
    
    @IBAction func segmentValueChange(_ sender: UISegmentedControl) {
        scrollToIndexView(index: sender.selectedSegmentIndex, changeSegment: true)
    }
}
extension MQHistoryVC {

    
    func scrollToIndexView(index: Int, changeSegment: Bool = false) -> Void {
        if index == 0 {
            if scanViewList == nil {
                historyViewModel?.fetchDBData(page: currentPage, maxPage: maxPage)
                scanViewList = createTableViewWith(index)
                self.mainScrollView.addSubview(scanViewList!)
            }
        } else {
            if createViewList == nil {
                historyViewModel?.fetchGenerateData(page: currentCreatePage, maxPage: maxPage)
                createViewList = createTableViewWith(index)
                self.mainScrollView.addSubview(createViewList!)
            }
        }
        mainScrollView.setContentOffset(CGPoint(x: CGFloat(index) * mainScrollView.mm_width, y: 0), animated: true)
        if changeSegment {
            segmentControl.selectedSegmentIndex = index
        }
    }
    
    func createTableViewWith(_ index:Int) -> UITableView {
        let tableView = UITableView.tableViewWith(nibCells: ["MQHistoryTVCell"], classCells: nil, delegate: self)
        tableView.frame = mainScrollView.bounds
        tableView.mm_x = index == 0 ? 0 : MQScreenWidth
        tableView.allowsMultipleSelection = true
        return tableView
    }
    
//    func getFitArray(tableView: UITableView) -> [MQHistoryScanModel] {
//        if tableView == scanViewList {
//            return scanListArr
//        }
//        return createListArr
//    }
}

extension MQHistoryVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == scanViewList {
            return scanListArr.count
        }
        return createListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MQHistoryTVCell", for: indexPath) as! MQHistoryTVCell

        if tableView == scanViewList {
//            let models: [MQHistoryScanModel] = (tableView: tableView)
            let model: MQHistoryScanModel = scanListArr[indexPath.row]
            cell.historyModel = model
            cell.separatorLineView.isHidden = indexPath.row + 1 == scanListArr.count
        } else {
            let model: MQHistoryGenerateModel = createListArr[indexPath.row]
            cell.generateModel = model
            cell.separatorLineView.isHidden = indexPath.row + 1 == createListArr.count
        }
        
//        let panGes = tableView.superview?.gestureRecognizers?.first
//        panGes?.require(toFail: cell.gestureRecognizers!.first!)
        return cell
    }
}

extension MQHistoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle(rawValue: UITableViewCell.EditingStyle.delete.rawValue | UITableViewCell.EditingStyle.insert.rawValue)!
//        return UITableViewCell.EditingStyle.delete
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "删除") { (action, indexPath) in
            
        }
        let remark = UITableViewRowAction(style: .default, title: "备注") { (action, indexPath) in
            
        }
        remark.backgroundColor = UIColor.lightGray
        return [delete,remark]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        MQPrintLog(message: indexPath)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration()
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == scanViewList {
            let model: MQHistoryScanModel = scanListArr[indexPath.row]
            let resultVC: MQScanResultVC = UIStoryboard(name: "MQHome", bundle: nil).instantiateViewController(withIdentifier: "MQScanResultVC") as! MQScanResultVC
            resultVC.needToSaveDB = false
            resultVC.resultData = [model.scanContent!]
            self.navigationController?.pushViewController(resultVC, animated: true)
        } else {
            let model: MQHistoryGenerateModel = createListArr[indexPath.row]
            let resultVC: MQShowQRCodeVC = UIStoryboard(name: "MQHome", bundle: nil).instantiateViewController(withIdentifier: "MQShowQRCodeVC") as! MQShowQRCodeVC
            resultVC.sourceContent = model.createContent
            resultVC.needToSaveDB = false
            self.navigationController?.pushViewController(resultVC, animated: true)
        }

    }
}

//extension MQHistoryVC: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == mainScrollView {
//            scanViewList?.isScrollEnabled = false
//            createViewList?.isScrollEnabled = false
//        }
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView == mainScrollView {
//            scanViewList?.isScrollEnabled = true
//            createViewList?.isScrollEnabled = true
//        }
//    }
//}

