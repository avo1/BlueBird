//
//  TweetViewController.swift
//  BlueBird
//
//  Created by Dave Vo on 11/30/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit

@objc protocol TweetViewControllerDelegate {
  optional func tweetViewController(tweetViewController: TweetViewController, newTweet: Tweet)
}

class TweetViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var tweet: Tweet?
  @IBOutlet weak var replyButton: UIButton!
  @IBOutlet weak var charCountLabel: UILabel!
  @IBOutlet weak var keyboardView: UIView!
  @IBOutlet weak var keyboardViewHeight: NSLayoutConstraint!
  @IBOutlet weak var messageTextView: UITextView!
  @IBOutlet weak var replyToLabel: UILabel!
  @IBOutlet weak var messageHeight: NSLayoutConstraint!
  
  var kbHeight: CGFloat!
  var screenName: String!
  weak var delegate: TweetViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    
    messageTextView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
    replyButton.layer.cornerRadius = 5
    replyButton.clipsToBounds = true
    keyboardView.layer.borderWidth = 0.5
    keyboardView.layer.borderColor = UIColor.lightGrayColor().CGColor
    screenName = tweet?.user?.screenName!
    replyToLabel.text = "Reply to @\(screenName!)"
    
    // Add observer to detect when the keyboard will be shown
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "keyboardHiden:", name: UIKeyboardDidHideNotification, object: nil)
    messageTextView.delegate = self
    
    
  }
  
  func keyboardShown(notification: NSNotification) {
    let info  = notification.userInfo!
    let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
    
    let rawFrame = value.CGRectValue
    let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
    
    kbHeight = keyboardFrame.height
    keyboardViewHeight.constant = kbHeight + 40
    replyToLabel.hidden = true
    messageTextView.text = "@\(screenName) "
  }
  
  func keyboardHiden(notification: NSNotification) {
    keyboardViewHeight.constant = 40
  }
  
  @IBAction func onReply(sender: UIButton) {
    TwitterClient.sharedInstance.replyStatus(messageTextView.text, tweetId: (tweet?.tweetId)!) { (tweet, error) -> () in
      if tweet != nil {
        print("message replied")
        self.navigationController?.popViewControllerAnimated(true)
      }
    }
  }
  
}

extension TweetViewController: UITableViewDataSource, UITableViewDelegate, TweetCellDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as! TweetCell
    
    cell.tweet = tweet
    cell.delegate = self
    
    return cell
  }
  
  func tweetCell(tweetCell: TweetCell, didChangeFav value: Bool, favCount: Int) {
    print("Tweeet detail: fav changed to \(value)")
    tweet?.iLikeIt = value
    tweet?.favCount = favCount
    delegate!.tweetViewController!(self, newTweet: tweet!)
  }
  
  func tweetCell(tweetCell: TweetCell, didChangeRetweet value: Bool, retweetCount: Int) {
    print("Tweet detail: retweet changed to \(value)")
    tweet?.iRetweetIt = value
    tweet?.retweetCount = retweetCount
    delegate!.tweetViewController!(self, newTweet: tweet!)
  }
}

extension TweetViewController: UITextViewDelegate {
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    var newText: NSString = textView.text!
    newText = newText.stringByReplacingCharactersInRange(range, withString: text)
    
    let textLength = newText.length
    charCountLabel.text = String(140 - textLength)
    charCountLabel.textColor = textLength <= 120 ? UIColor.lightGrayColor() : MyColors.redOfFavCount
    replyButton.enabled = (textLength > 0) && (textLength <= 140)
    replyButton.backgroundColor = replyButton.enabled ? MyColors.bluesky : UIColor.lightGrayColor()
    
    // Adjust the height of the messageTextView to fit its content
    // The size of the textView to fit its content
    let newSize = messageTextView.sizeThatFits(CGSize(width: messageTextView.frame.width, height: CGFloat.max))
    print(newSize.height)
    let height = min(100, newSize.height)
    keyboardViewHeight.constant = kbHeight + height + 10
    messageHeight.constant = newSize.height
    
    return true
  }
}
