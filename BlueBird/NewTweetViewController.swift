//
//  NewTweetViewController.swift
//  BlueBird
//
//  Created by Dave Vo on 11/29/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit

@objc protocol NewTweetViewControllerDelegate {
    optional func newTweetViewController(newTweetViewController: NewTweetViewController, newTweet: Tweet)
}

class NewTweetViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var keyboardViewHeight: NSLayoutConstraint!
    @IBOutlet weak var questionLabel: UILabel!
    
    weak var delegate: NewTweetViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        avatarImageView.layer.cornerRadius = 5
        avatarImageView.clipsToBounds = true
        print(User.currentUser!.profileImageURL)
        avatarImageView.setImageWithURL((User.currentUser!.profileImageURL)!)
        
        tweetButton.layer.cornerRadius = 5
        tweetButton.clipsToBounds = true
        keyboardView.layer.borderWidth = 0.5
        keyboardView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        // Create the "padding" for the text
        messageTextView.textContainerInset = UIEdgeInsetsMake(15, 15, 0, 15)
        // Add observer to detect when the keyboard will be shown
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        messageTextView.becomeFirstResponder()
        messageTextView.delegate = self
    }
    
    func keyboardShown(notification: NSNotification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        print("keyboardFrame: \(keyboardFrame)")
        keyboardViewHeight.constant = keyboardFrame.height + 40
    }
    
    @IBAction func cancelTweet(sender: UIButton) {
        messageTextView.resignFirstResponder()
        
        // If nothing then no need to confirm for deletion
        if messageTextView.text == "" {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alertMessage = UIAlertController()
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive) { action in self.dismissViewControllerAnimated(true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { action in self.messageTextView.becomeFirstResponder()
            }
            
            alertMessage.addAction(deleteAction)
            alertMessage.addAction(cancelAction)
            self.presentViewController(alertMessage, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTweetButtonTapped(sender: UIButton) {
        let params = ["status" : messageTextView.text]
        TwitterClient.sharedInstance.postNewStatus(params) { (response, error) -> () in
            if response != nil {
                self.delegate!.newTweetViewController!(self, newTweet: Tweet(dictionary: response as! NSDictionary))
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                // What if fail to post?
            }
        }
        
    }
}

extension NewTweetViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var newText: NSString = textView.text!
        newText = newText.stringByReplacingCharactersInRange(range, withString: text)
        
        let textLength = newText.length
        questionLabel.hidden = textLength > 0
        charCountLabel.text = String(140 - textLength)
        charCountLabel.textColor = textLength <= 120 ? UIColor.lightGrayColor() : MyColors.redOfFavCount
        tweetButton.enabled = (textLength > 0) && (textLength <= 140)
        tweetButton.backgroundColor = tweetButton.enabled ? MyColors.bluesky : UIColor.lightGrayColor()
        
        return true
    }
}