//
//  MQDBManager.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/7.
//  Copyright © 2019 yangjie. All rights reserved.
//

import Foundation
import SQLite

class MQDBManager {
    
    /// 单例
    static let shareManager: MQDBManager = MQDBManager()
    
    var shareDB: Connection?
    
    init() {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last
        guard let tPath = path else { return }
        let dbPath = tPath + "/mqrcode"
        var isDirector: ObjCBool = false
        
        let fileExist = FileManager.default.fileExists(atPath: dbPath, isDirectory: &isDirector)
        if fileExist == false  {
            do {
                try FileManager.default.createDirectory(atPath: dbPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                MQPrintLog(message: error)
            }
        }
        let dbFile = dbPath + "/MQDB.db"
        do {
            shareDB = try Connection(dbFile)
        } catch {
            MQPrintLog(message: error)
        }
        
    }
    
    func createTable(name: String,block: (TableBuilder) -> Void) -> Table? {
        let _table = Table(name)
        guard let tDB = shareDB else { return nil }
        do {
            try tDB.run(_table.create(ifNotExists: true,block: block))
        } catch {
            MQPrintLog(message: error)
        }
        
        return _table
    }
    
    
}
