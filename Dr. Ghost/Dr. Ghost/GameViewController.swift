//
//  GameViewController.swift
//  Dr. Ghost
//
//  Created by Mac on 2/5/17.
//  Copyright (c) 2017 Mac. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

var backgroundAudio = AVAudioPlayer()

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let path = Bundle.main.path(forResource : "backgroundaudio", ofType: "mp3")
            let fullpath = NSURL(fileURLWithPath: path!)
            backgroundAudio = try! AVAudioPlayer(contentsOf: fullpath as URL)
        }

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            
            backgroundAudio.play()
            backgroundAudio.numberOfLoops = -1
            
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            scene.size = self.view.bounds.size
            
            skView.presentScene(scene)
        }
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
