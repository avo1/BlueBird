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
  
  @IBOutlet weak var retweetedImageHeight: NSLayoutConstraint!
  @IBOutlet weak var retweetedImageToAvatar: NSLayoutConstraint!
  
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
      retweetCountLabel.text = "\(tweet.retweetCount)"
      favCountLabel.text = "\(tweet.favCount)"
      
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
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
