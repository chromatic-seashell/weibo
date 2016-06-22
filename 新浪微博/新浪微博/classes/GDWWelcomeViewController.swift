//
//  GDWWelcomeViewController.swift
//  新浪微博
//
//  Created by apple on 15/11/14.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit
import SDWebImage

class GDWWelcomeViewController: UIViewController {

    
    /// 头像距离底部约束
    @IBOutlet weak var iconBottomCons: NSLayoutConstraint!
    /// 欢迎回来
    @IBOutlet weak var tipLabel: UILabel!
    /// 头像容器
    @IBOutlet weak var iconView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置头像
        // 断言: 断定一定有授权模型, 如果没有程序就会崩溃, 并且会输出后面message中的内容
        assert(GDWUserAccount.loadUserAccount() != nil, "用户当前还没有授权")
        
        let url = NSURL(string: GDWUserAccount.loadUserAccount()!.avatar_large!)
        iconView.sd_setImageWithURL(url)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let offset = view.bounds.height - iconBottomCons.constant
        iconBottomCons.constant =  offset
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.tipLabel.alpha = 1.0
                    }, completion: { (_) -> Void in
                        // 发送通知, 通知AppDelegate切换根控制器
                        NSNotificationCenter.defaultCenter().postNotificationName(GDWChangeRootViewControllerNotification, object: self, userInfo: nil)
                })
        }
    }

}
