//
//  GDWTabBarController.swift
//  新浪微博
//
//  Created by apple on 15/11/6.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit

class GDWTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
           设置tabBar的显示样式:
           1在当前控制器中设置主题颜色
           2在AppDelegate中设置外观颜色
            UITabBar.appearance().tintColor=UIColor.orangeColor()
        */
        tabBar.tintColor = UIColor.orangeColor()
        
    }
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        //1.添加加号按钮到tabBar
        tabBar.addSubview(plusButton)
        //2.设置按钮的位置
        let width = tabBar.bounds.width / CGFloat(childViewControllers.count)
        let height = tabBar.bounds.height
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        plusButton.frame = CGRectOffset(rect, 2 * width, 0)
        
    }
    
    /* +号按钮的懒加载 */
    lazy var  plusButton : UIButton={
         let btn = UIButton(imageName: "tabbar_compose_icon_add", backgroundImageName: "tabbar_compose_button")
        
        btn.addTarget(self, action: Selector("plusBtnClick"), forControlEvents: UIControlEvents.TouchUpInside)
        
         return btn
    }()
    /*
     MARK: - 内部控制方法
     如果给一个方法加上private, 那么这个方法就只能在当前文件中访问
     private不光能够修饰方法, 还可以修改类/属性
     注意: 按钮的点击事件是由运行循环动态派发的, 而如果将方法标记为私有的, 那这个方法在外界就拿不到, 所以动态派发时就找不到该方法
     只要加上@objc, 那么就可以让私有方法支持动态派发
    */
     @objc private  func  plusBtnClick(){
      
        GDWLog("btn")
        /* 使tabBarVc显示index对应的控制器 */
        //selectedIndex = 2
      
    }
    
    /* 纯代码时添加自控制器 */
    func  setUpChildViewController(){
     
        
        /* 通过字符串生成类名,来创建对象,添加自控制器 */
        addChildViewControllerWithString("GDWHomeViewController", imageName: "tabbar_home", title: "首页")
        addChildViewControllerWithString("GDWMessageViewController", imageName: "tabbar_message_center", title: "消息")
        addChildViewControllerWithString("GDWDiscoverViewController", imageName: "tabbar_discover", title: "发现")
        addChildViewControllerWithString("GDWMeViewController", imageName: "tabbar_profile", title: "我")
        
        /*:通过控制器对象,添加自控制器
        addChildViewController(GDWHomeViewController(), imageName: "tabbar_home", title: "首页")
        addChildViewController(GDWMessageViewController(), imageName: "tabbar_message_center", title: "消息")
        addChildViewController(GDWDiscoverViewController(), imageName: "tabbar_discover", title: "发现")
        addChildViewController(GDWMeViewController(), imageName: "tabbar_profile", title: "我")
        */
    }
    /* 通过字符串生成类名,来创建对象,添加自控制器 */
    func  addChildViewControllerWithString(childVcName: String,  imageName:String , title:String ){
        //1.获取命名空间
        guard let workSpaceName =  NSBundle.mainBundle().infoDictionary!["CFBundleExecutable"] as? String  else{
        
            GDWLog("没有获取命名空间")
            return
        }
        
        //2通过字符串创建一个类名
        let childVcClass:AnyObject? = NSClassFromString(workSpaceName + "." + childVcName)
        
        guard let childClass = childVcClass as? UIViewController.Type
            else{
            GDWLog("childClass类名没有创建成功")
            return
        }
        //3创建自控制器
        let  childVc = childClass.init()
        
        //3.1设置控制器属性
        //设置图片
        childVc.tabBarItem.image=UIImage(named: imageName)
        childVc.tabBarItem.selectedImage = UIImage(named:imageName + "_highlighted")
        //设置标题
        childVc.title=title
        //设置背景颜色
        childVc.view.backgroundColor = UIColor.lightGrayColor()
        
        //3.2导航控制器
        let nav = UINavigationController(rootViewController: childVc)
        
        //3.3添加自控制器
        addChildViewController(nav)
    
        
    }
    /* 通过控制器对象,添加自控制器 */
    func addChildViewController(childVc: UIViewController,  imageName:String , title:String) {
        
        //1.设置控制器属性
        //设置图片
        childVc.tabBarItem.image=UIImage(named: imageName)
        childVc.tabBarItem.selectedImage = UIImage(named:imageName + "_highlighted")
        //设置标题
        childVc.title=title
        //设置背景颜色
        childVc.view.backgroundColor = UIColor.lightGrayColor()
        
        //2.导航控制器
        let nav = UINavigationController(rootViewController: childVc)
        
        //3.添加自控制器
        addChildViewController(nav)
    }

}
