//
//  CampaignDetailController.swift
//  MobileCommonsSMS
//
//  Created by Gustavo Tandeciarz on 10/16/15.
//  Copyright © 2015 NFL Players Association. All rights reserved.
//

import UIKit
import SWXMLHash

class CampaignDetailController: UIViewController, UITextViewDelegate, UIAlertViewDelegate,  UIActionSheetDelegate {
    
    var campaign: Campaign!
    var charactersUsed = 0;
    
    @IBOutlet weak var MessageTextView: UITextView!
    
    @IBOutlet weak var CampaignName: UILabel!
    
    @IBOutlet weak var campaignId: UILabel!
    
    @IBOutlet weak var characters: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        debugPrint(campaign);
        
        MessageTextView.delegate = self;
        
        let string = "\(campaign.Name) \(campaign.Id)" as NSString
        
        let attributedString = NSMutableAttributedString(
            string: string as String,
            attributes: [NSForegroundColorAttributeName: UIColor.blackColor()]
            )
        
        let lightText = [NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(0.3), NSFontAttributeName: UIFont.systemFontOfSize(12)]
        
        attributedString.addAttributes(lightText, range: string.rangeOfString(campaign.Id))
        
        CampaignName.attributedText = attributedString;
        
        characters.text = "\(charactersUsed)/160"
        
        self.title = "Send Message"
    }
    
    @IBAction func SendMessage(sender: AnyObject) {
        
        let AS = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .ActionSheet)
        AS.addAction(UIAlertAction(title: "Send", style: .Destructive, handler: { (action) -> Void in
            
            let request = MCClient.sharedInstance.SendMessage(self.MessageTextView.text, campaign: self.campaign)
            
            request.response { (request, response, data, error) in
                let xml = SWXMLHash.parse(data!)
                
                for elem in xml["response"] {
                    if elem.element?.attributes["success"] == "true"
                    {
                        let broadcastId = elem["broadcast"].element?.attributes["id"]
                        
                        let alertController = UIAlertController(title: "Message Sent", message: "Broadcast ID: \(broadcastId)", preferredStyle: .Alert) // 1
                        
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: { (sentAction) -> Void in
                            
                            self.performSegueWithIdentifier("cancelMessage", sender: self)
                            
                        }));
                        
                        self.presentViewController(alertController, animated: true, completion: nil);
                    }
                    else{
                        
                    }
                    debugPrint(elem)
                }
            }

        }))
        AS.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        self.presentViewController(AS, animated: true, completion: nil);
        
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        //return on done
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        let maxLength = 160
        let currentString: NSString = textView.text
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: text)
        
        let newLength = newString.length
        
        if newString.length <= maxLength
        {
            charactersUsed = newLength
            updateCharactersUsed()
            return true
        }
        return false
    }
    
    func updateCharactersUsed(){
        
        characters.text = "\(charactersUsed)/160"
        if 160 - charactersUsed < 10
        {
            characters.textColor = UIColor.redColor()
        }
        else{
            characters.textColor = UIColor.blackColor()
        }
    }
    
}
