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
  var timeSinceCreated: String?
  var iLikeIt = false
  var iRetweetIt = false
  var retweetCount = 0
  var favCount = 0
  var isRetweeted = false
  var retweetedBy: String?
  var tweetId: Int64?
  var tweetIdStr: String?
  
  //retweeted_status: if avail -> retweeted
  
  init(dictionary: NSDictionary) {
    if let retweetedStatus = dictionary["retweeted_status"] {
      isRetweeted = true
      
      retweetedBy = dictionary["user"]!["name"] as? String
      user = User(dictionary: retweetedStatus["user"] as! NSDictionary)
      text = retweetedStatus["text"] as? String
      createdAtString = retweetedStatus["created_at"] as? String
      retweetCount = (retweetedStatus["retweet_count"] as? Int)!
      favCount = (retweetedStatus["favorite_count"] as? Int)!
      tweetIdStr = retweetedStatus["id_str"] as? String
    } else {
      isRetweeted = false
      
      user = User(dictionary: dictionary["user"] as! NSDictionary)
      text = dictionary["text"] as? String
      createdAtString = dictionary["created_at"] as? String
      retweetCount = (dictionary["retweet_count"] as? Int)!
      favCount = (dictionary["favorite_count"] as? Int)!
      tweetIdStr = dictionary["id_str"] as? String
    }
    
    iLikeIt = (dictionary["favorited"] as? Bool)!
    iRetweetIt = (dictionary["retweeted"] as? Bool)!
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
    createdAt = formatter.dateFromString(createdAtString!)
    
    let elapsedTime = NSDate().timeIntervalSinceDate(createdAt!)
    if elapsedTime < 60 {
      timeSinceCreated = String(elapsedTime) + "s"
    } else if elapsedTime < 3600 {
      timeSinceCreated = String(Int(elapsedTime / 60)) + "m"
    } else if elapsedTime < 24*3600 {
      timeSinceCreated = String(Int(elapsedTime / 60 / 60)) + "h"
    } else {
      timeSinceCreated = String(Int(elapsedTime / 60 / 60 / 24)) + "d"
    }
  }
  
  class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
    var tweets = [Tweet]()
    
    for dict in array {
      tweets.append(Tweet(dictionary: dict))
    }
    return tweets
  }
}
