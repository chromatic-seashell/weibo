//
//  GDWPhotoBrowserController.swift
//  新浪微博
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit


class GDWPhotoBrowserController: UIViewController {

    /// 所有需要显示的图片
    var urls: [NSURL]?
    /// 当前点击图片的索引
    var path : NSIndexPath?{
        didSet{
             //collectionView.scrollToItemAtIndexPath(path!, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        }
    }
    
    
    init( urls : [NSURL],path : NSIndexPath){
        self.urls = urls
        self.path = path
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //1.添加子控件
        view.addSubview(colseButton)
        view.addSubview(saveButton)
        view.insertSubview(collectionView, atIndex: 0)
        
        
        //2.布局子控件
        colseButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(20)
            make.bottom.equalTo(view.snp_bottom).offset(-20)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        saveButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(view).offset(-20)
            make.bottom.equalTo(view.snp_bottom).offset(-20)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        collectionView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
    }
    /*
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //collectionView.scrollToItemAtIndexPath(path!, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
        //GDWLog("")
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
     
        //GDWLog("")
        //collectionView.setContentOffset(CGPointMake(500, 0), animated:false)
    }
    */
    // MARK: 点中那张图片显示那张
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.scrollToItemAtIndexPath(path!, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
    }

    // MARK: - 内部控制方法
    @objc private func closeBtnClick()
    {
        //print("关闭图片浏览器")
        
        guard let indexPath = collectionView.indexPathsForVisibleItems().first else{
          return
        }
        
        // 发送通知把所选的indexPath传给转场的代理
        NSNotificationCenter.defaultCenter().postNotificationName(GDWPhotoBroserAnimationCloseNotification, object: nil, userInfo: ["indexPath" : indexPath])
        // 关闭图片浏览器
        dismissViewControllerAnimated(true, completion: nil)
    }
    @objc private func saveBtnClick()
    {
        GDWLog("保存图片")
    }
    // MARK: - 懒加载
    //关闭按钮
    private lazy var colseButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("关闭", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        btn.addTarget(self, action: Selector("closeBtnClick"), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    // 保存按钮
    private lazy var saveButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("保存", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        btn.addTarget(self, action: Selector("saveBtnClick"), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    // collectionLayout
    private var collectionLayout : GDWPhotoBrowserLayout = GDWPhotoBrowserLayout()
    // collectionView
    private lazy var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.collectionLayout)
        collectionView.registerClass(GDWPhotoBrowserCell.self, forCellWithReuseIdentifier: "browserCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        return  collectionView
    }()
    
}

// MARK: - UICollectionViewDataSource
extension GDWPhotoBrowserController : UICollectionViewDataSource{

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (urls?.count)!
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
         //GDWLog("")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("browserCell", forIndexPath: indexPath) as! GDWPhotoBrowserCell
        cell.backgroundColor = UIColor.lightGrayColor()
        // 给cel设置数据
        cell.url = urls![indexPath.item]
        cell.delegate = self
        return cell
    }
}
extension GDWPhotoBrowserController : UICollectionViewDelegate{

    
}
// MARK: - GDWPhotoBrowserCellDelegate
extension GDWPhotoBrowserController : GDWPhotoBrowserCellDelegate{
    func photoBrowserCellDidClick(cell: GDWPhotoBrowserCell) {
        //print("关闭图片浏览器")
        guard let indexPath = collectionView.indexPathsForVisibleItems().first else{
            return
        }
        // 发送通知把所选的indexPath传给转场的代理
        NSNotificationCenter.defaultCenter().postNotificationName(GDWPhotoBroserAnimationCloseNotification, object: nil, userInfo: ["indexPath" : indexPath])
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - GDWPhotoBrowserLayout
class  GDWPhotoBrowserLayout : UICollectionViewFlowLayout{

    override func prepareLayout() {
        itemSize = UIScreen.mainScreen().bounds.size
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.pagingEnabled = true
    }
}
