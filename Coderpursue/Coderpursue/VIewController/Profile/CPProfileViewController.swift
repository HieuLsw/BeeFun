//
//  CPProfileViewController.swift
//  Coderpursue
//
//  Created by wenghengcong on 15/12/30.
//  Copyright © 2015年 JungleSong. All rights reserved.
//

import UIKit
import Kingfisher
import Foundation

class CPProfileViewController: CPBaseViewController {
    
    @IBOutlet weak var profileBgV: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pvc_backImgV: UIImageView!
    @IBOutlet weak var pvc_avatarImgV: UIImageView!
    @IBOutlet weak var pvc_nameLabel: UILabel!
    @IBOutlet weak var pvc_emailLabel: UIButton!
    @IBOutlet weak var pvc_loginBtn: UIButton!
    @IBOutlet weak var pvc_editProfileBtn: UIButton!
    
    @IBOutlet weak var reposBgV: UIView!
    @IBOutlet weak var followerBgV: UIView!
    @IBOutlet weak var followingBgV: UIView!
    
    @IBOutlet weak var pvc_numOfReposLabel: UILabel!
    @IBOutlet weak var pvc_numOfFollwerLabel: UILabel!
    @IBOutlet weak var pvc_numOfFollowingLabel: UILabel!
    
    @IBOutlet weak var pvc_reposLabel: UILabel!
    @IBOutlet weak var pvc_followersLabel: UILabel!
    @IBOutlet weak var pvc_followingLabel: UILabel!
    
    
    var isLoingin:Bool = false
    var user:ObjUser?
    let cellId = "CPSettingsCell"
    var settingsArr:[[ObjSettings]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pvc_addButtonTarget()
        pvc_loadUserinfoData()
        pvc_loadSettingPlistData()
        pvc_customView()
        pvc_setupTableView()
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pvc_loadUserinfoData", name: CPNotiName.GitLoginSuccessfulNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: load data 
    func pvc_loadUserinfoData() {
        user = UserInfoHelper.sharedInstance.user
        isLoingin = UserInfoHelper.sharedInstance.isLoginIn
        
        if user != nil {
            print("user\(user!.name)")
            pvc_updateViewWithUserData()
        }
    }
    
    func pvc_loadSettingPlistData() {
        if let path = NSBundle.mainBundle().pathForResource("CPSettings", ofType: "plist") {
            let dictArr = NSArray(contentsOfFile: path)!
            // use swift dictionary as normal
            print(dictArr)
            for item in dictArr {
                
                var section:[ObjSettings] = []
                let sectionArr = item as! [AnyObject]
                
                for rowdict in sectionArr {
                    let settings = ObjSettings()
                    settings.setValuesForKeysWithDictionary(rowdict as! Dictionary)
                    section.append(settings)
                    
                }
                
                settingsArr.append(section)
            }
            
            print(settingsArr)
            self.tableView.reloadData()
        }

    }
    
    // MARK: view
    
    func pvc_customView() {
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.pvc_avatarImgV.layer.cornerRadius = self.pvc_avatarImgV.width/2
        self.pvc_avatarImgV.layer.masksToBounds = true
        
        self.pvc_nameLabel.textColor = UIColor.whiteColor()
        self.pvc_emailLabel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.pvc_emailLabel.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        
        self.pvc_loginBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.pvc_loginBtn.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        
        self.pvc_numOfReposLabel.textColor = UIColor.labelTitleTextColor()
        self.pvc_reposLabel.textColor = UIColor.labelSubtitleTextColor()
        
        self.pvc_numOfFollwerLabel.textColor = UIColor.labelTitleTextColor()
        self.pvc_followersLabel.textColor = UIColor.labelSubtitleTextColor()
        
        self.pvc_numOfFollowingLabel.textColor = UIColor.labelTitleTextColor()
        self.pvc_followingLabel.textColor = UIColor.labelSubtitleTextColor()
        
        //add border to sperator three columns
        self.reposBgV.addOnePixelAroundBorder(UIColor.lineBackgroundColor())
        self.followerBgV.addOnePixelAroundBorder(UIColor.lineBackgroundColor())
        self.followingBgV.addOnePixelAroundBorder(UIColor.lineBackgroundColor())
        
        pvc_updateViewWithUserData()
    }
    
    func pvc_updateViewWithUserData() {
        
        self.pvc_nameLabel.hidden = !isLoingin
        self.pvc_emailLabel.hidden = !isLoingin
        
        self.pvc_editProfileBtn.hidden = !isLoingin
        self.pvc_loginBtn.hidden = isLoingin
        
        if isLoingin {
            self.pvc_avatarImgV.kf_setImageWithURL( NSURL(string: user!.avatar_url!)!, placeholderImage: nil)
            self.pvc_numOfReposLabel.text = String(format: "%ld", arguments: [(user?.public_repos)!])
            self.pvc_numOfFollowingLabel.text = String(format: "%ld", arguments: [(user?.following)!])
            self.pvc_numOfFollwerLabel.text = String(format: "%ld", arguments: [(user?.followers)!])
        }else {
            
        }
        
    }
    
    func pvc_setupTableView() {
        
        self.tableView.dataSource=self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = UIColor.viewBackgroundColor()
//        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellId)    //register class by code
//        self.tableView.registerNib(UINib(nibName: "CPSettingsCell", bundle: nil), forCellReuseIdentifier: cellId) //regiseter by xib
//        self.tableView.addSingleBorder(UIColor.lineBackgroundColor(), at:UIView.ViewBorder.Top)
//        self.tableView.addSingleBorder(UIColor.lineBackgroundColor(), at:UIView.ViewBorder.Bottom)
    }
    
    
    func pvc_addButtonTarget() {
        pvc_editProfileBtn.addTarget(self, action: "pvc_editProfileAction:", forControlEvents: .TouchUpInside)
        pvc_loginBtn.addTarget(self, action: "pvc_loginAction:", forControlEvents: .TouchUpInside)

    }
    
    // MARK:  action
    func pvc_editProfileAction(sender:UIButton!) {
    }
    
    func pvc_loginAction(sender:UIButton) {
        
        pvc_showLoginInWebView()
    }
    
    
    // MARK: segue
    
    func pvc_showLoginInWebView() {
        NetworkHelper.clearCookies()
        
        let loginVC = CPGitLoginViewController()
        let url = String(format: "https://github.com/login/oauth/authorize/?client_id=%@&state=%@&redirect_uri=%@&scope=%@",GitHubKey.githubClientID(),"junglesong",GitHubKey.githubRedirectUrl(),"user,user:email,user:follow,public_repo,repo,repo_deployment,repo:status,delete_repo,notifications,gist,read:repo_hook,write:repo_hook,admin:repo_hook,admin:org_hook,read:org,write:org,admin:org,read:public_key,write:public_key,admin:public_key" )
        loginVC.url = url
        loginVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(loginVC, animated: true)
        
    }
    
}


extension CPProfileViewController : UITableViewDataSource {
	
	    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
	        return settingsArr.count
	    }
	
	    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let sectionArr = settingsArr[section]
	        return sectionArr.count
	    }
	
	    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            var cell = tableView .dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as? CPSettingsCell
            if cell == nil {
                cell = CPSettingsCell(style: UITableViewCellStyle.Default, reuseIdentifier:cellId)
            }
            let section = indexPath.section
            let row = indexPath.row
            let settings:ObjSettings = settingsArr[section][row]
            cell!.objSettings = settings
            
            //handle line in cell
            if row == 0 {
                cell!.topline = true
            }
            let sectionArr = settingsArr[section]
            if (row == sectionArr.count-1) {
                cell!.fullline = true
            }else {
                cell!.fullline = false
            }
            
            return cell!;
	    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view:UIView = UIView.init(frame: CGRectMake(0, 0, ScreenSize.ScreenWidth, 15))
        view.backgroundColor = UIColor.viewBackgroundColor()
        return view
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
	    
}
extension CPProfileViewController : UITableViewDelegate {
	
	    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            
	    }
	    
}