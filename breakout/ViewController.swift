//
//  ViewController.swift
//  breakout
//
//  Created by Kathy Gallo on 7/9/15.
//  Copyright © 2015 Paul Schmidt. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    @IBOutlet weak var livesLabel: UILabel!
    
    var dynamicAnimator = UIDynamicAnimator()
    var ball = UIView()
    var paddle = UIView()
    var lives = 5
    var collisionBehavior = UICollisionBehavior()
    var brick = UIView()
    var bricks = [UIView]()
    var winCondition = false
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Defaults()
    }
    @IBAction func dragPaddle(sender: UIPanGestureRecognizer) {
        let panGesture = sender.locationInView(view)
        paddle.center = CGPointMake(panGesture.x, paddle.center.y)
        dynamicAnimator.updateItemUsingCurrentState(paddle)
    }
    
    func Defaults(){
        counter = 0
        lives = 5
        livesLabel.text = "Lives : \(lives)"
        
        //add a black ball to the view
        ball = UIView(frame: CGRectMake(view.center.x, view.center.y, 20, 20))
        ball.backgroundColor = UIColor.blackColor()
        ball.layer.cornerRadius = 10
        ball.clipsToBounds = true
        view.addSubview(ball)
        
        //add a red paddle to the view
        paddle = UIView(frame: CGRectMake(view.center.x, view.center.y * 1.7, 80, 20))
        paddle.backgroundColor = UIColor.redColor()
        view.addSubview(paddle)
        
        //add a brick
        for i in 0...8{
            // var brick = UIView()
            brick = UIView(frame: CGRectMake(CGFloat(42 * i), 20, 40, 20))
            brick.backgroundColor = UIColor.yellowColor()
            view.addSubview(brick)
            bricks.append(brick)
        }
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        //create dynamic behavior for the ball
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        //create dynamic behavioe for the paddle
        let paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBehavior.density = 10000
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        
        //create dynamic behavior for the brick
        let brickDynamicBehavior = UIDynamicItemBehavior(items: bricks)
        brickDynamicBehavior.density = 10000
        brickDynamicBehavior.resistance = 100
        brickDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicBehavior)
        
        //create a push behavior to get ball moving
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.7, -1.3)
        pushBehavior.magnitude = 0.1
        dynamicAnimator.addBehavior(pushBehavior)
        
        //create collision detection
        collisionBehavior = UICollisionBehavior(items: [paddle, ball] + bricks)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .Everything
        collisionBehavior.collisionDelegate = self
        livesLabel.text = "Lives : \(lives)"
        dynamicAnimator.addBehavior(collisionBehavior)
        
    }
    
    
    //collision behavior delegate method (with boundary)
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        
        //alert actions
        let quitAction = UIAlertAction(title: "Quit", style: .Cancel) { (action) -> Void in
            exit(0)
        }
        let playAgainAction = UIAlertAction(title: "Play Again", style: .Default) { (action) -> Void in
            self.Defaults()
        }
        
        if item.isEqual(ball) && p.y > paddle.center.y {
            lives--
            if lives > 0{
                livesLabel.text = "Lives : \(lives)"
                ball.center = view.center
                dynamicAnimator.updateItemUsingCurrentState(ball)
            }
            else{
                livesLabel.text = "Lives : \(lives)"
                let loseAlert = UIAlertController(title: "You Lost", message: nil, preferredStyle: .Alert)
                loseAlert.addAction(playAgainAction)
                loseAlert.addAction(quitAction)
                ball.removeFromSuperview()
                paddle.removeFromSuperview()
                collisionBehavior.removeItem(ball)
                bricks.removeAll()
                self.presentViewController(loseAlert, animated: true, completion: nil)
            }
        }
    }
    
    //collision behavior delegate method (with another object)
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        
        //alert actions
        let quitAction = UIAlertAction(title: "Quit", style: .Cancel) { (action) -> Void in
            exit(0)
        }
        let playAgainAction = UIAlertAction(title: "Play Again", style: .Default) { (action) -> Void in
            self.Defaults()
        }
        for brick in bricks{
            if (item1.isEqual(ball) && item2.isEqual(brick)) || (item1.isEqual(brick) && item2.isEqual(ball)) {
                if brick.backgroundColor == UIColor.cyanColor() {
                    brick.backgroundColor = UIColor.yellowColor()
                }
                else if brick.backgroundColor == UIColor.yellowColor(){
                    brick.backgroundColor = UIColor.greenColor()
                }
                else{
                    brick.hidden = true
                    counter++
                    collisionBehavior.removeItem(brick)
                    if bricks.count == counter{
                        winCondition = true
                    }
                    if winCondition == true{
                        let winAlert = UIAlertController(title: "You Won", message: nil, preferredStyle: .Alert)
                        winAlert.addAction(playAgainAction)
                        winAlert.addAction(quitAction)
                        ball.removeFromSuperview()
                        collisionBehavior.removeItem(ball)
                        collisionBehavior.removeItem(paddle)
                        paddle.removeFromSuperview()
                        dynamicAnimator.updateItemUsingCurrentState(ball)
                        for brick in bricks{
                            collisionBehavior.removeItem(brick)
                            brick.removeFromSuperview()
                        }
                        bricks.removeAll()
                        self.presentViewController(winAlert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}


