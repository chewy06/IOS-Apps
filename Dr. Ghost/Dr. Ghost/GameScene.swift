//
//  GameScene.swift
//  Dr. Ghost
//
//  Created by Mac on 2/5/17.
//  Copyright (c) 2017 Mac. All rights reserved.
//

import SpriteKit
import Foundation
import AVFoundation

struct PhysicsCatagory {
    static let Ghost : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
    static let Top : UInt32 = 0x1 << 5
    static let Bot : UInt32 = 0x1 << 6
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let ghostColor = [SKColor.blue, SKColor.red, SKColor.purple]
    var BotGround = SKSpriteNode()
    var TopGround = SKSpriteNode()
    var Ghost = SKSpriteNode()
    var restartBTN = SKSpriteNode()
    
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    let scoreLbl = SKLabelNode()
    var died = Bool()
    
    var setColor = true
    var ghostIndex = 1
    var wallIndex = 0
    
    var NewScore: [SKSpriteNode] = []
    var nextIndex: [Int] = []
    
    var wallCrash = AVAudioPlayer()
    var levelSound = AVAudioPlayer()
    var loadSound = true
    
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        
        died = false
        gameStarted = false
        setColor = true
        score = 0
        nextIndex.removeAll()
        ghostIndex = 1
        wallIndex = 0
        createScene()
    }
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<3 {
            let background = SKSpriteNode(imageNamed: "background" + "\(Int(arc4random_uniform(3)))")
            background.anchorPoint = CGPoint(x: 0, y: 0)
            
            //background.size = CGSize(width: self.frame.width, height: self.frame.height)
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            background.zPosition = 0
            
            self.addChild(background)
        }
        
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLbl.zPosition = 5
        scoreLbl.text = "\(score)"
        self.addChild(scoreLbl)
        
        BotGround = SKSpriteNode()
        BotGround.setScale(0.5)
        BotGround.size = CGSize(width: self.frame.width, height: 5)
        BotGround.position = CGPoint(x: self.frame.width / 2, y: 0 + BotGround.frame.height / 2)
    
        BotGround.physicsBody = SKPhysicsBody(rectangleOf: BotGround.size)
        BotGround.physicsBody?.categoryBitMask = PhysicsCatagory.Bot
        BotGround.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        BotGround.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        BotGround.physicsBody?.affectedByGravity = false
        BotGround.physicsBody?.isDynamic = false
        BotGround.color = SKColor.white
        BotGround.zPosition = 1
        
        self.addChild(BotGround)
        
        TopGround = SKSpriteNode()
        TopGround.setScale(0.5)
        TopGround.size = CGSize(width: self.frame.width, height: 5)
        TopGround.position = CGPoint(x: self.frame.width / 2, y: self.frame.height - TopGround.frame.height / 2)
        
        TopGround.physicsBody = SKPhysicsBody(rectangleOf: TopGround.size)
        TopGround.physicsBody?.categoryBitMask = PhysicsCatagory.Top
        TopGround.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        TopGround.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        TopGround.physicsBody?.affectedByGravity = false
        TopGround.physicsBody?.isDynamic = false
        TopGround.color = SKColor.white
        TopGround.zPosition = 1
        
        self.addChild(TopGround)
        
        Ghost = SKSpriteNode()
        Ghost.size = CGSize(width: 60, height: 70)
        Ghost.position = CGPoint(x: self.frame.width / 2 - Ghost.frame.width, y: self.frame.height / 2)
        
        Ghost.physicsBody = SKPhysicsBody(circleOfRadius: Ghost.frame.height / 2)
        Ghost.physicsBody?.categoryBitMask = PhysicsCatagory.Ghost
        Ghost.physicsBody?.collisionBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall
        Ghost.physicsBody?.contactTestBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall | PhysicsCatagory.Score
        Ghost.physicsBody?.affectedByGravity = false
        Ghost.physicsBody?.isDynamic = true
        Ghost.color = SKColor.black
        Ghost.zPosition = 1
        
        
        self.addChild(Ghost)
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        createScene()
    }
    
    func createBTN() {
        restartBTN = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 200, height: 100))
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        
        restartBTN.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.Ghost || firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Score {
            
            levelSound.play()
            score += 1
            scoreLbl.text = "\(score)"
            setColor = true
        }else if firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Wall || firstBody.categoryBitMask == PhysicsCatagory.Wall && secondBody.categoryBitMask == PhysicsCatagory.Ghost {
            
            wallCrash.play()
            died = true
            createBTN()
        } else if firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Top || firstBody.categoryBitMask == PhysicsCatagory.Top && secondBody.categoryBitMask == PhysicsCatagory.Ghost {
            
            Ghost.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            Ghost.physicsBody?.applyImpulse(CGVector(dx: 0,dy: -90))
            
        }else if firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Bot || firstBody.categoryBitMask == PhysicsCatagory.Bot && secondBody.categoryBitMask == PhysicsCatagory.Ghost {
            
            Ghost.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            Ghost.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 90))
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let firstbody = contact.bodyA
        let secondbody = contact.bodyB
        
        if died == true {
        
        } else if firstbody.categoryBitMask == PhysicsCatagory.Top && secondbody.categoryBitMask == PhysicsCatagory.Ghost || firstbody.categoryBitMask == PhysicsCatagory.Ghost && secondbody.categoryBitMask == PhysicsCatagory.Top {
        
        } else if firstbody.categoryBitMask == PhysicsCatagory.Bot && secondbody.categoryBitMask == PhysicsCatagory.Ghost || firstbody.categoryBitMask == PhysicsCatagory.Ghost && secondbody.categoryBitMask == PhysicsCatagory.Bot {
    
        } else if firstbody.categoryBitMask == PhysicsCatagory.Score && secondbody.categoryBitMask == PhysicsCatagory.Ghost || firstbody.categoryBitMask == PhysicsCatagory.Ghost && secondbody.categoryBitMask == PhysicsCatagory.Score {
                setColor = false
                Ghost.color = ghostColor[nextIndex[ghostIndex]]
                ghostIndex += 1
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        if gameStarted == false {
            
            gameStarted = true
            Ghost.physicsBody?.affectedByGravity = true
            setColor = false
    
            let randomIndex = Int(arc4random_uniform(3))
            nextIndex.append(randomIndex)
            
            let spawn = SKAction.run {
                () in
                
                let randomIndex = Int(arc4random_uniform(3))
                self.nextIndex.append(randomIndex)
                self.createWalls()
            }
            
            let delay = SKAction.wait(forDuration: 3.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let SpawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(SpawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let moveWalls = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.008 * distance))
            let removeWalls = SKAction.removeFromParent()
            
            moveAndRemove = SKAction.sequence([moveWalls, removeWalls])
            Ghost.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            Ghost.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 90))
            Ghost.color = ghostColor[nextIndex[0]]
        } else {
            
            if died == true {
            
            } else {
                Ghost.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
                Ghost.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 90))
            }
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if died == true {
                if restartBTN.contains(location) {
                    restartScene()
                }
            }
        }
        
        
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if setColor {
            Ghost.color = ghostColor[Int(arc4random_uniform(3))]
        }
        
        if loadSound {
            let path = Bundle.main.path(forResource : "death", ofType: "wav")
            let fullpath = NSURL(fileURLWithPath: path!)
            wallCrash = try! AVAudioPlayer(contentsOf: fullpath as URL)
            wallCrash.setVolume(10, fadeDuration: 2)
            
            
            let levelpath = Bundle.main.path(forResource : "levelSound", ofType: "wav")
            let fullLevelpath = NSURL(fileURLWithPath: levelpath!)
            levelSound = try! AVAudioPlayer(contentsOf: fullLevelpath as URL)
            
            loadSound = false
        }
        
        if gameStarted == true {
            enumerateChildNodes(withName: "background", using: ({
                (node, error) in
                
                let bg = node as! SKSpriteNode
                
                bg.position = CGPoint(x: bg.position.x - 5, y: bg.position.y)
                
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                }
                
            }))
        }
    }
    
    func createWalls() {
        
        let wallHeigths = self.frame.height / 3
        let size = self.frame.height / 2
        
        let scoreNode = SKSpriteNode()
        let topWall = SKSpriteNode()
        let bottonWall = SKSpriteNode()
        
        let BLOCKS = [SKSpriteNode(),SKSpriteNode(),SKSpriteNode(),SKSpriteNode()]
        var currPos = CGFloat(0)
        var dif = CGFloat(5)
        
        wallPair = SKNode()
        
        for block in BLOCKS {
            
            block.setScale(0.5)
            block.size = CGSize(width: 20, height: 20)
            block.position = CGPoint(x: self.frame.width, y: currPos + dif)
            
            block.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
            block.physicsBody?.affectedByGravity = false
            block.physicsBody?.isDynamic = false
            
            block.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
            block.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
            block.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
            block.color = SKColor.black
            block.zPosition = 6
            
            currPos = currPos + wallHeigths + dif
            dif = dif - CGFloat(5)
            
            wallPair.addChild(block)
        }
        
        scoreNode.setScale(0.5)
        scoreNode.size = CGSize(width: 10, height: wallHeigths)
        scoreNode.position = CGPoint(x: self.frame.width, y: size)
        
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        scoreNode.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        scoreNode.color = SKColor.blue
        
        topWall.setScale(0.5)
        bottonWall.setScale(0.5)
        
        topWall.size = CGSize(width: 10, height: wallHeigths)
        bottonWall.size = CGSize(width: 10, height: wallHeigths)
        
        topWall.position = CGPoint(x: self.frame.width, y: size + wallHeigths)
        bottonWall.position = CGPoint(x: self.frame.width, y: size - wallHeigths)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        topWall.color = SKColor.red
        
        bottonWall.physicsBody = SKPhysicsBody(rectangleOf: bottonWall.size)
        bottonWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        bottonWall.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        bottonWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        bottonWall.physicsBody?.isDynamic = false
        bottonWall.physicsBody?.affectedByGravity = false
        bottonWall.color = SKColor.purple
        
        scoreNode.zPosition = 1
        topWall.zPosition = 2
        bottonWall.zPosition = 3
        
        NewScore = [scoreNode,topWall,bottonWall]
        
        NewScore[nextIndex[wallIndex]].physicsBody?.categoryBitMask = PhysicsCatagory.Score
        wallIndex += 1
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottonWall)
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveAndRemove)
        self.addChild(wallPair)
        
    }
}
