//
//  User.swift
//  BlueBird
//
//  Created by Dave Vo on 11/24/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit

var _currentUser: User?
let keyCurrentUser = "keyCurrentUser"
let userLoginNotification = "userLoginNotification"
let userLogoutNotification = "userLogoutNotification"

class User: NSObject {
  var name: String?
  var screenName: String?
  var profileImangeURL: String?
  var tagline: String?
  var dictionary: NSDictionary
  
  init(dictionary: NSDictionary) {
    self.dictionary = dictionary
    name = dictionary["name"] as? String
    screenName = dictionary["screen_name"] as? String
    profileImangeURL = dictionary["profile_image_url"] as? String
    tagline = dictionary["description"] as? String
  }
  
  func logout() {
    User.currentUser = nil
    TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
    
    NSNotificationCenter.defaultCenter().postNotificationName(userLogoutNotification, object: nil)
  }
  
  static var currentUser: User? {
    get {
    if _currentUser == nil {
    let data = NSUserDefaults.standardUserDefaults().objectForKey(keyCurrentUser) as? NSData
    if data != nil {
    var dictionary: NSDictionary!
    do {
    dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as! NSDictionary
    _currentUser = User(dictionary: dictionary)
  } catch {
    // Failed to parse JSON
    }
    }
    }
    return _currentUser
    }
    
    set(user) {
      _currentUser = user
      if _currentUser != nil {
        var data: NSData!
        do {
          data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: NSJSONWritingOptions())
          NSUserDefaults.standardUserDefaults().setObject(data, forKey: keyCurrentUser)
        } catch {
          // Failed to parse JSON
        }
      } else {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: keyCurrentUser)
      }
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }
  
}
