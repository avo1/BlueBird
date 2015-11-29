//
//  TweetCell.swift
//  BlueBird
//
//  Created by Dave Vo on 11/25/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var fullnameLabel: UILabel!
  @IBOutlet weak var postTimeLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var retweetCountLabel: UILabel!
  @IBOutlet weak var favCountLabel: UILabel!
  @IBOutlet weak var retweetedByLabel: UILabel!
  @IBOutlet weak var retweetButton: UIButton!
  @IBOutlet weak var favButton: UIButton!
  
  @IBOutlet weak var retweetedImageHeight: NSLayoutConstraint!
  @IBOutlet weak var retweetedImageToAvatar: NSLayoutConstraint!
  
  //weak var delegate: TweetCellDelegate?
  var tweetId: NSNumber!
  
  var tweet: Tweet! {
    didSet {
      if tweet.user?.profileImageURL != nil {
        avatarImageView.alpha = 0.0
        UIView.animateWithDuration(0.3, animations: {
          self.avatarImageView.setImageWithURL((self.tweet.user?.profileImageURL)!)
          self.avatarImageView.alpha = 1.0
          }, completion: nil)
      } else {
        avatarImageView.image = UIImage(named: "noImage")
      }
      fullnameLabel.text = tweet.user?.name
      usernameLabel.text = "@" + (tweet.user?.screenName)!
      contentLabel.text = tweet.text
      postTimeLabel.text = tweet.timeSinceCreated
      
      // If this is my post (not my retweet) then disable retweet
      retweetButton.enabled = (tweet.user?.screenName != User.currentUser?.screenName) || tweet.isRetweeted
      
      setRetweetCountLabel(tweet.retweetCount, retweeted: tweet.iRetweetIt)
      setFavCountLabel(tweet.favCount, liked: tweet.iLikeIt)
      
      if !tweet.isRetweeted {
        retweetedByLabel.hidden = true
        retweetedImageHeight.constant = 0
        retweetedImageToAvatar.constant = 0
      } else {
        retweetedByLabel.text = tweet.retweetedBy! + " retweeted"
      }
      
      tweetId = tweet.tweetId
    }
  }
  
  func setRetweetCountLabel(count: Int, retweeted: Bool) {
    if retweeted {
      retweetButton.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Normal)
      retweetCountLabel.textColor = MyColors.greenOfRetweetCount
    } else {
      retweetButton.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
      retweetCountLabel.textColor = UIColor.lightGrayColor()
    }
    retweetCountLabel.text = "\(count)"
    retweetCountLabel.hidden = !(count > 0)
  }
  
  func setFavCountLabel(count: Int, liked: Bool) {
    if liked {
      favButton.setImage(UIImage(named: "like_on"), forState: .Normal)
      favCountLabel.textColor = MyColors.redOfFavCount
    } else {
      favButton.setImage(UIImage(named: "like"), forState: .Normal)
      favCountLabel.textColor = UIColor.lightGrayColor()
    }
    favCountLabel.text = "\(count)"
    favCountLabel.hidden = !(count > 0)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    avatarImageView.layer.cornerRadius = 5
    avatarImageView.clipsToBounds = true
    contentLabel.preferredMaxLayoutWidth = contentLabel.frame.size.width
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    contentLabel.preferredMaxLayoutWidth = contentLabel.frame.size.width
  }
  
  @IBAction func onFavValueChange(sender: UIButton) {
    if sender.imageView?.image == UIImage(named: "like_on") {
      sender.setImage(UIImage(named: "like"), forState: UIControlState.Normal)
      // Unlike it
      TwitterClient.sharedInstance.unlikeStatus(["id" : tweetId])
      setFavCountLabel(Int(favCountLabel.text!)! - 1, liked: false)
    } else {
      sender.setImage(UIImage(named: "like_on"), forState: UIControlState.Normal)
      // Like it
      TwitterClient.sharedInstance.likeStatus(["id" : tweetId])
      setFavCountLabel(Int(favCountLabel.text!)! + 1, liked: true)
    }
  }
  
  @IBAction func onRetweetValueChange(sender: UIButton) {
    if sender.imageView?.image == UIImage(named: "retweet_on") {
      sender.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
      // Unretweet it
    } else {
      sender.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Normal)
      // Retweet it
      TwitterClient.sharedInstance.retweetStatus(tweetId, completion: { (response, error) -> () in
        if response != nil {
          self.setRetweetCountLabel(Int(self.retweetCountLabel.text!)! + 1, retweeted: true)
        }
      })
    }
    //delegate?.tweetCell?(self, didChangeRetweetValue: v)
  }
  
}
