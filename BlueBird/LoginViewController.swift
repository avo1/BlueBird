//
//  LoginViewController.swift
//  BlueBird
//
//  Created by Dave Vo on 11/23/15.
//  Copyright © 2015 Dave Vo. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
  
  @IBOutlet weak var birdImage: UIImageView!
  @IBOutlet weak var birdImageWidth: NSLayoutConstraint!
  
  var birdOriginalCenter: CGPoint!
  var birdShouldDisappearAt: CGFloat!
  var halfWay: CGFloat!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    birdShouldDisappearAt = UIScreen.mainScreen().bounds.width - 47
    halfWay = UIScreen.mainScreen().bounds.width / 2.0
  }
  
  func login() {
    TwitterClient.sharedInstance.loginWithCompletion {
      (user: User?, error: NSError?) in
      if user != nil {
        self.performSegueWithIdentifier("loginSegue", sender: self)
      } else {
        // Handle login error
      }
    }
  }
  
  @IBAction func onLogin(sender: UIButton) {
    login()
  }
  
  @IBAction func onBirdDrag(sender: UIPanGestureRecognizer) {
    let velocity    = sender.velocityInView(view)
    let translation = sender.translationInView(view)
    
    if sender.state == UIGestureRecognizerState.Began {
      birdOriginalCenter = birdImage.center
    } else if sender.state == UIGestureRecognizerState.Changed {
      let newX = birdOriginalCenter.x + translation.x
      if newX >= 60 && newX <= halfWay {
        birdImage.center = CGPoint(x: newX, y: birdOriginalCenter.y)
      }
    } else if sender.state == UIGestureRecognizerState.Ended {
      if birdImage.center.x < halfWay - 20 {
        UIView.animateWithDuration(Double(birdImage.center.x) / 300.0, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: [], animations: { () -> Void in
          self.birdImage.center = self.birdOriginalCenter
          }, completion: nil)
      } else {
        if velocity.x > 0 {
          let d = birdShouldDisappearAt - birdImage.center.x
          UIView.animateWithDuration(Double(d)/300.0, animations: { () -> Void in
            self.birdImage.center = CGPoint(x: self.birdShouldDisappearAt, y: self.birdOriginalCenter.y)
            }, completion: { (finished: Bool) -> Void in
              // Start to login
              print("login")
              self.login()
          })
        }
      }
      
    }
  }
}

