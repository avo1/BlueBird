//
//  LoginViewController.swift
//  BlueBird
//
//  Created by Dave Vo on 11/23/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit
import BDBOAuth1Manager



class LoginViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func onLogin(sender: UIButton) {
    TwitterClient.sharedInstance.loginWithCompletion {
      (user: User?, error: NSError?) in
      if user != nil {
        self.performSegueWithIdentifier("loginSegue", sender: self)
      } else {
        // Handle login error
      }
    }
  }
  
}

