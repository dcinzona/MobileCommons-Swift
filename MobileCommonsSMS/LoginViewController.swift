//
//  FirstViewController.swift
//  MobileCommonsSMS
//
//  Created by Gustavo Tandeciarz on 10/16/15.
//  Copyright © 2015 NFL Players Association. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loginButton: UIButton!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var formCenterOriginal: CGFloat = 0;
    
    override func viewDidLoad() {
        
        self.title = "Sign In"
        
        self.formCenterOriginal = self.centerConstraint.constant;
        self.usernameField.delegate = self;
        self.passwordField.delegate = self;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        if(MCClient.sharedInstance.GetCredentials().Authenticated == true){
            self.usernameField.text = MCClient.sharedInstance.GetCredentials().Username
            self.passwordField.text = MCClient.sharedInstance.GetCredentials().Password
            login()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginFailed:", name: "LoginFailed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginSuccess:", name: "LoginSuccess", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loggedOut:", name: "LoggedOut", object: nil)
        
        super.viewDidLoad()
    }
    
    @IBAction func logOutSegue(segue: UIStoryboardSegue) {
        print("should be going back to login")
        MCClient.sharedInstance.Logout()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func viewDidAppear(animated: Bool) {
        self.usernameField.text = MCClient.sharedInstance.GetCredentials().Username
    }
    
    func loggedOut(notif: NSNotification){        
        self.usernameField.text = MCClient.sharedInstance.GetCredentials().Username
        self.passwordField.text = MCClient.sharedInstance.GetCredentials().Password
    }
    
    func loginSuccess(notif: NSNotification) {
        print("logged in!")
        self.performSegueWithIdentifier("loggedInSegue", sender: self)
    }
        
    func loginFailed(notif: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: "Login Failed", message: "Your username or password is incorrect", preferredStyle: .Alert) // 1
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil));
            
            self.presentViewController(alertController, animated: true, completion: nil);
        })
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func login(){
        
        let username = usernameField.text
        let password = passwordField.text
        
        MCClient.sharedInstance.TryLogin(username!,passwd: password!)
    }
    

    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue();
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.centerConstraint.constant = self.formCenterOriginal - (keyboardFrame.size.height / 2);
        });
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.centerConstraint.constant = self.formCenterOriginal;
    }
    
    
    
    func textFieldShouldReturn(theTextField: UITextField) -> Bool {
        if (theTextField == self.passwordField) {
            theTextField.resignFirstResponder();
            login();
        } else if (theTextField == self.usernameField) {
            self.passwordField.becomeFirstResponder();
        }
        
        return true;
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    @IBAction func LoginClick(sender: AnyObject) {
        
        login()
        
    }
}

