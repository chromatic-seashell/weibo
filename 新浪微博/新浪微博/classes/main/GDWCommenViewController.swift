//
//  GDWCommenViewController.swift
//  新浪微博
//
//  Created by apple on 15/11/7.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit

class GDWCommenViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    //记录用户是否登录
    var isLogined : Bool = GDWUserAccount.login()
    var  visitorView : GDWVisitorView?
    
    // MARK: - 重写laadView方法
    override func loadView() {
        isLogined ? super.loadView() : setUpVisitorView()
    }
    
    private func setUpVisitorView(){
     
        //1.添加访客视图
        visitorView = GDWVisitorView.visitorViewfromNib()
        view = visitorView
        //2.监听按钮点击
        visitorView?.registerButton.addTarget(self, action: Selector("registerBtnClick"), forControlEvents:.TouchUpInside)
        visitorView?.loginButton.addTarget(self, action: Selector("loginBtnClick"), forControlEvents: UIControlEvents.TouchUpInside)
        // 3.添加导航条按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("registerBtnClick"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("loginBtnClick"))
        
    }
    
    
    // MARK: - 内部方法
    @objc  private func  loginBtnClick(){
        // 1.创建登录界面
        let sb = UIStoryboard(name: "GDWOAuthViewController", bundle: nil)
        let OAuthVc = sb.instantiateInitialViewController()!
        
        // 2.弹出登录界面
        presentViewController(OAuthVc, animated: true, completion: nil)
    
    }
    
    @objc  private func  registerBtnClick(){
        GDWLog("")
        
    }
    
    

    

    

}
