//
//  TweetsViewController.swift
//  BlueBird
//
//  Created by Dave Vo on 11/24/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetsViewController: UIViewController {
  
  var tweets = [Tweet]()
  var refreshControl = UIRefreshControl()
  
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
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as! TweetCell
    
    cell.tweet = tweets[indexPath.row]
    
    return cell
  }
}
