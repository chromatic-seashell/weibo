//
//  GDWQRCodeCreateViewController.swift
//  新浪微博
//
//  Created by apple on 16/2/20.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class GDWQRCodeCreateViewController : UIViewController{
    
    @IBOutlet weak var QRCodeImageView: UIImageView!
    var image : UIImage!
    
    override func viewDidLoad() {
        //1.创建滤镜对象
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        //2.恢复默认设置
        filter.setDefaults()
        //3.设置二维码数据
        let data = "雨浩天".dataUsingEncoding(NSUTF8StringEncoding)
        filter.setValue(data, forKey: "inputMessage")
        //4.从滤镜中取出二维码
        let ciImage = filter.outputImage!
        //5.显示二维码图片
        image = createNonInterpolatedUIImageFormCIImage(ciImage, size: 300)
        QRCodeImageView.image = image
    }
    // MARK: - 保存二维码到系统相册
    @IBAction func saveImageClick(sender: UIButton) {
        
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        
    }
    // 提示：参数 空格 参数别名: 类型
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject?){
        
        if didFinishSavingWithError != nil {
            print("图片保存失败")
            return
        }
        print("图片保存成功")
    }
    

    // MARK: - 生成高清二维码
    /**
     生成高清二维码
     
     - parameter image: 需要生成原始图片
     - parameter size:  生成的二维码的宽高
     */
    private func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        let extent: CGRect = CGRectIntegral(image.extent)
        let scale: CGFloat = min(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent))
        
        // 1.创建bitmap;
        let width = CGRectGetWidth(extent) * scale
        let height = CGRectGetHeight(extent) * scale
        let cs: CGColorSpaceRef = CGColorSpaceCreateDeviceGray()!
        let bitmapRef = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, cs, 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImageRef = context.createCGImage(image, fromRect: extent)
        
        CGContextSetInterpolationQuality(bitmapRef,  CGInterpolationQuality.None)
        CGContextScaleCTM(bitmapRef, scale, scale);
        CGContextDrawImage(bitmapRef, extent, bitmapImage);
        
        // 2.保存bitmap到图片
        let scaledImage: CGImageRef = CGBitmapContextCreateImage(bitmapRef)!
        
        return UIImage(CGImage: scaledImage)
    }

}
