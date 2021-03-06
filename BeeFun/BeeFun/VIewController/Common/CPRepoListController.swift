//
//  CPRepoListController.swift
//  BeeFun
//
//  Created by wenghengcong on 16/1/30.
//  Copyright © 2016年 JungleSong. All rights reserved.
//

import UIKit
import Moya
import Foundation
import MJRefresh

class CPRepoListController: CPBaseViewController {

    var tableView: UITableView = UITableView.init()

    //incoming var
    var dic:[String:String]?
    var username:String?
    var viewType:String?
    
    var reposData:[ObjRepos]! = []
    var reposPageVal = 1
    var reposPerpage = 15
    
    var typeVal:String = "owner"
    var sortVal:String = "created"
    var directionVal:String = "desc"
    
    
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    // 底部刷新
    let footer = MJRefreshAutoNormalFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        rvc_addNaviBarButtonItem()
        rvc_setupTableView()
        rvc_selectDataSource()
        self.title = "Repositories".localized

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func leftItemAction(_ sender: UIButton?) {
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    func rvc_addNaviBarButtonItem() {
        
        /*
        let btnName = UIButton()
        btnName.setImage(UIImage(named: "bubble_consulting_chat-512"), forState: .Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.addTarget(self, action: Selector("tvc_rightButtonTouch"), forControlEvents: .TouchUpInside)
        
        //.... Set Right/Left Bar Button item
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        */
        


    }
    
    func rvc_rightButtonTouch() {
        
    }
    
    func rvc_setupTableView() {
        
        self.view.addSubview(tableView)
        self.tableView.frame = CGRect.init(x: 0, y: uiTopBarHeight, width: ScreenSize.width, height: ScreenSize.height-uiTopBarHeight)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.viewBackgroundColor
        self.automaticallyAdjustsScrollViewInsets = false
        
        // 下拉刷新
        header.setTitle("", for: .idle)
        header.setTitle(kHeaderPullTip, for: .pulling)
        header.setTitle(kHeaderPullingTip, for: .refreshing)
        header.setRefreshingTarget(self, refreshingAction: #selector(CPRepoListController.headerRefresh))
        // 现在的版本要用mj_header
        self.tableView.mj_header = header
        
        // 上拉刷新
        footer.setTitle("", for: .idle)
        footer.setTitle(kFooterLoadTip, for: .pulling)
        footer.setTitle(kFooterLoadNoDataTip, for: .noMoreData)
        footer.setRefreshingTarget(self, refreshingAction: #selector(CPRepoListController.footerRefresh))
        footer.isRefreshingTitleHidden = true
        self.tableView.mj_footer = footer
    }
    
    // 顶部刷新
    func headerRefresh(){
        print("下拉刷新")
        reposPageVal = 1
        rvc_selectDataSource()
    }
    
    // 底部刷新
    func footerRefresh(){
        print("上拉刷新")
        reposPageVal += 1
        rvc_selectDataSource()
    }
    
    func rvc_updateViewContent() {
        
        self.tableView.reloadData()
    }
    
    func rvc_selectDataSource() {
        
        if(self.viewType == "myrepositories") {
            rvc_getMyReposRequest()
        }else if(self.viewType == "forked"){
            rvc_getForkedReposRequst()
        }else{
            rvc_getMyReposRequest()
        }
        
    }
    
    // MARK: request for repos
    
    func rvc_getMyReposRequest() {
        
        if (username == nil){
            return
        }
        
        Provider.sharedProvider.request( .myRepos(page:self.reposPageVal,perpage:self.reposPerpage,type:self.typeVal, sort:self.sortVal ,direction:self.directionVal ) ) { (result) -> () in
            print(result)
            
            var message = kNoDataFoundTip
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            switch result {
            case let .success(response):
                
                do {
                    if let repos:[ObjRepos]? = try response.mapArray(ObjRepos.self){
                        if(self.reposPageVal == 1) {
                            self.reposData.removeAll()
                            self.reposData = repos!
                        }else{
                            self.reposData = self.reposData+repos!
                        }
                        self.rvc_updateViewContent()
                        
                    } else {

                        JSMBHUDBridge.showError(message, view: self.view)
                    }
                } catch {

                }
                //                self.tableView.reloadData()
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description

            }
            
        }
        
        
    }
    
    func rvc_getForkedReposRequst() {
        
    }    
}


extension CPRepoListController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  self.reposData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        var cellId = ""
        if(self.viewType == "myrepositories") {
            cellId = "CPMyReposCellIdentifier"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? CPMyReposCell
            if cell == nil {
                cell = (CPMyReposCell.cellFromNibNamed("CPMyReposCell") as! CPMyReposCell)
            }
            
            //handle line in cell
            if row == 0 {
                cell!.topline = true
            }
            if (row == reposData.count-1) {
                cell!.fullline = true
            }else {
                cell!.fullline = false
            }
            
            let repos = self.reposData[row]
            cell!.objRepos = repos
            
            return cell!;
        }
        
        cellId = "CPProfileReposCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? CPProfileReposCell
        if cell == nil {
            cell = (CPProfileReposCell.cellFromNibNamed("CPProfileReposCell") as! CPProfileReposCell)
        }
        
        //handle line in cell
        if row == 0 {
            cell!.topline = true
        }
        if (row == reposData.count-1) {
            cell!.fullline = true
        }else {
            cell!.fullline = false
        }
        
        let repos = self.reposData[row]
        cell!.objRepos = repos
        
        return cell!;
        
        
    }
    
}
extension CPRepoListController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let repos = self.reposData[indexPath.row]
        
        let vc = CPRepoDetailController()
        vc.hidesBottomBarWhenPushed = true
        vc.repos = repos
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

