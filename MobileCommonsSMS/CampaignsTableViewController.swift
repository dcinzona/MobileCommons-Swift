//
//  CompaniesTableViewController.swift
//  MobileCommonsSMS
//
//  Created by Gustavo Tandeciarz on 10/16/15.
//  Copyright © 2015 NFL Players Association. All rights reserved.
//

import UIKit
import SWXMLHash


class CampaignsTableViewController: UITableViewController {
    
    var campaigns = [Campaign]()
    var isLoading = false
    var loadingFromRefresh = false
    
    @IBOutlet var tableview: UITableView!
        
    @IBOutlet weak var userLabel: UIBarButtonItem!
        
    
    override func viewDidLoad() {
        self.title = "Campaigns"
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loggedOut:", name: "LoggedOut", object: nil)
        
        super.viewDidLoad()
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if(updateToolbarItems()){
            if(campaigns.count == 0){
                loadData()
            }
        }
        
    }
    
    func updateToolbarItems() -> Bool{
        if(MCClient.sharedInstance.GetCredentials().Authenticated){
            let username = MCClient.sharedInstance.GetCredentials().Username!;
            self.userLabel.title = "User: \(username)"
            return true
        }
        else{
            self.userLabel.title = "Not signed in"
            return false
        }
    }
    
    
    func loginSuccess(notif: NSNotification) {
        print("logged in!")
    }
    

    func loggedOut(notif: NSNotification){
        self.campaigns.removeAll()
        self.tableview.reloadData()
        updateToolbarItems()
    }
        
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.loadingFromRefresh = true
        loadData()
    }
    
    func loadData(){
        if(MCClient.sharedInstance.GetCredentials().Authenticated == true)
        {
            isLoading = true
            let request = MCClient.sharedInstance.SendAPICall("campaigns")
            debugPrint(request)
            request.response { (request, response, data, error) in
                self.campaigns.removeAll()
                let xml = SWXMLHash.parse(data!)
                for elem in xml["response"]["campaigns"]["campaign"] {
                    let id = elem.element!.attributes["id"]!
                    let name = elem["name"].element!.text!
                    let item = Campaign(id: id,name: name);
                    self.campaigns.append(item);
                }
                self.isLoading = false;
                self.campaigns.sortInPlace{
                    $0.Name.localizedCaseInsensitiveCompare($1.Name) == NSComparisonResult.OrderedAscending
                }
                self.tableView.reloadData()
                if(self.loadingFromRefresh == true){
                    self.refreshControl!.endRefreshing()
                    self.loadingFromRefresh = false
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let user = MCClient.sharedInstance.GetCredentials().Username!
        return "User: \(user)"
    }
    
    @IBOutlet weak var toolbarView: UIToolbar!
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.toolbarView
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.campaigns.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Campaign", forIndexPath: indexPath)
        
        if self.campaigns.count >= indexPath.row
        {
            let campaign = self.campaigns[indexPath.row]
            cell.textLabel?.text = campaign.Name
            cell.detailTextLabel?.text = campaign.Id
            
        }

        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let detailsViewController: CampaignDetailController = segue.destinationViewController as? CampaignDetailController {
            let index = self.tableview!.indexPathForSelectedRow!.row
            let selectedCampaign = self.campaigns[index]
            detailsViewController.campaign = selectedCampaign
        }
        
        if let detailsViewController: CampaignMembersTableViewController = segue.destinationViewController as? CampaignMembersTableViewController {
            let index = self.tableview!.indexPathForSelectedRow!.row
            let selectedCampaign = self.campaigns[index]
            detailsViewController.campaign = selectedCampaign
        }

    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


}
