//
//  GDWPhotoBrowserCell.swift
//  新浪微博
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

// MARK: - 关闭图片浏览器的协议
protocol    GDWPhotoBrowserCellDelegate : NSObjectProtocol{

    func  photoBrowserCellDidClick(cell : GDWPhotoBrowserCell)
}


class GDWPhotoBrowserCell: UICollectionViewCell {
    
    /// 代理
    // 注意: 代理属性前面一定要写weak
    weak var delegate : GDWPhotoBrowserCellDelegate?
    
    var url : NSURL?{
        didSet{
        
            /// 1.重置cell参数
            reset()
            
            /// 2.设置图片
            iconImageView.sd_setImageWithURL(url) { (image, error, _ , _) -> Void in

                // 屏幕宽高
                let screenWidth = UIScreen.mainScreen().bounds.width
                let screenHeight = UIScreen.mainScreen().bounds.height
                
                // 1.按照宽高比缩放图片
                let scale = image.size.height / image.size.width
                let height = scale * screenWidth
                self.iconImageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: screenWidth, height: height))
                
                
                
                // 2.判断是长图还是短图
                if height < screenHeight
                {
                    // 短图, 需要居中
                    //1.1计算偏移位
                    let offsetY = (screenHeight - height) * 0.5
                    
                    // 1.2设置偏移位
                    self.scrollView.contentInset = UIEdgeInsets(top: offsetY, left: 0, bottom: offsetY, right: 0)
                }else
                {
                    // 长图, 不需要居中
                    self.scrollView.contentSize = self.iconImageView.frame.size
                }
            
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //1.添加子控件
        contentView.addSubview(scrollView)
        scrollView.addSubview(iconImageView)
        //2.布局子控件
        scrollView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(contentView)
            
        //3.给contentView添加手势
        //点击图片可以关闭图片浏览器,点击图片外的部分也能关闭图片游览器
            let tap = UITapGestureRecognizer(target: self, action: Selector("closePhotoBrowserVc"))
            contentView.addGestureRecognizer(tap)
            
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 重置所有属性
    private func reset()
    {
        scrollView.contentSize = CGSizeZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentInset = UIEdgeInsetsZero
        iconImageView.transform = CGAffineTransformIdentity
    }

    
    // MARK: - 懒加载
    private lazy var scrollView : UIScrollView = {
    
        let sl = UIScrollView()
        // 和缩放相关的设置
        sl.minimumZoomScale = 0.5
        sl.maximumZoomScale = 3.0
        sl.delegate = self
        return sl
    }()
    
    private lazy var iconImageView : UIImageView = {
        let imageView = UIImageView()
        /*
        //1.图片可交互
        imageView.userInteractionEnabled = true
        //2.给imageView添加手势
        let tap = UITapGestureRecognizer(target: self, action: Selector("closePhotoBrowserVc"))
        imageView.addGestureRecognizer(tap)
        */
        return imageView
    }()
    
    // MARK: - 内部方法
    @objc private func  closePhotoBrowserVc(){
    
        //GDWLog("关闭图片游览器")
        delegate?.photoBrowserCellDidClick(self)
    }
    
}


extension GDWPhotoBrowserCell : UIScrollViewDelegate{

    // MARK: - 返回要缩放符控件
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return iconImageView
    }
    // MARK: - scrollView缩放时会调用
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // 调整图片的位置, 让图片居中
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        
        // scrollView被缩放的view, 它的frame和bounds是有一定的区别的
        // bounds是的值是固定的, 而frame的值是变化的
        // 所以被缩放的控件的frame就是scrollView的contentSize
        // 也就是说frame的值和contentSize一样的
        
        let offsetY = (screenHeight - iconImageView.frame.height) * 0.5
        let offsetX = (screenWidth - iconImageView.frame.width) * 0.5
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)

    }
    
}
