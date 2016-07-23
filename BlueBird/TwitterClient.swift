//
//  TwitterClient.swift
//  BlueBird
//
//  Created by Dave Vo on 11/23/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "JxUiG0fZyXliskmGJZYLjZcc4"
let twitterConsumerSecret = "2rW7IMZQ9Iz73JTwm800PGoaRHTPa3Vz59nDRXx2I1NIEaiipo"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        // Fetch request token and redirect to auth page
        requestSerializer.removeAccessToken()
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "bluebird://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("get request token")
            
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            
            }, failure: { (error: NSError!) -> Void in
                print("failed to request token")
                self.loginCompletion?(user: nil, error: error)
        })
    }
    
    func homeTimelineWithParams(params: [String: AnyObject], completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            //print("home timeline = \(response)")
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            
            //      for tweet in tweets {
            //        print("text: \(tweet.text), create at = \(tweet.createdAt)")
            //      }
            completion(tweets: tweets, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                print("failed to get home timeline")
                completion(tweets: nil, error: error)
        })
        
    }
    
    func postNewStatus(params: NSDictionary, completion: (response: AnyObject?, error: NSError?) -> ()) {
        POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            
            completion(response: response, error: nil)
            
        }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
            print("failed to post status \(error)")
            completion(response: nil, error: error)
        }
    }
    
    func deleteTweet(id: NSNumber, completion: (response: AnyObject?, error: NSError?) -> ()) {
        POST("1.1/statuses/destroy/\(id).json", parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            
            print("delete successfully")
            completion(response: response, error: nil)
            
        }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
            print("failed to delete status \(error)")
            completion(response: nil, error: error)
        }
    }
    
    func replyStatus(text: String, tweetId: NSNumber, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params = [String : AnyObject]()
        params["status"] = text
        params["in_reply_to_status_id"] = tweetId
        
        POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            let newTweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: newTweet, error: nil)
            
            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                print("failed to reply tweet \(error)")
                completion(tweet: nil, error: error)
        })
    }
    
    // MARK: Retweet
    func retweetStatus(id: NSNumber, completion: (response: AnyObject?, error: NSError?) -> ()) {
        POST("1.1/statuses/retweet/\(id).json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            completion(response: response, error: nil)
            
            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                print("failed to retweet: \(error)")
                completion(response: nil, error: error)
        })
    }
    
    func getRetweetedId(id: NSNumber, completion: (response: AnyObject?, error: NSError?) -> ()) {
        var retweetedId: NSNumber?
        var params = [String : AnyObject]()
        params["include_my_retweet"] = true
        
        GET("1.1/statuses/show/\(id).json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            let tweet = response as! NSDictionary
            let currentUserRetweet = tweet["current_user_retweet"] as! NSDictionary
            retweetedId = currentUserRetweet["id"] as? NSNumber
            
            completion(response: retweetedId, error: nil)
            
            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                completion(response: nil, error: error)
        })
    }
    
    func unretweet(id: NSNumber, completion: (response: AnyObject?, error: NSError?) -> ()) {
        POST("1.1/statuses/destroy/\(id).json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            completion(response: response, error: nil)
            
            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                print("failed to unretweet \(error)")
                completion(response: nil, error: error)
        })
    }
    
    // MARK: Favorite
    func likeStatus(params: NSDictionary, completion: (response: AnyObject?, error: NSError?) -> ()) {
        POST("1.1/favorites/create.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            
            completion(response: response, error: nil)
            
        }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
            print("failed to like status \(error)")
            completion(response: nil, error: error)
        }
    }
    
    func unlikeStatus(params: NSDictionary, completion: (response: AnyObject?, error: NSError?) -> ()) {
        POST("1.1/favorites/destroy.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            
            completion(response: response, error: nil)
            
        }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
            print("failed to unlike status \(error)")
            completion(response: nil, error: error)
        }
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("get access token")
            self.requestSerializer.saveAccessToken(accessToken)
            
            self.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                //print("user = \(response)")
                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                print("user: \(user.name)")
                self.loginCompletion?(user: user, error: nil)
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                    print("failed to get user")
                    self.loginCompletion?(user: nil, error: error)
            })
            
        }) { (error: NSError!) -> Void in
            print("failed to get access token \(error!)")
            self.loginCompletion?(user: nil, error: error)
        }
    }
}
