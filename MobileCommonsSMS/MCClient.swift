//
//  MCClient.swift
//  MobileCommonsSMS
//
//  Created by Gustavo Tandeciarz on 10/16/15.
//  Copyright © 2015 NFL Players Association. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

struct Campaign{
    var Id : String
    var Name: String
    init(id : String, name : String){
        self.Id = id
        self.Name = name
    }
}

struct Member{
    var Id : String
    var Name: String
    var Phone: String
    init(id : String, name : String, phone: String){
        self.Id = id
        self.Name = name
        self.Phone = phone
    }
}

class MCCredentials : NSObject {
    var Defaults : NSUserDefaults
    var Username : String?
    var Password : String?
    var Authenticated : Bool

    override init(){
        let defaults = NSUserDefaults.standardUserDefaults()
        self.Defaults = defaults
        self.Username = defaults.objectForKey("username") as? String
        self.Password = defaults.objectForKey("password") as? String
        self.Authenticated = Defaults.boolForKey("authenticated")
        self.Defaults.synchronize()
    }
    func Clear(){
        self.Password = nil
        self.Defaults.setObject(nil, forKey: "password")
        SetAuthenticated(false)
        self.Defaults.synchronize()
    }
    func SetAuthenticated(authenticated:Bool){
        self.Authenticated = authenticated
        self.Defaults.setBool(authenticated, forKey: "authenticated")
    }
    func SetUsername(username : String){
        self.Username = username
        self.Defaults.setObject(username, forKey: "username")
    }
    func SetPassword(pass : String){
        self.Password = pass
        self.Defaults.setObject(pass, forKey: "password")
    }
    func UpdateCredentials(username: String, password: String, authenticated : Bool){
        SetUsername(username)
        SetPassword(password)
        SetAuthenticated(authenticated)
        self.Defaults.synchronize()
    }
}

final class MCClient {

    static let sharedInstance = MCClient()

    let baseUrl = "https://secure.mcommons.com/api/";

//    let companyId = [
//        "company" : "CompanyKey"
//    ];
//
    var credentials = MCCredentials.init()

    private init(){
        print("Initializing Client");
    }

    func GetCredentials() -> MCCredentials {
        return self.credentials
    }

    func TryLogin(username : String, passwd : String){

        let credentialData = "\(username):\(passwd)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])

        let headers = ["Authorization": "Basic \(base64Credentials)"]

        Alamofire.request(.GET, baseUrl + "groups", headers: headers, parameters: nil)
            .validate().response { (request, response, data, error) in
            let success = response?.statusCode == 200;
            debugPrint(response?.statusCode)
            dispatch_async(dispatch_get_main_queue(), {
                if(success){
                    self.credentials.UpdateCredentials(username, password: passwd, authenticated: success)
                    NSNotificationCenter.defaultCenter().postNotificationName("LoginSuccess", object: nil);
                }
                else{
                    self.Logout()
                    NSNotificationCenter.defaultCenter().postNotificationName("LoginFailed", object: nil);
                }
            })
        }
    }

    func Logout(){
        Alamofire.Manager.sharedInstance.session.resetWithCompletionHandler { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.credentials.Clear()
                NSNotificationCenter.defaultCenter().postNotificationName("LoggedOut", object: nil);
            })
        };
    }


    func GetAuthorizationHeaders() -> [String : String]{

        let credentialData = "\(self.credentials.Username):\(self.credentials.Password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])

        let headers = ["Authorization": "Basic \(base64Credentials)"]

        return headers
    }


    func SendAPICall(apiEndpoint:String) -> Alamofire.Request{

        return SendAPICall(apiEndpoint, parameters: nil)

    }

    func SendAPICall(apiEndpoint:String, parameters: [String : AnyObject]?) -> Alamofire.Request{


        let request = Alamofire.request(.GET, baseUrl + apiEndpoint, headers: GetAuthorizationHeaders(), parameters: parameters).validate()

        return request;

    }

    func SendMessage(message:String, campaign:Campaign) -> Alamofire.Request {

        let parameters = ["campaign_id":campaign.Id, "body":message]

        let request = Alamofire.request(.POST, baseUrl + "schedule_broadcast", headers: GetAuthorizationHeaders(), parameters: parameters).validate()

        return request;

    }
}
