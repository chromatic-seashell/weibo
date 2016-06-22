//
//  GDWPhotoBroserAnimationManager.swift
//  新浪微博
//
//  Created by apple on 16/3/18.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

// MARK: - 定义协议
protocol  GDWPhotoBroserAnimationManagerDelegate : NSObjectProtocol{

    /// 返回和点击的UIImageView一模一样的UIImageView
    func photoBrowserImageView(path: NSIndexPath) -> UIImageView
    /// 返回被点击的UIImageView相对于keywindow的frame
    func photoBrowserFromRect(path: NSIndexPath) -> CGRect
    /// 返回被点击的UIImageView最终在图片浏览器中显示的尺寸
    func photoBrowserToRect(path: NSIndexPath) -> CGRect
}

class GDWPhotoBroserAnimationManager: UIPresentationController {

    /// 当前被点击图片的索引
    private var path: NSIndexPath?
    
    /// 记录当前是否是展现
    private var isPresent = false
    
    /// 负责展现动画的代理
    weak var photoBrowserDelegate : GDWPhotoBroserAnimationManagerDelegate?
    
    
    /// 初始化方法
    func setDefaultInfo(path: NSIndexPath)
    {
        self.path = path
    }

    
}


extension GDWPhotoBroserAnimationManager : UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning{

    // MARK: - UIViewControllerTransitioningDelegate
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController?
    {
        
        return UIPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    /// 告诉系统谁来负责展现的样式
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        isPresent = true
        return self
    }
    
    /// 告诉系统谁来负责消失的样式
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        isPresent = false
        return self
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    /// 该方法用于告诉系统展现或者消失动画的时长
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
    {
        return 0.5
    }
    
    /// 无论是展现还是消失都会调用这个方法
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        // 1.拿到菜单, 将菜单添加到容器视图上
        if isPresent
        {
            
            // 1.1获取图片浏览器
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
            transitionContext.containerView()?.addSubview(toView!)
            toView?.alpha = 0.0

            // 1.2获取需要添加到容器视图上的UIImageView
            // 该方法必须返回一个UIImageView
            let iv  = photoBrowserDelegate!.photoBrowserImageView(path!)
            // 1.3获取需要添加到容器视图上的UIImageView的frame
            let fromRect = photoBrowserDelegate!.photoBrowserFromRect(path!)
            iv.frame = fromRect
            transitionContext.containerView()?.addSubview(iv)
            
            // 1.4获取需要添加到容器仕途上的UIImageView最终的frame
            let toRect = photoBrowserDelegate!.photoBrowserToRect(path!)
            
            // 2.执行动画
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                iv.frame = toRect
                }, completion: { (_) -> Void in
                    
                    // 删除iv
                    iv.removeFromSuperview()
                    
                    // 显示图片浏览器
                    toView?.alpha = 1.0
                    
                    // 告诉系统动画执行完毕
                    transitionContext.completeTransition(true)
            })
            
        }else
        {
            // 消失
            // 1.1获取图片浏览器
            let fromVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
            //将图片浏览器的view从容器view中移除
            fromVc?.view.removeFromSuperview()
            
            // 1.2获取需要添加到容器视图上的UIImageView
            // 该方法必须返回一个UIImageView
            let iv  = photoBrowserDelegate!.photoBrowserImageView(path!)
            
            // 1.3获取需要添加到容器视图上的UIImageView的frame
            let fromRect = photoBrowserDelegate!.photoBrowserToRect(path!)
            // 1.4获取需要添加到容器视图上的UIImageView最终的frame
            let toRect = photoBrowserDelegate!.photoBrowserFromRect(path!)
            
            iv.frame = fromRect
            transitionContext.containerView()?.addSubview(iv)
            
            
            // 2.执行动画
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                iv.frame = toRect
                }, completion: { (_) -> Void in
                    
                    // 删除iv
                    iv.removeFromSuperview()
                    
                    // 告诉系统动画执行完毕
                    transitionContext.completeTransition(true)
            })

        }
    }


}