//
//  GDWOAuthViewController.swift
//  新浪微博
//
//  Created by apple on 15/11/13.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit

class GDWOAuthViewController: UIViewController {

    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.加载登录界面
        loadPage()
    }
    // MARK: - 内部控制方法
    @IBAction func leftBtnClick(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    /// 自定义填充账号密码
    @IBAction func rightBtnClick(sender: AnyObject) {
        
        let js = "document.getElementById('userId').value = 'gdw994773831@163.com';" + "document.getElementById('passwd').value = 'gdw15937685448';"
        // "document.getElementById('passwd').value = '123456789';"
        webView.stringByEvaluatingJavaScriptFromString(js)
    }
    
    /// 加载登录界面
    private func loadPage()
    {
        let str = "https://api.weibo.com/oauth2/authorize?client_id=\(WB_App_Key)&redirect_uri=\(WB_Redirect_URI)"
        guard let url = NSURL(string: str) else
        {
            return
        }
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }

    

}

extension GDWOAuthViewController: UIWebViewDelegate
{
    /// webview每次请求一个新的地址都会调用该方法, 返回true代表允许访问, 返回flase代表不允许方法
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        // 1.判断是否是授权回调地址, 如果不是就允许继续跳转
        guard let urlStr = request.URL?.absoluteString where urlStr.hasPrefix(WB_Redirect_URI)  else
        {
            // : https://api.weibo.com/
           
            return true
        }
        
        // 2.判断是否授权成功
        let code = "code="
        guard urlStr.containsString(code) else
        {
            // 授权失败
            return false
        }
        
        // 3.授权成功
        if let temp = request.URL?.query
        {
            // 3.1截取code=后面的字符串
            let codeStr = temp.substringFromIndex(code.endIndex)
            
            // 3.2利用RequestToken换取AccessToken
            loadAccessToken(codeStr)
        }
        
        
        return false
    }
    
    /// 根据RequestToken换取AccessToken
    private func loadAccessToken(codeStr: String)
    {
        let path = "oauth2/access_token"
        let parameters = ["client_id": WB_App_Key, "client_secret": WB_App_Secret, "grant_type": "authorization_code", "code": codeStr, "redirect_uri": WB_Redirect_URI]
        NetworkTools.shareInstance.POST(path, parameters: parameters, success: { (task, objc) -> Void in
            
            //1.将授权信息转化为模型
            let userAccount = GDWUserAccount(dict: objc as! [String: AnyObject])
            //2.根据授权信息获取用户信息
            self.loadUserInfo(userAccount)
                        
            }) { (task, error) -> Void in
        }
    }
    /// 获取用户信息
    private func loadUserInfo(account: GDWUserAccount)
    {
        let path = "2/users/show.json"
        let parameters = ["access_token": account.access_token!, "uid": account.uid!]
        NetworkTools.shareInstance.GET(path, parameters: parameters, success: { (task, objc) -> Void in
            
            // 1.取出获取到的用户信息
            let dict = objc as! [String: AnyObject]
            account.screen_name = dict["screen_name"] as? String
            account.avatar_large = dict["avatar_large"] as? String
            
            // 2.保存授权信息
            account.saveAccount()
            
            // 3.切换到欢迎界面
            // 发送通知, 通知AppDelegate切换根控制器
            NSNotificationCenter.defaultCenter().postNotificationName(GDWChangeRootViewControllerNotification, object: self, userInfo: ["message": true])
            
            
            }) { (task, error) -> Void in
                
        }
    }
    
    
}


