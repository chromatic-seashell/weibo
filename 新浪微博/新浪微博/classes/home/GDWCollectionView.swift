//
//  GDWCollectionView.swift
//  新浪微博
//
//  Created by apple on 15/11/17.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit
import SDWebImage
import AFNetworking


class GDWCollectionView: UICollectionView {

    /// 配图容器高度约束
    @IBOutlet weak var pictureCollectionViewHeightCons: NSLayoutConstraint!
    /// 配图容器宽度约束
    @IBOutlet weak var pictureCollectionVeiwWidthCons: NSLayoutConstraint!

    var viewModel:GDWStatusViewModel?{
    
        didSet{
        
            // 配图
            // 1计算配图和配图容器的尺寸
            let (itemSize, size) = caculateSize()
            // 2设置配图容器的尺寸
            pictureCollectionVeiwWidthCons.constant = size.width
            pictureCollectionViewHeightCons.constant = size.height
            
            // 3设置配图的尺寸
            if itemSize != CGSizeZero
            {
                (collectionViewLayout as! UICollectionViewFlowLayout).itemSize = itemSize
            }
            //刷新collectionView控件
            reloadData()
        }
    
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        delegate = self
        
    }
    // MARK: - 内部控制方法
    /// 计算配图的尺寸
    /// 第一个参数: imageView的尺寸
    /// 第二个参数: 配图容器的尺寸
    private func caculateSize() -> (CGSize, CGSize)
    {
        /*
        没有配图: 不显示CGSizeZero
        一张配图: 图片的尺寸就是配图和配图容器的尺寸
        四张配图: 田字格
        其他张配图: 九宫格
        */
        // 1.获取配图个数
        let count = viewModel?.thumbnail_pics?.count ?? 0
        
        // 2.判断有没有配图
        if count == 0
        {
            return (CGSizeZero, CGSizeZero)
        }
        
        // 3.判断是否是一张配图
        if count == 1
        {
            let urlStr = viewModel!.thumbnail_pics?.last!.absoluteString
            // 加载已经下载好得图片
            let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(urlStr)
            
            // 获取图片的size
            return (image.size, image.size)
        }
        
        let imageWidth:CGFloat = 90
        let imageHeight = imageWidth
        let imageMargin: CGFloat = 10
        // 4.判断是否是4张配图
        if count == 4
        {
            let col:CGFloat = 2
            // 计算宽度  宽度 = 列数 * 图片宽度+ (列数 - 1) * 间隙
            let width = col * imageWidth + (col - 1) * imageMargin
            // 计算高度
            let height = width
            return (CGSize(width: 90, height: 90), CGSize(width: width, height: height))
        }
        
        // 5.其它张配图  九宫格
        let col: CGFloat = 3
        let row  =  (count - 1) / 3 + 1
        let width = col * imageWidth + (col - 1) * imageMargin
        let height = CGFloat(row) * imageHeight + CGFloat(row - 1) * imageMargin
        return (CGSize(width: 90, height: 90), CGSize(width: width, height: height))
    }

    
}

// MARK: - GDWPhotoBroserAnimationManagerDelegate
extension GDWCollectionView : GDWPhotoBroserAnimationManagerDelegate{
    
    /// 返回和点击的UIImageView一模一样的UIImageView
    func photoBrowserImageView(path: NSIndexPath) -> UIImageView{
        
        //1.新建一个imageVeiw
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        //2将点击的图片赋值给imageView
        let url = viewModel?.thumbnail_pics![path.item]
        imageView.sd_setImageWithURL(url)
        
      return  imageView
    }
    /// 返回被点击的UIImageView相对于keywindow的frame
    func photoBrowserFromRect(path: NSIndexPath) -> CGRect{
        // 1.获取被点击的cell
        /*
         注意: 如果直接获取cell的frame是相对于collectionview的
         含义: 将cell.frame的坐标系从self转换到keyWindow
        */
        guard  let cell = cellForItemAtIndexPath(path) else {
        
            return CGRectZero
        }
        let frame = convertRect(cell.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
    
        return frame
        
    }
    /// 返回被点击的UIImageView最终在图片浏览器中显示的尺寸
    func photoBrowserToRect(path: NSIndexPath) -> CGRect{
    
        // 1.取出被点击的图片
        guard let key = viewModel?.thumbnail_pics![path.item].absoluteString else
        {
            return CGRectZero
        }
        
        // 利用SDWebImage从磁盘中获取图片
        let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key)
        
        
        // 屏幕宽高
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        
        // 1.按照宽高比缩放图片
        let scale = image.size.height / image.size.width
        // 计算图片的高度
        let height = scale * screenWidth
        
        // 2.判断是长图还是短图
        var offsetY: CGFloat = 0
        if height < screenHeight
        {
            // 短图, 需要居中
            //1.1计算偏移位
            offsetY = (screenHeight - height) * 0.5
        }
        return CGRect(origin: CGPoint(x: 0, y: offsetY), size: CGSize(width: screenWidth, height: height))
    
    }


}

// MARK: - UICollectionViewDataSource,UICollectionViewDelegate
extension GDWCollectionView :UICollectionViewDataSource,UICollectionViewDelegate{

    //  UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.thumbnail_pics?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pictureCell", forIndexPath: indexPath) as! GDWPictureCollectionViewCell
        
        let url = viewModel!.thumbnail_pics![indexPath.item]
        cell.imageURL = url
        
        return cell
    }
    // UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //1.点击图片是先下载,显示进度
        guard let url = viewModel?.bmidddle_pics![indexPath.item] else
        {
            return
        }
        
        /*
        监听网络注册是在GDWHomeViewController的viewDidLoad方法中设置的.
        
        */
        // 获取当前的网络状态
        let status = AFNetworkReachabilityManager.sharedManager().networkReachabilityStatus
        // 如果没有网络直接返回
        if status == AFNetworkReachabilityStatus.NotReachable{
           return
        }
        
        //判断当前的网络状态
//        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status) -> Void in
//            
//            
//                let netStatus = status as AFNetworkReachabilityStatus
//            
//                if netStatus == AFNetworkReachabilityStatus.ReachableViaWWAN{
//                    print("蜂窝网")
//                
//                }else if  netStatus == AFNetworkReachabilityStatus.ReachableViaWiFi{
//                
//                    print("WiFi")
//                }else if netStatus ==  AFNetworkReachabilityStatus.NotReachable{
//                
//                    print("没有网络")
//                }
//        }
        
        
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! GDWPictureCollectionViewCell
        //1.1下载图片
        SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: { (current, total) -> Void in
            
            cell.iconImageView.progregss = CGFloat(current) / CGFloat(total)
            
            }) { (_, error , _ , _ , _ ) -> Void in
                
                
                
                //2.图片下载完后,给首页控制器发送通知,modal出图片游览器
                NSNotificationCenter.defaultCenter().postNotificationName(GDWPhotoBrowserShow, object: self, userInfo: ["urls" : self.viewModel!.bmidddle_pics!,"indexPath" : indexPath])
        }
        
    }
}

// MARK: - 自定义cell
class GDWPictureCollectionViewCell: UICollectionViewCell {
    
    /// 配图
    @IBOutlet weak var iconImageView: ProgressImageView!
    
    @IBOutlet weak var gifImageView: UIImageView!
    /// 配图对应的URL
    var imageURL: NSURL?
        {
        didSet{
            //1.设置配图
            iconImageView.sd_setImageWithURL(imageURL)
            
            //2.是否显示gif图标
            guard let urlStr = imageURL?.absoluteString else
            {
                return
            }
            gifImageView.hidden = (urlStr as NSString).pathExtension != "gif"
        }
    }
}

