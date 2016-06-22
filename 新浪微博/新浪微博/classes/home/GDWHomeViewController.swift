//
//  GDWHomeViewController.swift
//  新浪微博
//
//  Created by apple on 15/11/7.
//  Copyright © 2015年 apple. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
import AFNetworking

class GDWHomeViewController: GDWCommenViewController{

    // MARK: - 成员变量
    //保存所有微博数据
    var statuses : [GDWStatusViewModel]?
        {
        return modelList.statuses
    }
    /// 缓存行高 key微博的ID, value对应的行高
    var rowHeightCache = [String: CGFloat]()
    /// 负责加载数据模型
    var modelList: GDWStatusViewModelList = GDWStatusViewModelList()
    /// 记录是否是上拉加载更多
    var pullupFlag = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //1.判断是否登录
        if !isLogined {
            visitorView?.setUpVisitorInfo(nil, title: "")
            return
        }
        
        //2.设置导航条
        setUpNavgationBar()
        
        //3.注册监听
        setUpObserver()
        
        //4.添加下拉刷新
        refreshControl = GDWRefreshControl()
        refreshControl?.addTarget(self, action: Selector("loadData"), forControlEvents: .ValueChanged)
        // 注意点:beginRefreshing并不会触发loadData
        refreshControl?.beginRefreshing()
        // 5.添加提示视图
        tipLabel.frame = CGRect(x: 0, y: -44 * 2, width: UIScreen.mainScreen().bounds.width, height: 44)
        navigationController?.navigationBar.insertSubview(tipLabel, atIndex: 0)
        
        //6.加载数据
        loadData()
        tableView.estimatedRowHeight = 100
        
        //开始网络状态监听
        reachabilityManager.startMonitoring()
    }
    
    // MARK: - 懒加载
    
    private var reachabilityManager : AFNetworkReachabilityManager = AFNetworkReachabilityManager.sharedManager()
    
    // 标题按钮
    private lazy var titleBtn: GDWTitleButton = {
        let btn = GDWTitleButton()
        let title = GDWUserAccount.loadUserAccount()!.screen_name ?? "雨浩天"
        btn.setTitle(title + " ", forState: .Normal)
        btn.addTarget(self, action: Selector("titleBtnClick:"), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    // 负责自定义转场的对象
    private lazy var popoverManager: GDWAnimationManager = {
        let manager = GDWAnimationManager()
        manager.presentedFrame = CGRect(x: 100, y: 56, width: 200, height: 400)
        return manager
    }()
    
    // 负责图片浏览器转场的对象
    private lazy var photoBroserAnimationManager : GDWPhotoBroserAnimationManager = GDWPhotoBroserAnimationManager()
    
    /// 提醒视图
    private lazy var tipLabel: UILabel = {
        // 1.创建UILabel
        let lb = UILabel()
        lb.textAlignment =  NSTextAlignment.Center
        lb.textColor = UIColor.whiteColor()
        lb.backgroundColor = UIColor.orangeColor()
        return lb
    }()

    // MARK: - 内部控制方法
    @objc private func loadData()
    {
        
        // 0.准备since_id/ max_id
        var since_id = statuses?.first?.status.idstr ?? "0"
        var max_id = "0"
        
        if pullupFlag
        {
            max_id = statuses?.last?.status.idstr ?? "0"
            since_id = "0"
        }
        
        // 1.获取微博数据
        modelList.loadStatus(since_id, max_id: max_id) { (models, error) -> () in
            // 1.安全校验
            if error != nil
            {
                SVProgressHUD.showErrorWithStatus("获取微博数据失败", maskType: SVProgressHUDMaskType.Black)
                return
            }
            // 2.显示刷新提醒
            self.showTipView(models!.count)
            
            // 3.设置数据
            self.tableView.reloadData()
            
            // 4.关闭刷新控件
            self.refreshControl?.endRefreshing()
        }
    }
    /// 显示刷新提醒
    private func showTipView(count: Int)
    {
        
        // 0.设置提醒文字
        tipLabel.text = (count == 0) ? "没有更多微博数据" : "刷新到\(count)条微博数据"
        
        // 1.保存原来的frame
        let rect = tipLabel.frame
        
        // 2.执行动画
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.tipLabel.frame = CGRect(origin: CGPoint(x: 0, y: 44), size: rect.size)
            }) { (_) -> Void in
                UIView.animateWithDuration(1.0, delay: 1.0, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                    self.tipLabel.frame = rect
                    }, completion: nil)
        }
    }

    // MARK: - 设置导航条
    private  func  setUpNavgationBar(){
        //1.初始化左右按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem.creatBarButtonItem("navigationbar_friendattention", target: self, action: "leftItemClick")
        navigationItem.rightBarButtonItem = UIBarButtonItem.creatBarButtonItem("navigationbar_pop", target: self, action: "rightItemClick")
        //2.设置中间的标题
        
        titleBtn.setTitle("chromaticShell", forState: UIControlState.Normal)
        titleBtn.addTarget(self, action: "titleBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.titleView = titleBtn
    
    }
    
    // 导航条上内部方法
    @objc private func leftItemClick()
    {
        print(__FUNCTION__)
    }
    
    @objc private func rightItemClick()
    {
        // 1.创建二维码界面
        let sb = UIStoryboard(name: "GDWQRCodeViewController", bundle: nil)
        let QRCodeVc = sb.instantiateInitialViewController()!
        
        // 2.弹出二维码界面
        presentViewController(QRCodeVc, animated: true, completion: nil)
    }
    
    @objc private  func titleBtnClick(btn: GDWTitleButton){
        //1.创建菜单
        let sb = UIStoryboard(name:"GDWPopoverController", bundle: nil)
        let popoverVc = sb.instantiateInitialViewController()!
        //转场方面的设置
        popoverVc.transitioningDelegate = popoverManager
        popoverVc.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        //2.显示菜单
        presentViewController(popoverVc, animated: true, completion: nil)
    }
    // MARK: - 注册监听
    private func setUpObserver(){
        //1.菜单的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("titleBtnChange"), name: GDWPopoverViewControllerShowClick, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("titleBtnChange"), name: GDWPopoverViewControllerDismissClick, object: nil)
        
        //2.图片游览器的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showPhotoBrowser:"), name: GDWPhotoBrowserShow, object: nil)
        
        //3.关闭图片浏览器的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("closePhotoBrowser:"), name: GDWPhotoBroserAnimationCloseNotification, object: nil)
    }
    /// 控制标题按钮箭头的方向
    @objc private func titleBtnChange()
    {
        titleBtn.selected = !titleBtn.selected
    }
    /// 图片游览器
    @objc private func showPhotoBrowser(notify : NSNotification){
    
        //0 进行安全校验
        guard let urls = notify.userInfo!["urls"] as? [NSURL] else {
            return
        }
        guard let path = notify.userInfo!["indexPath"] as? NSIndexPath  else {
            return
        }
        guard let pictureCollectionView = notify.object as? GDWCollectionView else{
        
            return
        }
        
        //1 创建图片游览器
        let browserVc = GDWPhotoBrowserController(urls: urls, path: path)
        
        //1.1自定义转场
        browserVc.transitioningDelegate = photoBroserAnimationManager
        //把当前点击图片的索引传给manager
        photoBroserAnimationManager.setDefaultInfo(path)
        
        //给转场对象设置代理
        photoBroserAnimationManager.photoBrowserDelegate = pictureCollectionView
        
        //1.2设置转场样式
        browserVc.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        //2 弹出图片浏览器
        presentViewController(browserVc, animated: true, completion: nil)
        
        
    }
    @objc private func closePhotoBrowser(notify : NSNotification){
    
        // 通过监听通知,修改photoBroserAnimationManager中path属性的值
        // photoBroserAnimationManager再通过代理,获得关闭时转场动画的数据
        guard let path = notify.userInfo!["indexPath"] as? NSIndexPath  else {
            return
        }
        photoBroserAnimationManager.setDefaultInfo(path)
    }
    
    
    ///移除监听者
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return statuses?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //1.取出模型
        let viewModel = statuses![indexPath.row]
        
        //2.缓存池中获取cell
        let cell = tableView.dequeueReusableCellWithIdentifier(GDWTableViewIdentifier.identifierWithViewModel(viewModel), forIndexPath: indexPath) as! GDWTableViewCell
        //3.设置数据
       cell.viewModel = viewModel
        //4判断是否是最后一个cell
        if indexPath.row == ((statuses!.count) - 1){
            pullupFlag = true
            //加载数据
            loadData()
        }
        
        return cell
    }
    
    // 返回当前行的行高
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // 0.取出模型
        let viewModel = statuses![indexPath.row]
        
        // 1.从缓存中获取
        if let height = rowHeightCache[viewModel.status.idstr ?? "0"]
        {
            // 有缓存直接返回
            return height
        }
        
        // 没有缓存数据
        // 1.1.拿到当前行的cell
        let cell = tableView.dequeueReusableCellWithIdentifier(GDWTableViewIdentifier.identifierWithViewModel(viewModel)) as! GDWTableViewCell
        // 1.2.计算行高
        let height = cell.caculateRowHeight(viewModel)
        
        // 1.3 将计算结果缓存起来
        rowHeightCache[viewModel.status.idstr ?? "0"] = height
        
        // 1.4返回行高
        return height
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 接收到内存警告, 将所有缓存移除
        rowHeightCache.removeAll()
    }
}



