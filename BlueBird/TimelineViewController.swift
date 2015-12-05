//
//  TimelineViewController.swift
//  BlueBird
//
//  Created by Dave Vo on 11/24/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit
import MBProgressHUD

class TimelineViewController: UIViewController {
  
  var tweets = [Tweet]()
  var refreshControl = UIRefreshControl()
  var selectedTweetIndex: Int!
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.title = User.currentUser?.name
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    
    // Refresh control
    //    refreshControl.tintColor = UIColor.whiteColor()
    refreshControl.addTarget(self, action: Selector("fetchTimeline"), forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
    
    // Just call the HUD once
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    fetchTimeline()
    
  }
  
  override func viewWillAppear(animated: Bool) {
    // Reload whatever the change from other pages
    tableView.reloadData()
  }
  
  func fetchTimeline() {
    TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
      self.tweets = tweets!
      self.tableView.reloadData()
      self.refreshControl.endRefreshing()
      MBProgressHUD.hideHUDForView(self.view, animated: true)
    })
  }
  
  @IBAction func onLogout(sender: UIBarButtonItem) {
    User.currentUser?.logout()
  }
  
  @IBAction func onNewTweet(sender: UIBarButtonItem) {
    self.performSegueWithIdentifier("newTweetSegue", sender: self)
  }
  
  // MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "tweetSegue" {
      let tweetVC: TweetViewController = segue.destinationViewController as! TweetViewController
      let data = sender as! Tweet
      tweetVC.tweet = data
      tweetVC.delegate = self
    } else if segue.identifier == "newTweetSegue" {
      let newTweetVC: NewTweetViewController = segue.destinationViewController as! NewTweetViewController
      newTweetVC.delegate = self
    }
  }
  
}

// MARK: - Detail Tweet
extension TimelineViewController: TweetViewControllerDelegate {
  func tweetViewController(tweetViewController: TweetViewController, newTweet: Tweet) {
    //print("Timeline got signal from detail page")
    tweets[selectedTweetIndex] = newTweet
  }
}

extension TimelineViewController: UITableViewDataSource, UITableViewDelegate, TweetCellDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as! TweetCell
    
    cell.tweet = tweets[indexPath.row]
    cell.delegate = self
    
    return cell
  }
  
  func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    // If this is my tweet then allow to delete
    let tweet = tweets[indexPath.row]
    
    let hideAction = UITableViewRowAction(style: .Normal, title: "Hide") { action, index in
      self.tweets.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
    }
    hideAction.backgroundColor = MyColors.bluesky
    
    if tweet.user?.screenName == User.currentUser?.screenName {
      let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
        TwitterClient.sharedInstance.deleteTweet(tweet.tweetId!, completion: { (response, error) -> () in
          if error == nil {
            self.tweets.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
          }
        })
      }
      deleteAction.backgroundColor = MyColors.carrot
      
      return [deleteAction]
    } else {
      return [hideAction]
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedTweetIndex = indexPath.row
    let tweet = tweets[selectedTweetIndex]
    performSegueWithIdentifier("tweetSegue", sender: tweet)
  }
  
  func tweetCell(tweetCell: TweetCell, didChangeFav value: Bool, favCount: Int) {
    let indexPath = tableView.indexPathForCell(tweetCell)!
    print("Timeline: fav changed to \(value)")
    tweets[indexPath.row].iLikeIt = value
    tweets[indexPath.row].favCount = favCount
  }
  
  func tweetCell(tweetCell: TweetCell, didChangeRetweet value: Bool, retweetCount: Int) {
    let indexPath = tableView.indexPathForCell(tweetCell)!
    print("Timeline: retweet changed to \(value)")
    tweets[indexPath.row].iRetweetIt = value
    tweets[indexPath.row].retweetCount = retweetCount
  }
}

extension TimelineViewController: NewTweetViewControllerDelegate {
  func newTweetViewController(newTweetViewController: NewTweetViewController, newTweet: Tweet) {
    print("i got new tweet")
    tweets.insert(newTweet, atIndex: 0)
  }
}
