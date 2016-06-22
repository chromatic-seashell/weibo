//
//  GDWRefreshControl.swift
//  新浪微博
//
//  Created by apple on 15/11/17.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit
import SnapKit

class GDWRefreshControl: UIRefreshControl {

    override init() {
        super.init()
        
        //1.添加子控件
        addSubview(refreshView)
        //2.布局子控件
        refreshView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: 150, height: 60))
        }
        //3.KVO监听frame的变化
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit{
        removeObserver(self, forKeyPath: "frame")
    }
    
    // MARK: - 停止刷新
    override func endRefreshing() {
        super.endRefreshing()
        refreshView.endAnimation()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // 下拉刷新控件的frame一旦改变就会调用
        /*
        规律: 越往下拉Y越小, 越往上推Y越大
        */
        // 1.过滤垃圾数据
        if frame.origin.y == 0 || frame.origin.y == -64
        {
            return
        }
        // 2.检查是否已经触发下拉刷新
        if refreshing
        {
            refreshView.startAnimation()
            return
        }
        
        // 3.控制箭头旋转
        if frame.origin.y < -50 && !refreshView.showRotationFlag
        {
            refreshView.showRotationFlag = true
            refreshView.rotationArrow()
        }else if frame.origin.y > -50 && refreshView.showRotationFlag
        {
            refreshView.showRotationFlag  = false
            refreshView.rotationArrow()
        }

    }
    
    
    // MARK: - 懒加载
    private  lazy var refreshView = GDWRefreshView.refreshView()

}


class GDWRefreshView : UIView {
    
    /// 提示视图
    @IBOutlet weak var tipsView: UIView!
    /// 箭头视图
    @IBOutlet weak var arrowImageView: UIImageView!
    /// 菊花视图
    @IBOutlet weak var loadingImageVIew: UIImageView!
    
    //是否需要旋转标记
    var  showRotationFlag = false
    
    // MARK: - 快速创建视图
    class  func  refreshView() -> GDWRefreshView{
    
         return  NSBundle.mainBundle().loadNibNamed("GDWRefreshView", owner: nil, options: nil).last  as! GDWRefreshView
    }
    // MARK: - 箭头的动画
    private func  rotationArrow(){
    
        /*
        规律: 1.默认是顺时针 2.就近原则
        */
        var angle = CGFloat(M_PI)
        angle = showRotationFlag ? angle - 0.01 : angle + 0.01
        UIView.animateWithDuration(0.5) { () -> Void in
            self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, angle)
        }
    }
    // MARK: - 菊花旋转动画
    private  func startAnimation(){
    
       //1.隐藏提示图
        tipsView.hidden = true
       //2.根据key来取动画
        let key = "transform.rotation"
        if let _ = loadingImageVIew.layer.animationForKey(key)
        {
           return
        }
        //3.根据key来没有获取动画,就创建动画
        //创建动画
        let  anim = CABasicAnimation(keyPath:  "transform.rotation")
        //设置动画属性
        anim.toValue = 2 * M_PI
        anim.duration = 10.0
        anim.repeatCount = MAXFLOAT
        anim.removedOnCompletion = false
        //将动画添加到图层上
        loadingImageVIew.layer.addAnimation(anim, forKey: key)
    
    }
    // MARK: - 停止菊花动画
    private func endAnimation(){
    
       //1.显示提示图
        tipsView.hidden = false
        //2.移除动画
        loadingImageVIew.layer.removeAllAnimations()
    
    }
    
    
}