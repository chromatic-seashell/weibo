//
//  GDWStatusViewModelList.swift
//  新浪微博
//
//  Created by apple on 15/11/17.
//  Copyright © 2015年 apple. All rights reserved.
//

import Foundation
import SDWebImage

class  GDWStatusViewModelList{
    /// 保存所有微博数据
    var statuses: [GDWStatusViewModel]?
    
    /// 获取微博数据
    func loadStatus(since_id: String,  max_id: String,finished: (models: [GDWStatusViewModel]?, error: NSError?)->())
    {
        // 1.从本地加载微博数据
        loadCacheStatus(since_id, max_id: max_id) { (models, error) -> Void in
            
            // 1.安全校验
            if error != nil
            {
                finished(models: nil, error: error)
                return
            }
            
            // 2.判断本地是否有数据
            if models != nil && models!.count != 0
            {
                // 3.处理下拉刷新的数据
                if since_id != "0"
                {
                    // 将新的数据凭借到旧数据前面
                    self.statuses = models! + self.statuses!
                    
                }else if max_id != "0"
                {
                    // 将新的数据拼接到旧数据后面
                    self.statuses = self.statuses! + models!
                }else{
                    self.statuses = models!
                }
                
                //print("从本地加载微博数据")
                finished(models: models, error: nil)
                return
            }
            
            // 如果缓存中没哟数据从网络中下载
            self.loadNetworkStatus(since_id, max_id: max_id, finished:finished)
        }
    }
    // MARK: - 从本地加载微博数据
    func loadCacheStatus(since_id : String, max_id: String,finished : (models : [GDWStatusViewModel]?,error : NSError?) ->Void){
    
        // 1.获取用户ID
        guard let userId = GDWUserAccount.loadUserAccount()?.uid else {
            
            return
        }
        
        // 2.定义sql语句
        var sql = "SELECT * FROM T_Status \n" +
        "WHERE userId = '\(userId)' \n"
        if since_id != "0"
        {
            sql += "AND  statusId > '\(since_id)' \n"
        }else if max_id != "0"
        {
            
            sql += "AND  statusId <= '\(Int(max_id)! - 1)' \n"
        }
        sql += "ORDER BY statusId DESC LIMIT 20;"
        
        // 3.执行sql语句
        SQLiteManager.shareInstance.dbQueue?.inDatabase({ (db) -> Void in
            do{
                // 3.1获取查询的结果集
               let result = try db.executeQuery(sql, values: nil)
                // 3.2遍历结果集将每条数据转化为GDWStatusViewModel模型
                var models = [GDWStatusViewModel]()
                
                while result.next()
                {
                     // 取出一条微博数据
                    let statusText = result.stringForColumn("statusText")
                    let data = statusText.dataUsingEncoding(NSUTF8StringEncoding)
                    
                    let dic = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    // 字典转模型
                    models.append(GDWStatusViewModel(status: GDWStatus(dict: dic as! [String : AnyObject])))
                }
                
                finished(models: models, error: nil)
            
            }
            catch{
            
                finished(models: nil, error: NSError(domain: "com.520.gdw", code: 1099, userInfo: ["message": "从数据库中获取微博数据失败"]))
            }
        })
        
        
    }
    // MARK: - 从网络上获取的微博数据
    func loadNetworkStatus(since_id: String,  max_id: String,finished : (models : [GDWStatusViewModel]?,error : NSError?)->()){
    
        // 1.获取微博数据
        NetworkTools.shareInstance.loadStatus(since_id, max_id: max_id) { (dicts, error) -> () in
            //print("从网络加载微博数据")
            // 1.安全校验
            if error != nil
            {
                finished(models: nil, error: error)
                return
            }

            guard let array = dicts else
            {
                finished(models: nil, error: NSError(domain: "com.520it.lnj", code: 1002, userInfo: ["message": "没有获取到微博数据"]))
                return
            }
             print(dicts)
            // 2.遍历字典数组, 处理微博数据
            var models = [GDWStatusViewModel]()
            for dict in array
            {
                models.append(GDWStatusViewModel(status:GDWStatus(dict: dict)))
            }

            // 3.处理下拉刷新的数据
            if since_id != "0"
            {
                // 将新的数据凭借到旧数据前面
                self.statuses = models + self.statuses!

            }else if max_id != "0"
            {
                // 将新的数据拼接到旧数据后面
                self.statuses = self.statuses! + models
            }else{
                self.statuses = models
            }
            
            // 4.缓存微博数据
            self.cacheStatus(array)
            // 5.缓存配图
            self.cacheImage(models, finished: finished)
        }

    
    }
    
    
    // MARK: - 从网络上获取的微博数据缓存到本地
    func cacheStatus(list : [[String :AnyObject]]){
    
        // 1.获取用户ID
        guard let userId = GDWUserAccount.loadUserAccount()?.uid else {
        
            return
        }
        
        SQLiteManager.shareInstance.dbQueue?.inTransaction({ (db, rollback) -> Void in
            
            for dict in list{
            
                // 2. 获取当前微博的id
                guard let idStr = dict["idstr"] as? String else {
                    
                    return
                }
                // 3.一条微博数据内容
                guard let data = try? NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)  else{
                    return
                }
                //将NSData数据转化为字符串
                guard let statusText = String(data: data, encoding: NSUTF8StringEncoding)else{
                    return
                }
                // 4.定义sql语句
                let sql = "INSERT INTO T_Status \n" +
                    "(statusId, statusText, userId) \n" +
                    "VALUES \n" +
                "(?, ?, ?);"
                // 5 执行sql语句
                do{
                    try db.executeUpdate(sql, values: [idStr,statusText,userId])
                }
                catch{
                    print(error)
                }
            
            }
        })
        
    }
    // MARK: - 清除本地数据库中的缓存数据
    class func clearCacheStatus(){
    
        // 1.获取作为判断条件的时间字符串
        let limitedTime = NSDate(timeIntervalSinceNow: -60*60*24*7)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = NSLocale(localeIdentifier: "en")
        let dateStr = formatter.stringFromDate(limitedTime)
        
        // 2.编写sql语句
        let sql = "DELETE FROM T_Status WHERE createDate <= '\(dateStr)';"
        
        // 3.执行sql语句
        SQLiteManager.shareInstance.dbQueue?.inTransaction({ (db, rollback) -> Void in
            
            try! db.executeUpdate(sql, values: nil)
        })
    
    }
    
    // MARK: - 缓存配图
    private func cacheImage(list: [GDWStatusViewModel], finished: (models: [GDWStatusViewModel]?, error: NSError?)->())
    {
        
        // 0.创建一个组
        let group = dispatch_group_create()
        
        // 1.取出所有微博模型
        for viewModel in list
        {
            // 2.安全校验
            guard let urls = viewModel.thumbnail_pics else
            {
                continue
            }
            
            // 3.从微博模型中取出所有的配图字典
            for url in urls
            {
                // 将当前操作添加到组中
                dispatch_group_enter(group)
                
                // 4.下载图片
                // 注意:downloadImageWithURL方法下载图片是在子线程下载的, 而回调是在主线程回调
                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (_, error, _, _, _) -> Void in
                    
                    // 将当前操作从组中移除
                    dispatch_group_leave(group)
                })
            }
            
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            // 执行回调
            finished(models: list, error: nil)
        }
    }

}



