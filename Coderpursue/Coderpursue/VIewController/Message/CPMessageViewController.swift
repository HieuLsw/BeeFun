//
//  CPMessageViewController.swift
//  Coderpursue
//
//  Created by wenghengcong on 15/12/30.
//  Copyright © 2015年 JungleSong. All rights reserved.
//

import UIKit
import Moya
import Foundation
import MJRefresh

class CPMessageViewController: CPBaseViewController {

    @IBOutlet weak var tableView: UITableView!

    var segControl:HMSegmentedControl! = HMSegmentedControl.init(sectionTitles: ["News","Notifications","Issues"])
    
    var newsData:[ObjRepos]! = []
    var notificationsData:[ObjNotification]! = []
    var issuesData:[ObjEvent]! = []

    var sortVal:String = "created"
    var directionVal:String = "desc"
    
    var newsPageVal = 1
    var notisPageVal = 1
    var issuesPageVal = 1

    var notiAllPar:Bool = false
    var notiPartPar:Bool = false
    
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    // 底部刷新
    let footer = MJRefreshAutoNormalFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mvc_checkUserSignIn()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func mvc_checkUserSignIn() {
        
        mvc_setupSegmentView()
        mvc_setupTableView()
        updateNetrokData()
        
    }
    
    func updateNetrokData() {
        
        if UserInfoHelper.sharedInstance.isLoginIn {
            self.tableView.hidden = false
            
            mvc_getNewsRequest(self.newsPageVal)
            mvc_getNotificationsRequest(self.notisPageVal)
            mvc_getIssuesRequest(self.issuesPageVal)
            
        }else {
            //加载未登录的页面
            self.tableView.hidden = true
        }
    }

    func mvc_setupSegmentView() {
        
        self.view.addSubview(segControl)
        segControl.verticalDividerColor = UIColor.lineBackgroundColor()
        segControl.verticalDividerWidth = 1
        segControl.verticalDividerEnabled = true
        segControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        segControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        segControl.selectionIndicatorColor = UIColor.cpRedColor()
        segControl.selectionIndicatorHeight = 2
        segControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.labelTitleTextColor(),NSFontAttributeName:UIFont.hugeSizeSystemFont()];
        
        segControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.cpRedColor(),NSFontAttributeName:UIFont.hugeSizeSystemFont()];
        
        segControl.indexChangeBlock = {
            (index:Int)-> Void in
            
            self.tableView.reloadData()
        }
        
        segControl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(64)
            make.height.equalTo(44)
            make.width.equalTo(self.view)
            make.left.equalTo(0)
        }
        
    }
    
    func mvc_setupTableView() {
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = UIColor.viewBackgroundColor()
        self.automaticallyAdjustsScrollViewInsets = false
        
        // 下拉刷新
        header.setTitle("Pull down to refresh", forState: .Idle)
        header.setTitle("Release to refresh", forState: .Pulling)
        header.setTitle("Loading ...", forState: .Refreshing)
        header.setRefreshingTarget(self, refreshingAction: Selector("headerRefresh"))
        // 现在的版本要用mj_header
        self.tableView.mj_header = header
        
        // 上拉刷新
        footer.setTitle("Click or drag up to refresh", forState: .Idle)
        footer.setTitle("Loading more ...", forState: .Pulling)
        footer.setTitle("No more data", forState: .NoMoreData)
        footer.setRefreshingTarget(self, refreshingAction: Selector("footerRefresh"))
        self.tableView.mj_footer = footer
    }
    
    // 顶部刷新
    func headerRefresh(){
        print("下拉刷新")
        if(segControl.selectedSegmentIndex == 0) {
            self.newsPageVal = 1
        }else if(segControl.selectedSegmentIndex == 1){
            self.notisPageVal = 1
        }else{
            self.issuesPageVal = 1
        }
        updateNetrokData()
    }
    
    // 底部刷新
    func footerRefresh(){
        print("上拉刷新")
        if(segControl.selectedSegmentIndex == 0) {
            self.newsPageVal++
        }else if(segControl.selectedSegmentIndex == 1){
            self.notisPageVal++
        }else{
            self.issuesPageVal++
        }
        updateNetrokData()
    }

    // MARK: fetch data form request
    
    func mvc_getNewsRequest(pageVal:Int) {
        
        print("page:\(pageVal)")
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Provider.sharedProvider.request(.MyStarredRepos(page:pageVal,perpage:7,sort: sortVal,direction: directionVal) ) { (result) -> () in
            
            var success = true
            var message = "Unable to fetch from GitHub"
            
            if(pageVal == 1) {
                self.tableView.mj_header.endRefreshing()
            }else{
                self.tableView.mj_footer.endRefreshing()
            }
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            switch result {
            case let .Success(response):
                
                do {
                    if let news:[ObjRepos]? = try response.mapArray(ObjRepos){
                        if(pageVal == 1) {
                            self.newsData.removeAll()
                            self.newsData = news!
                        }else{
                            self.newsData = self.newsData+news!
                        }
                        
                        self.tableView.reloadData()
                        
                    } else {
                        success = false
                    }
                } catch {
                    success = false
                    CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                }
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                success = false
                CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                
            }
            
        }
    }
    
    func mvc_getNotificationsRequest(pageVal:Int) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Provider.sharedProvider.request(.MyNotifications(page:pageVal,perpage:15,all:notiAllPar ,participating:notiPartPar) ) { (result) -> () in
            
            var success = true
            var message = "Unable to fetch from GitHub"
            
            if(pageVal == 1) {
                self.tableView.mj_header.endRefreshing()
            }else{
                self.tableView.mj_footer.endRefreshing()
            }
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            switch result {
            case let .Success(response):
                
                do {
                    if let notis:[ObjNotification]? = try response.mapArray(ObjNotification){
                        if(pageVal == 1) {
                            self.notificationsData.removeAll()
                            self.notificationsData = notis!
                        }else{
                            self.notificationsData = self.notificationsData+notis!
                        }
                        
                        self.tableView.reloadData()
                        
                    } else {
                        success = false
                    }
                } catch {
                    success = false
                    CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                }
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                success = false
                CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                
            }
        }
        
    }

    
    func mvc_getIssuesRequest(pageVal:Int) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        Provider.sharedProvider.request(.UserEvents(username:ObjUser.loadUserInfo()!.name! ,page:pageVal,perpage:10) ) { (result) -> () in
            
            var success = true
            var message = "Unable to fetch from GitHub"
            
            if(pageVal == 1) {
                self.tableView.mj_header.endRefreshing()
            }else{
                self.tableView.mj_footer.endRefreshing()
            }
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            switch result {
            case let .Success(response):
                
                do {
                    if let issues:[ObjEvent]? = try response.mapArray(ObjEvent){
                        if(pageVal == 1) {
                            self.issuesData.removeAll()
                            self.issuesData = issues!
                        }else{
                            self.issuesData = self.issuesData+issues!
                        }
                        
                        self.tableView.reloadData()
                        
                    } else {
                        success = false
                    }
                } catch {
                    success = false
                    CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                }
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                success = false
                CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                
            }
        }
        
    }

    
}

extension CPMessageViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if (segControl.selectedSegmentIndex == 0) {
//            return  self.newsData.count
            return 0
        }else if(segControl.selectedSegmentIndex == 1)
        {
            return self.notificationsData.count
        }
//        return self.issuesData.count
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        var cellId = ""
        
        if segControl.selectedSegmentIndex == 0 {
            
            cellId = "CPStarredReposCellIdentifier"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? CPStarredReposCell
            if cell == nil {
                cell = CPStarredReposCell(style: UITableViewCellStyle.Default, reuseIdentifier:cellId)
            }
            
            //handle line in cell
            if row == 0 {
                cell!.topline = true
            }
            if (row == newsData.count-1) {
                cell!.fullline = true
            }else {
                cell!.fullline = false
            }
            
            let repos = self.newsData[row]
            cell!.objRepos = repos
            
            return cell!;
            
        }else if(segControl.selectedSegmentIndex == 1) {
            
            cellId = "CPMesNotificationCellIdentifier"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? CPMesNotificationCell
            if cell == nil {
                cell = (CPMesNotificationCell.cellFromNibNamed("CPMesNotificationCell") as! CPMesNotificationCell)

            }
            
            //handle line in cell
            if row == 0 {
                cell!.topline = true
            }
            if (row == notificationsData.count-1) {
                cell!.fullline = true
            }else {
                cell!.fullline = false
            }
            
            let noti = self.notificationsData[row]
            cell!.noti = noti
            
            return cell!;
        }
        
        var cell:CPEventBaseCell?
        let event = self.issuesData[row]
        let eventType:EventType = EventType(rawValue: (event.type!))!
        

        //handle line in cell
        if row == 0 {
            cell!.topline = true
        }
        if (row == issuesData.count-1) {
            cell!.fullline = true
        }else {
            cell!.fullline = false
        }
        cell!.event = event
        
        return cell!;
        
    }
    
}
extension CPMessageViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if segControl.selectedSegmentIndex == 0 {
            
            return 85
            
        }else if(segControl.selectedSegmentIndex == 1){
            
            return 55
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}
