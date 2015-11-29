//
//  TweetCell.swift
//  BlueBird
//
//  Created by Dave Vo on 11/25/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol TweetCellDelegate {
  optional func tweetCell(tweetCell: TweetCell, didChangeFavValue value: Bool)
  optional func tweetCell(tweetCell: TweetCell, didChangeRetweetValue value: Bool)
}

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
  
  weak var delegate: TweetCellDelegate?
  
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
      if tweet.iRetweetIt {
        retweetButton.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Normal)
        retweetCountLabel.textColor = MyColors.greenOfRetweetCount
      } else {
        retweetButton.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
        retweetCountLabel.textColor = UIColor.lightGrayColor()
      }
      retweetCountLabel.text = "\(tweet.retweetCount)"
      retweetCountLabel.hidden = !(tweet.retweetCount > 0)
      
      if tweet.iLikeIt {
        favButton.setImage(UIImage(named: "like_on"), forState: UIControlState.Normal)
        favCountLabel.textColor = MyColors.redOfFavCount
      } else {
        favButton.setImage(UIImage(named: "like"), forState: UIControlState.Normal)
        favCountLabel.textColor = UIColor.lightGrayColor()
      }
      favCountLabel.text = "\(tweet.favCount)"
      favCountLabel.hidden = !(tweet.favCount > 0)
      
      if !tweet.isRetweeted {
        retweetedByLabel.hidden = true
        retweetedImageHeight.constant = 0
        retweetedImageToAvatar.constant = 0
      } else {
        retweetedByLabel.text = tweet.retweetedBy! + " retweeted"
      }
      
    }
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
    var v: Bool
    if sender.imageView?.image == UIImage(named: "like_on") {
      sender.setImage(UIImage(named: "like"), forState: UIControlState.Normal)
      v = false
    } else {
      sender.setImage(UIImage(named: "like_on"), forState: UIControlState.Normal)
      v = true
    }
    delegate?.tweetCell?(self, didChangeFavValue: v)
  }
  
  @IBAction func onRetweetValueChange(sender: UIButton) {
    var v: Bool
    if sender.imageView?.image == UIImage(named: "retweet_on") {
      sender.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
      v = false
    } else {
      sender.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Normal)
      v = true
    }
    delegate?.tweetCell?(self, didChangeRetweetValue: v)
  }
  
}
