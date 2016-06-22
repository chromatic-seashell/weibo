//
//  UIButton + Extention.swift
//  新浪微博
//
//  Created by apple on 15/11/7.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit


extension UIButton {
    // 只要在构造方法前面加上convenience单词, 那么这就是一个便利构造方法
    // 便利构造方法: 仅仅是对原有构造方法的扩充, 主要是为了方便创建对象
    /*
    指定构造方法: init(xxx:xxx)
    1.必须调用"父类"super.init()初始化
    2.默认情况下系统会自动帮调用(编译器隐式的帮我们自动添加了一行super.init())
    便利构造方法: convenience init(xxx:xxx)
    1.必须调用"当前类"的指定构造方法
    2.不能调用super.init()
    3.也可以调用其他的便利构造方法, 但是其它构造方法中必须调用本类的指定构造方法
    */
    convenience init(imageName : String ,backgroundImageName : String){
    
        self.init()
        setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        setImage(UIImage(named: imageName + "_highlighted"), forState: UIControlState.Highlighted)
        
        setBackgroundImage(UIImage(named: backgroundImageName), forState: UIControlState.Normal)
        setBackgroundImage(UIImage(named: backgroundImageName + "_highlighted"), forState: UIControlState.Highlighted)
        
        sizeToFit()
    }

}
