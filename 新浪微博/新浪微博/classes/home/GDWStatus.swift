//
//  GDWStatus.swift
//  新浪微博
//
//  Created by apple on 15/11/15.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit

class GDWStatus: NSObject {
    /// 当前这条微博的发布时间
    var created_at: String?
    
    /// 来源
    var source: String?
    
    /// 字符串型的微博ID
    var idstr: String?
    
    /// 微博信息内容
    var text: String?
    
    /// 当前微博对应的用户
    var user: GDWUser?
    
    /// 存储所有配图字典
    var pic_urls: [[String: AnyObject]]?
    
    /// 转发微博
    var retweeted_status: GDWStatus?
    
    init(dict: [String: AnyObject])
    {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    // KVC的setValuesForKeysWithDictionary方法内部会调用下面这个方法
    override func setValue(value: AnyObject?, forKey key: String) {
        // 1.判断是否是用户
        if key == "user"
        {
            user = GDWUser(dict: value as! [String: AnyObject])
            return // 注意: 如果自己处理了, 那么就不需要父类处理了, 所以一定要写上return
        }
        // 2.判断是否是转发微博
        if key == "retweeted_status"
        {
            retweeted_status = GDWStatus(dict: value as! [String: AnyObject])
            return
        }
        super.setValue(value, forKey: key)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
    }
    
    override var description: String {
        let property = ["created_at", "source", "idstr", "text"]
        let dict = dictionaryWithValuesForKeys(property)
        return "\(dict)"
    }
}
