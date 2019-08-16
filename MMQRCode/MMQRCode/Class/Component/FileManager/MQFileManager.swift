//
//  MQFileManager.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/16.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit

enum MQFileType: String {
    case image = "mqImage"
}



class MQFileManager: NSObject {
    
    static let share: MQFileManager = MQFileManager()
    
    var MQDocumentPath: String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return path as String
    }
    
    func saveFileToDisk(fileType: MQFileType = .image, saveData: Any?, saveName: String) -> Bool {
        guard let _saveData = saveData else { return false }
        let folderPath: String = MQDocumentPath + "/" + fileType.rawValue
        guard checkFolderPath(folderPath) else {
            return false
        }
        //创建文件成功,写入文件
        if fileType == .image {
            let filePath = URL(fileURLWithPath: folderPath + "/" + saveName + ".png")
            //留存 如果有相同文件名从情况下。应进行替换。
//            if checkFolderPath(folderPath + saveName + ".png") {
//                let fileM = FileManager.default.rem

//            }
            
            let png = (_saveData as! UIImage).pngData()
            do {
                try png!.write(to: filePath, options: Data.WritingOptions.atomic)
            } catch {
                MQPrintLog(message: error)
                return false
            }
            MQPrintLog(message: filePath)
        }
        return true
    }
    
    func checkFolderPath(_ folderPath: String) -> Bool {
        let fileM = FileManager.default
        var isDirectory = ObjCBool(false)
        if !fileM.fileExists(atPath: folderPath, isDirectory: &isDirectory) {
//            guard fileM.createFile(atPath: folderPath, contents: nil, attributes: nil) else {
//                MQPrintLog(message: "创建失败")
//                return false
//            }
            do {
                try fileM.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                MQPrintLog(message: "创建失败 ->\(error)")
                return false
            }
        }
        return true
    }
}
