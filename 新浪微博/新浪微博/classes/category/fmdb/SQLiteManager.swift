//
//  SQLiteManager.swift
//  新浪微博
//
//  Created by apple on 16/3/20.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class SQLiteManager: NSObject {
    
    /// 单例
    static let shareInstance : SQLiteManager = SQLiteManager()
    
    /// 数据库对象
    var dbQueue : FMDatabaseQueue?
    
    /// 打开数据库
    func openDB(name: String)
    {
        // 1.拼接SQLite路径
        let path = name.cacheDir()
        print(path)
        // 2.创建FMDB
        dbQueue = FMDatabaseQueue(path: path)
        // 3.创建表
        createTable()
    }
    
    /// 创建表
    private func createTable()
    {
        // 1.定义SQL语句
        let sql = "CREATE TABLE IF NOT EXISTS T_Status( \n" +
            "statusId TEXT PRIMARY KEY, \n" +
            "statusText TEXT, \n" +
            "userId TEXT ,\n" +
            "createDate TEXT NOT NULL DEFAULT (datetime('now', 'localtime')) \n" +
        "); \n"
        
        // 2.执行SQL语句
        dbQueue?.inDatabase({ (db) -> Void in
            do
            {
                try db.executeUpdate(sql, values: nil)
                
            }catch
            {
                
            }
        })
    }

}
