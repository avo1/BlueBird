//
//  Tweet.swift
//  BlueBird
//
//  Created by Dave Vo on 11/24/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit

class Tweet: NSObject {
  var user: User?
  var text: String?
  var createdAtString: String?
  var createdAt: NSDate?
  
  init(dictionary: NSDictionary) {
    user = User(dictionary: dictionary["user"] as! NSDictionary)
    text = dictionary["text"] as? String
    createdAtString = dictionary["created_at"] as? String
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
    createdAt = formatter.dateFromString(createdAtString!)
  }
  
  class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
    var tweets = [Tweet]()
    
    for dict in array {
      tweets.append(Tweet(dictionary: dict))
    }
    return tweets
  }
}
