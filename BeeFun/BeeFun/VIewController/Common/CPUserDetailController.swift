//
//  CPUserDetailController.swift
//  BeeFun
//
//  Created by WengHengcong on 3/10/16.
//  Copyright © 2016 JungleSong. All rights reserved.
//

import UIKit
import Moya
import Foundation
import MJRefresh
import ObjectMapper
import SwiftDate
import Kingfisher
import MBProgressHUD

public enum CPUserActionType:String {
    case Follow = "watch"
    case Repos = "star"
    case Following = "fork"
}


class CPUserDetailController: CPBaseViewController {

    var developerInfoV: CPDeveloperInfoView = CPDeveloperInfoView.init(frame: CGRect.zero)
    
    var tableView: UITableView = UITableView.init()
    var followBtn: UIButton = UIButton.init()
    
    var developer:ObjUser?
    var devInfoArr = [[String:String]]()

    var actionType:CPUserActionType = .Follow
    var followed:Bool = false
    
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    
    // MARK: - view cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dvc_customView()
        dvc_setupTableView()
        dvc_getUserinfoRequest()
        if let username = developer!.name {
            self.title = username
        }else{
            self.title = developer!.login!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dvc_checkUserFollowed()
    }
    
    // MARK: - view
    
    func dvc_customView(){
        
        self.tableView.isHidden = true
        self.developerInfoV.isHidden = true
        self.followBtn.isHidden = true
        
        self.rightItemImage = UIImage(named: "nav_share_35")
        self.rightItemSelImage = UIImage(named: "nav_share_35")
        // TODO: 隐藏分享按钮
        self.rightItem?.isHidden = true
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.view.backgroundColor = UIColor.viewBackgroundColor

        self.view.addSubview(developerInfoV)
        self.view.addSubview(tableView)
        self.view.addSubview(followBtn)
        developerInfoV.frame = CGRect.init(x: 0, y: uiTopBarHeight, width: ScreenSize.width, height: 183.0)
        
        let tabY = developerInfoV.bottom+15.0
        let tabH = ScreenSize.height-tabY
        tableView.frame = CGRect.init(x: 0, y: tabY, width: ScreenSize.width, height: tabH)
        
        developerInfoV.userActionDelegate = self
        
        followBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        followBtn.backgroundColor = UIColor.cpRedColor
        followBtn.layer.cornerRadius = 5
        followBtn.layer.masksToBounds = true
        followBtn.addTarget(self, action: #selector(CPUserDetailController.dvc_followAction), for: UIControlEvents.touchUpInside)
        
        let followX:CGFloat = 10.0
        let followW = ScreenSize.width-2*followX
        let followH:CGFloat = 40.0
        let followY = ScreenSize.height-followH-57.0
        followBtn.frame = CGRect.init(x: followX, y: followY, width: followW, height: followH)
        
        self.dvc_updateFolloweBtn()
    }
    
    func dvc_setupTableView() {
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.viewBackgroundColor
        self.tableView.allowsSelection = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        header.setTitle("Pull down to refresh", for: .idle)
        header.setTitle(kHeaderPullTip, for: .pulling)
        header.setTitle(kHeaderPullingTip, for: .refreshing)
        header.setRefreshingTarget(self, refreshingAction: #selector(CPUserDetailController.headerRefresh))
        // 现在的版本要用mj_header
//        self.tableView.mj_header = header
    }

    // MARK: - action

    func headerRefresh(){
        print("下拉刷新")
    }
    
    func dvc_updateFolloweBtn() {
        
        if(followed){
            followBtn.setTitle("Unfollow".localized, for: UIControlState())
        }else{
            followBtn.setTitle("Follow".localized, for: UIControlState())
        }
    }
    
    func dvc_updateViewContent() {
        
        self.tableView.isHidden = false
        self.developerInfoV.isHidden = false
        self.followBtn.isHidden = false
        
        if(developer==nil){
            return
        }
        
        devInfoArr.removeAll()
        
        if let _ = developer!.html_url {
            let homepageDic:Dictionary = ["key":"homepage","img":"user_home","desc":"Homepage".localized,"discolsure":"true"]
            devInfoArr.insert(homepageDic, at: 0)
        }
        
        if let joinTime:String = developer!.created_at {
            let ind = joinTime.characters.index(joinTime.startIndex, offsetBy: 10)
            let subStr = joinTime.substring(to: ind)
            let join = "Joined on".localized + " "+subStr
            let joinDic:[String:String] = ["key":"join","img":"user_time","desc":join,"discolsure":"false"]
            devInfoArr.append(joinDic)
        }
        
        if let location:String = developer!.location {
            let locDic:[String:String] = ["key":"location","img":"user_loc","desc":location,"discolsure":"false"]
            devInfoArr.append(locDic)
        }
        
        if let company = developer!.company {
            let companyDic:Dictionary = ["key":"company","img":"user_org","desc":company,"discolsure":"false"]
            devInfoArr.append(companyDic)
        }
        
        developerInfoV.developer = developer
        self.tableView.reloadData()
        JSMBHUDBridge.hideHud(view: self.view)
    }
    
    override func leftItemAction(_ sender: UIButton?) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func rightItemAction(_ sender: UIButton?) {
        
        let shareContent:ShareContent = ShareContent()
        shareContent.contentType = .image
        shareContent.source = .user
        
        if let name = developer?.name{
            shareContent.title = name
        }else{
            shareContent.title = developer?.login
        }
        
        shareContent.url = developer?.html_url

        if let bio = developer?.bio {
            shareContent.content = "Developer".localized + " \((developer?.name)!) " + ":\(bio)." + "\(shareContent.url!)"
        }else{
            shareContent.content = "Developer".localized + " \((developer?.login)!)." + "\(shareContent.url!)"
        }
        
        if let urlStr = developer?.avatar_url {
            shareContent.image = urlStr as AnyObject?
            ShareManager.shared.share(content: shareContent)
        }else{
            shareContent.image = UIImage(named: "app_logo_90")
            ShareManager.shared.share(content: shareContent)
        }
        
    }

    func dvc_followAction() {
        
        if(followBtn.currentTitle == "Follow".localized){
            self.dvc_followUserRequest()
        }else if(followBtn.currentTitle == "Unfollow".localized){
            self.dvc_unfolloweUserRequest()
        }
        
    }
    
    // MARK: - request

    func dvc_checkUserFollowed() {
    
        let username = developer!.login!
        
        Provider.sharedProvider.request(.checkUserFollowing(username:username) ) { (result) -> () in
            
            var message = kNoDataFoundTip
            
            JSMBHUDBridge.hideHud(view: self.view)
            print(result)
            switch result {
            case let .success(response):
                
                let statusCode = response.statusCode
                if(statusCode == CPHttpStatusCode.noContent.rawValue){
                    self.followed = true
                }else{
                    self.followed = false
                }
                self.dvc_updateFolloweBtn()
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                JSMBHUDBridge.showError(message, view: self.view)
                
            }
        }

    }
    
    func dvc_getUserinfoRequest(){
        
        JSMBHUDBridge.showHud(view: self.view)
        
        let username = developer!.login!

        Provider.sharedProvider.request(.userInfo(username:username) ) { (result) -> () in
            
            var message = kNoDataFoundTip
            
            
            switch result {
            case let .success(response):
                
                do {
                    if let result:ObjUser = Mapper<ObjUser>().map(JSONObject: try response.mapJSON() ) {
                        self.developer = result
                        self.dvc_updateViewContent()
                        
                    } else {

                    }
                } catch {

                    JSMBHUDBridge.showError(message, view: self.view)
                }
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                JSMBHUDBridge.showError(message, view: self.view)
                
            }
        }
        
        
    }
    
    func dvc_followUserRequest(){
        
        JSMBHUDBridge.showHud(view: self.view)
        
        let username = developer!.login!
        
        Provider.sharedProvider.request(.follow(username:username) ) { (result) -> () in
            
            var message = kNoDataFoundTip
            
            JSMBHUDBridge.hideHud(view: self.view)
            
            switch result {
            case let .success(response):
                
                let statusCode = response.statusCode
                if(statusCode == CPHttpStatusCode.noContent.rawValue){
                    self.followed = true
                    JSMBHUDBridge.showMessage("Follow".localized+kSignEmptySpace+"Success".localized, view: self.view)

                }
                self.dvc_updateFolloweBtn()
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                JSMBHUDBridge.showError(message, view: self.view)
                
            }
        }
        
        
    }

    
    func dvc_unfolloweUserRequest(){
        
        JSMBHUDBridge.showHud(view: self.view)
        
        let username = developer!.login!
        
        Provider.sharedProvider.request(.unfollow(username:username) ) { (result) -> () in
            
            var message = kNoDataFoundTip
            
            JSMBHUDBridge.hideHud(view: self.view)
            
            switch result {
            case let .success(response):
                
                let statusCode = response.statusCode
                if(statusCode == CPHttpStatusCode.noContent.rawValue){
                    self.followed = false
                    JSMBHUDBridge.showMessage("UnFollow".localized+kSignEmptySpace+"Success".localized, view: self.view)

                }
                
                self.dvc_updateFolloweBtn()
                
            case let .failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                JSMBHUDBridge.showError(message, view: self.view)
                
            }
        }
        
        
    }

    
    
}

extension CPUserDetailController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return devInfoArr.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        let cellId = "CPDevUserInfoCellIdentifier"

        var cell = tableView .dequeueReusableCell(withIdentifier: cellId) as? CPDevUserInfoCell
        if cell == nil {
            cell = (CPDevUserInfoCell.cellFromNibNamed("CPDevUserInfoCell") as! CPDevUserInfoCell)
        }
        
        //handle line in cell
        if row == 0 {
            cell!.topline = true
        }
        
        if (row == devInfoArr.count-1) {
            cell!.fullline = true
        }else {
            cell!.fullline = false
        }
        cell!.duic_fillData(devInfoArr[row])
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (section == 0){
            return nil
        }
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 10))
        view.backgroundColor = UIColor.viewBackgroundColor
 
        return view
    }
    
}

extension CPUserDetailController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0){
            return 0
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        let dic = devInfoArr[row]
        let cellKey = dic["key"]
        
        if cellKey == "homepage" {
            let webView = CPWebViewController()
            webView.url = developer?.html_url
            self.navigationController?.pushViewController(webView, animated: true)
        }

    }
    
}

extension CPUserDetailController:UserProfileActionProtocol {
    
    
    func viewFollowAction() {
        actionType = .Follow
        segueGotoViewController()
    }
    
    func viewReposAction() {
        actionType = .Repos
        segueGotoViewController()
    }
    
    func viewFollowingAction() {
        actionType = .Following
        segueGotoViewController()
    }
    
    
    func segueGotoViewController() {
        
        if (!UserManager.shared.isLogin){
            JSMBHUDBridge.showError(kLoginFirstTip, view: self.view)
            return
        }
        
        switch(actionType){
        case .Follow:
            let uname = developer!.login
            let dic:[String:String] = ["uname":uname!,"type":"follower"]
            let vc = CPUserListController()
            vc.hidesBottomBarWhenPushed = true
            vc.dic = dic
            vc.username = dic["uname"]
            vc.viewType = dic["type"]
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .Repos:
            
            let uname = developer!.login
            let dic:[String:String] = ["uname":uname!,"type":"myrepositories"]
            let vc = CPRepoListController()
            vc.hidesBottomBarWhenPushed = true
            vc.dic = dic
            vc.username = dic["uname"]
            vc.viewType = dic["type"]
            self.navigationController?.pushViewController(vc, animated: true)

        case .Following:
            let uname = developer!.login
            let dic:[String:String] = ["uname":uname!,"type":"following"]
            let vc = CPUserListController()
            vc.hidesBottomBarWhenPushed = true
            vc.dic = dic
            vc.username = dic["uname"]
            vc.viewType = dic["type"]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
}



