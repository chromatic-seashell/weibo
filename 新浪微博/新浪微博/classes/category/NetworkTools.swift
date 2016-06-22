//
//  NetworkTools.swift
//  新浪微博
//
//  Created by apple on 15/11/13.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkTools: AFHTTPSessionManager {

    /// 单例
    static let shareInstance: NetworkTools = {
        // 注意: 指定BaseURL时一定要包含/
        let url = NSURL(string: "https://api.weibo.com/")
        let instance = NetworkTools(baseURL: url, sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
        //设置可序列化的文件格式
        instance.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json", "text/json", "text/javascript", "text/plain") as Set<NSObject>
        return instance
    }()
    
    /// 获取微博数据
    func loadStatus(finished: (dicts: [[String: AnyObject]]?, error: NSError?)->())
    {
        let path = "2/statuses/home_timeline.json"
        
        assert(GDWUserAccount.loadUserAccount() != nil, "必须授权之后才能获取微博数据")
        
        let parameters = ["access_token": GDWUserAccount.loadUserAccount()!.access_token!]
        
        NetworkTools.shareInstance.GET(path, parameters: parameters, success: { (task, objc) -> Void in
            
            // 1.从服务器返回的字典中取出字典数组
            guard let array = (objc as! [String : AnyObject])["statuses"] else
            {
                finished(dicts: nil, error: NSError(domain: "com.520it.lnj", code: 1001, userInfo: ["message": "没有找到statuses这个key"]))
                return
            }
            
            finished(dicts: array as? [[String : AnyObject]], error: nil)
            }) { (task, error) -> Void in
                finished(dicts: nil, error: error)
        }
    }
    
    /// 刷新微博时,获取微博数据
    func loadStatus(since_id: String,  max_id: String,finished: (dicts: [[String: AnyObject]]?, error: NSError?)->())
    {
        let path = "2/statuses/home_timeline.json"
        
        assert(GDWUserAccount.loadUserAccount() != nil, "必须授权之后才能获取微博数据")
        
        var parameters = ["access_token": GDWUserAccount.loadUserAccount()!.access_token!]
        if since_id != "0"
        {
            parameters["since_id"] = since_id
        }else if max_id != "0"
        {
            let temp = Int(max_id)! - 1
            parameters["max_id"] = "\(temp)"
        }
        
        NetworkTools.shareInstance.GET(path, parameters: parameters, success: { (task, objc) -> Void in
            
            // 1.从服务器返回的字典中取出字典数组
            guard let array = (objc as! [String : AnyObject])["statuses"] else
            {
                finished(dicts: nil, error: NSError(domain: "com.520it.lnj", code: 1001, userInfo: ["message": "没有找到statuses这个key"]))
                return
            }
            
            finished(dicts: array as? [[String : AnyObject]], error: nil)
            }) { (task, error) -> Void in
                finished(dicts: nil, error: error)
        }
    }
    
    
}
