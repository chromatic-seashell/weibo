//
//  GDWTableViewCell.swift
//  新浪微博
//
//  Created by apple on 15/11/16.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit
import SDWebImage

// Swift中的枚举比OC强大很多, 可以赋值任意类型的数据, 以及可以定义方法
enum GDWTableViewIdentifier : String{
    //原创
   case OriginalCellIdentifier = "originalCell"
    //转发
   case ForWardCellIdentifier = "forWardCell"
   static func identifierWithViewModel(viewModel:GDWStatusViewModel) -> String
   {
    
    return (viewModel.status.retweeted_status != nil) ? self.ForWardCellIdentifier.rawValue  : self.OriginalCellIdentifier.rawValue
    }
}

class GDWTableViewCell: UITableViewCell {

    /// 用户头像
    @IBOutlet weak var iconImageView: UIImageView!
    /// 会员图标
    @IBOutlet weak var vipImageView: UIImageView!
    /// 昵称
    @IBOutlet weak var nameLabel: UILabel!
    /// 正文
    @IBOutlet weak var contentLabel: UILabel!
    /// 正文宽度约束
    @IBOutlet weak var contentLabelWidthCons: NSLayoutConstraint!
    
    /// 来源
    @IBOutlet weak var sourceLabel: UILabel!
    /// 时间
    @IBOutlet weak var timeLabel: UILabel!
    /// 认证图标
    @IBOutlet weak var verifiedImageView: UIImageView!
    /// 配图容器
    @IBOutlet weak var pictureCollectionView: GDWCollectionView!
    /// 底部视图
    @IBOutlet weak var footerView: UIView!
    
    /// 转发正文
    @IBOutlet weak var forwardLabel: UILabel!
    /// 转发正文宽度约束
    @IBOutlet weak var forwardLabelWidthCons: NSLayoutConstraint!
    /// 模型对象
    var viewModel: GDWStatusViewModel?{
    
        didSet{
            
            // 1.设置头像
            iconImageView.sd_setImageWithURL(viewModel?.avatarURL)
            
            // 2.认证图标
            //verifiedImageView.image = viewModel?.verifiedImage
            
            // 3.昵称
            nameLabel.text = viewModel?.status.user?.screen_name ?? ""
            
            //print(nameLabel.text)
            // 4.会员图标
            vipImageView.image = viewModel?.mbrankImage
            
            // 5.时间
            timeLabel.text = viewModel?.createdText ?? ""
            
            // 6.来源
            sourceLabel.text  = viewModel?.sourceText ?? ""
            
            // 5.正文
            contentLabel.text = viewModel?.status.text ?? ""
            
            // 6.转发正文
            if let temp = viewModel?.status.retweeted_status?.text
            {
               forwardLabelWidthCons.constant = UIScreen.mainScreen().bounds.size.width - 20
                forwardLabel.text = temp
            }
                        
            // 6.4给collectionView赋值
            pictureCollectionView.viewModel = viewModel
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        //设置正文的宽度约束
        contentLabelWidthCons.constant = UIScreen.mainScreen().bounds.size.width-20
    }
    // MARK: - 外部控制方法
    /// 计算当前行的高度
    func caculateRowHeight(viewModel: GDWStatusViewModel) -> CGFloat
    {
        // 1.将数据赋值给当前cell
        self.viewModel = viewModel
        
        // 2.更新UI
        layoutIfNeeded()
        
        // 3.返回行高
        return CGRectGetMaxY(footerView.frame)
    }
    
}



