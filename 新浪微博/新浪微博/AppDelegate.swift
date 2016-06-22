//
//  AppDelegate.swift
//  新浪微博
//
//  Created by apple on 15/11/6.
//  Copyright © 2015年 apple. All rights reserved.


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /// 打开数据库
        SQLiteManager.shareInstance.openDB("status.sqlite")
        
        
        //1.设置tabBar外观
        UITabBar.appearance().tintColor=UIColor.orangeColor()
        
        //2.注册通知,监听控制器的改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("switchRootViewController:"), name:GDWChangeRootViewControllerNotification, object: nil)
        
        window = UIWindow()
        window?.frame = UIScreen.mainScreen().bounds
        window?.rootViewController = defaultViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    deinit{
        //移除监听者
        NSNotificationCenter.defaultCenter().removeObserver(self)
    
    }
    
    // MARK: - 程序进入后台会调用
    func applicationDidEnterBackground(application: UIApplication) {
        //清除本地数据库缓存
        GDWStatusViewModelList.clearCacheStatus()
    }
    // MARK: - 程序结束调用
    func applicationWillTerminate(application: UIApplication) {
        //清除本地数据库缓存
        GDWStatusViewModelList.clearCacheStatus()
    }
    

}

extension AppDelegate{


    /// 切换根控制器器
    @objc private func switchRootViewController(notify: NSNotification)
    {
        if let _ = notify.userInfo
        {
            // 切换到欢迎界面
            window?.rootViewController = createViewController("GDWWelcomeViewController")
            return
        }
        
        // 切换到首页
        window?.rootViewController = createViewController("Main")
    }
    
    /// 返回默认控制器
    private func defaultViewController() -> UIViewController
    {
        if let _ = GDWUserAccount.loadUserAccount()
        {
            return isNewVersion() ? createViewController("GDWNewfeatureViewController") : createViewController("GDWWelcomeViewController")
        }
        return createViewController("Main")
    }
    
    /// 根据一个SB的名称创建一个控制器
    private func createViewController(viewControllerName: String) -> UIViewController
    {
        let sb = UIStoryboard(name: viewControllerName, bundle: nil)
        return sb.instantiateInitialViewController()!
    }
    
    /// 判断是否有新版本
    private func isNewVersion() -> Bool
    {
        // 1.从info.plist中获取当前软件的版本号
        let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        // 2.从沙盒中获取以前的软件版本号
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sanboxVersion = (userDefaults.objectForKey("CFBundleShortVersionString") as? String) ?? "0.0"
        
        // 3.利用"当前的"和"沙盒的"进行比较
        if currentVersion.compare(sanboxVersion) == NSComparisonResult.OrderedDescending
        {
            // 有新版本
            // 4.存储当前的软件版本号到沙盒中 1.0
            userDefaults.setObject(currentVersion, forKey: "CFBundleShortVersionString")
            userDefaults.synchronize() // iOS7以前需要这样做, iOS7以后不需要了
            return true
        }
        
        // 5.返回结果 true false
        return false
        
    }
    
}



/*
自定义LOG的目的:
在开发阶段自动显示LOG
在发布阶段自动屏蔽LOG

print(__FUNCTION__)  // 打印所在的方法
print(__LINE__)     // 打印所在的行
print(__FILE__)     // 打印所在文件的路径

方法名称[行数]: 输出内容
*/

func  GDWLog<T>(message:T , method:String = __FUNCTION__ , line : Int = __LINE__){

    #if DEBUG
    print("\(method)[\(line)]:\(message)")
    #endif
    
}

