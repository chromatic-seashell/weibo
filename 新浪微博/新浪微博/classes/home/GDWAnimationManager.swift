//
//  GDWAnimationManager.swift
//  新浪微博
//
//  Created by apple on 15/11/9.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit

class GDWAnimationManager: UIPresentationController,UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning {

    /// 记录当前是否是展现
    private var isPresent = false
    /// 记录菜单的尺寸
    var presentedFrame = CGRectZero

    // MARK: - UIViewControllerTransitioningDelegate
    /*
    该方法用于告诉系统谁来负责自定义转场
    第一个参数: 被展现的控制
    第二个参数: 发起的控制器
    */
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController?
    {
        let pc = GDWPresentationViewController(presentedViewController: presented, presentingViewController: presenting)
        pc.presentedFrame = presentedFrame
        return pc
    }
    
    /// 告诉系统谁来负责展现的样式
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        isPresent = true
        NSNotificationCenter.defaultCenter().postNotificationName(GDWPopoverViewControllerShowClick, object: self)
        return self
    }
    
    /// 告诉系统谁来负责消失的样式
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        isPresent = false
        NSNotificationCenter.defaultCenter().postNotificationName(GDWPopoverViewControllerDismissClick, object: self)
        return self
    }
    

    
    
    
    // MARK: - UIViewControllerAnimatedTransitioning
    /// 该方法用于告诉系统展现或者消失动画的时长
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
    {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // 1.拿到菜单, 将菜单添加到容器视图上
        if isPresent
        {
            // 展现
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
            transitionContext.containerView()?.addSubview(toView!)
            
            // 2.执行动画
            toView?.transform = CGAffineTransformMakeScale(1.0, 0.0)
            toView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                toView?.transform = CGAffineTransformIdentity
                }) { (_) -> Void in
                    // 注意: 如果自定义转场动画, 那么必须告诉系统动画是否完成
                    transitionContext.completeTransition(true)
            }
        }else
        {
            // 消失
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
            // 注意: 以后如果使用CGFloat之后发现运行的结果和我们预期的结果不一致, 那么可以尝试修改CGFloat的值为一个很小的值
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                fromView?.transform = CGAffineTransformMakeScale(1.0, 0.0000001)
                }, completion: { (_) -> Void in
                    // 注意: 如果自定义转场动画, 那么必须告诉系统动画是否完成
                    transitionContext.completeTransition(true)
            })
            
        }
    }
    
}
