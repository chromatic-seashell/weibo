//
//  GDWVisitorView.swift
//  新浪微博
//
//  Created by apple on 15/11/7.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit

class GDWVisitorView: UIView {

    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var contentLable: UILabel!
    @IBOutlet weak var rotationImage: UIImageView!

    @IBOutlet weak var iconImage: UIImageView!
    
    class func  visitorViewfromNib() ->GDWVisitorView{
        
        return NSBundle.mainBundle().loadNibNamed("GDWVisitorView", owner: nil, options: nil).last as! GDWVisitorView
    }
    
    
    // MARK: - 外部设值方法
    func setUpVisitorInfo(imageName: String?, title: String){
        //首页内容
        guard let name = imageName  else {
            //开启圆形图标动画
            startAnimation()
            return
        }
        //其他界面内容
        iconImage.image = UIImage(named: name)
        contentLable.text = title
        rotationImage.hidden = true
    
    }
    
    func  startAnimation(){
     
        let basicAnim = CABasicAnimation()
        basicAnim.keyPath="transform.rotation"
        basicAnim.toValue=M_PI * 2
        basicAnim.duration = 10
        basicAnim.repeatCount=MAXFLOAT
        // 告诉系统不要随便给我移除动画, 只有当控件销毁的时候才需要移除
        basicAnim.removedOnCompletion = false
        rotationImage.layer.addAnimation(basicAnim, forKey: nil)
    
    }

}
