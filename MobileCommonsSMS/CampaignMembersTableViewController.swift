//
//  CampaignMembersTableViewController.swift
//  MobileCommonsSMS
//
//  Created by Gustavo Tandeciarz on 10/28/15.
//  Copyright © 2015 NFL Players Association. All rights reserved.
//

import UIKit
import SWXMLHash

class CampaignMembersTableViewController: UITableViewController{
    
    var members = [Member]()
    var isLoading = false
    var loadingFromRefresh = false
    var campaign = Campaign!()
    var _subnum = 0
    var currentPage = 1
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var userLabel: UIBarButtonItem!
    
    override func viewDidLoad() {
        debugPrint(campaign)
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if(members.count == 0){
            loadData()
        }
        
    }
    @IBAction func SendCampaignBroadcast(sender: AnyObject) {
        self.performSegueWithIdentifier("SendCampaignBroadcast", sender: self)
    }
    
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.loadingFromRefresh = true
        loadData()
    }
    
    func loadData(){
        if(MCClient.sharedInstance.GetCredentials().Authenticated){
            let request = MCClient.sharedInstance.SendAPICall("campaign_subscribers",
                parameters: [
                    "campaign_id" : campaign.Id
                    ,"page" : self.currentPage
                ])
            debugPrint(request)
            request.response { (request, response, data, error) in
                self.members.removeAll()
                let xml = SWXMLHash.parse(data!)
                debugPrint(xml)
                let subNum = xml["response"]["subscriptions"].element!.attributes["num"];
                self._subnum = Int(subNum!)!
                for elem in xml["response"]["subscriptions"]["sub"] {
                    
                    
                    let id = elem["id"].element!.text!
                    let phone = elem["phone_number"].element!.text!
                    let item = Member(id: id,name: "", phone: phone);
                    self.members.append(item);
                }
                self.isLoading = false;
                
                self.tableView.reloadData()
                if(self.loadingFromRefresh == true){
                    self.refreshControl!.endRefreshing()
                    self.loadingFromRefresh = false
                }
            }
        }
    }
    
    @IBAction func unwindToCampaignMembers(segue: UIStoryboardSegue) {
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Campaign: \(campaign.Name)"
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Total: \(self.members.count) out of \(self._subnum)"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.members.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Member", forIndexPath: indexPath)
        
        if self.members.count >= indexPath.row
        {
            let member = self.members[indexPath.row]
            
            let stringts: NSMutableString = NSMutableString(string: member.Phone)
            stringts.insertString(" ", atIndex: 1)
            stringts.insertString("(", atIndex: 2)
            stringts.insertString(") ", atIndex: 6)
            stringts.insertString("-", atIndex: 11)
            
            
            cell.textLabel?.text = String(stringts)
            cell.detailTextLabel?.text = "ID: \(member.Id)"
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let detailsViewController: CampaignDetailController = segue.destinationViewController as? CampaignDetailController {
            detailsViewController.campaign = self.campaign
        }
        
        
    }
    
}