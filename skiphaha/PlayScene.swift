//
//  PlayScene.swift
//  skiphaha
//
//  Created by JD Penuliar on 7/8/16.
//  Copyright © 2016 JD Penuliar. All rights reserved.
//

import Foundation
import SpriteKit
class PlayScene: SKScene, SKPhysicsContactDelegate {
    let runningBar = SKSpriteNode(imageNamed: "bar")
    let hero = SKSpriteNode(imageNamed: "hero")
    let block1 = SKSpriteNode(imageNamed: "block1")
    let block2 = SKSpriteNode(imageNamed: "block2")
    let scoreText = SKLabelNode(fontNamed: "Chalkduster")
    
    var origRunningBarPositionX = CGFloat(0)
    var maxBarX = CGFloat(0)
    var groundSpeed = 5
    var heroBaseLine = CGFloat(0)
    var onGround = true
    var velocityY = CGFloat(0)
    let gravity = CGFloat(0.6)
    
    var blockMaxX = CGFloat(0)
    var origBlockPositionX = CGFloat(0)
    var score = 0
    
    enum ColliderType:UInt32 {
        case hero = 1
        case block = 2
    }
    
    override func didMove(to view: SKView) {
        print("haha new scene")
        self.backgroundColor = UIColor(hex: 0x80D9FF)
        self.physicsWorld.contactDelegate = self
        self.runningBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.runningBar.position = CGPoint(x: self.frame.minX, y: self.frame.minY + (self.runningBar.size.height)/2 )
        
        self.origRunningBarPositionX = self.runningBar.position.x
        self.maxBarX = self.runningBar.size.width - self.frame.size.width
        self.maxBarX *= -1
        self.heroBaseLine = self.runningBar.position.y + (self.runningBar.size.height/2) + (self.hero.size.height/2)
        self.hero.position = CGPoint(x: self.frame.minX + (self.hero.size.width/4) + self.hero.size.width, y: self.heroBaseLine)
        self.hero.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(self.hero.size.width/2))
        self.hero.physicsBody?.affectedByGravity = false
        self.hero.physicsBody?.categoryBitMask = ColliderType.hero.rawValue
        self.hero.physicsBody?.contactTestBitMask = ColliderType.block.rawValue
        self.hero.physicsBody?.collisionBitMask = ColliderType.block.rawValue
        
        self.block1.position = CGPoint(x: self.frame.maxX + self.block1.size.width, y: self.heroBaseLine)
        self.block2.position = CGPoint(x: self.frame.maxX + self.block2.size.width, y: self.heroBaseLine + (self.block1.size.height/2))
        
        self.block1.physicsBody = SKPhysicsBody(rectangleOf: self.block1.size)
        self.block1.physicsBody?.isDynamic = false
        self.block1.physicsBody?.contactTestBitMask = ColliderType.hero.rawValue
        self.block1.physicsBody?.collisionBitMask = ColliderType.hero.rawValue
        
        self.block2.physicsBody = SKPhysicsBody(rectangleOf: self.block2.size)
        self.block2.physicsBody?.isDynamic = false
        self.block2.physicsBody?.contactTestBitMask = ColliderType.hero.rawValue
        self.block2.physicsBody?.collisionBitMask = ColliderType.hero.rawValue
        
        
        self.origBlockPositionX = self.block1.position.x
        
        self.block1.name = "block1"
        self.block2.name = "block2"

        blockStatuses["block1"] = BlockStatus(isRunning: false, timeGapForNextRun: random(), currentInterval: UInt32(0))
        blockStatuses["block2"] = BlockStatus(isRunning: false, timeGapForNextRun: random(), currentInterval: UInt32(0))
        
        self.scoreText.text = "0"
        self.scoreText.fontSize = 42
        self.scoreText.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        self.blockMaxX = 0 - self.block1.size.width/2
        
        
        self.addChild(self.runningBar)
        self.addChild(hero)
        self.addChild(block1)
        self.addChild(block2)
        self.addChild(self.scoreText)
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        died()
//        contact.bodyA.categoryBitMask == ColliderType.Hero.rawValue
    }
    func died() {
        if let scene = GameScene(fileNamed: "GameScene"){
            let skView = self.view as SKView!
            skView?.ignoresSiblingOrder = true
            scene.size = (skView?.bounds.size)!
            scene.scaleMode = .aspectFill
            skView?.presentScene(scene)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print ("\(self.hero.position.y)haha\(self.heroBaseLine)yo\(self.onGround)")
        if self.onGround{
            self.velocityY = -18.0
            print ("tss\(velocityY)haha")
            self.onGround = false
        }
        print ("\(self.hero.position.y)haha\(self.heroBaseLine)")
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print  ("end")
        if self.velocityY < -9.0 {
            self.velocityY = -9.0
        }
    }
    func random() -> UInt32 {
        let range = UInt32(50)..<UInt32(200)
        return range.lowerBound + arc4random_uniform(range.upperBound - range.lowerBound + 1)
    }
    
    var blockStatuses: Dictionary<String,BlockStatus> = [:]
    
    
    override func update(_ currentTime: TimeInterval){
        
        if self.runningBar.position.x <= maxBarX{
            self.runningBar.position.x = self.origRunningBarPositionX
        }
        
        //jump
        self.velocityY += self.gravity
        self.hero.position.y -= self.velocityY
        
        if self.hero.position.y < self.heroBaseLine {
            self.hero.position.y = self.heroBaseLine
            velocityY = 0.0
            self.onGround = true
        }
        
        //move the ground
        runningBar.position.x -= CGFloat(self.groundSpeed)
        
        //rotate hero
        let degreeRotation = CDouble(self.groundSpeed) * M_PI / 100
        self.hero.zRotation -= CGFloat(degreeRotation)
        
        blockRunner()
    }
    
    func blockRunner(){
        for (block, blockStatus) in self.blockStatuses{
            let thisBLock = self.childNode(withName: block)
            if blockStatus.shouldRUnBLock() {
                blockStatus.timeGapForNextRun = random()
                blockStatus.currentInterval = 0
                blockStatus.isRunning = true
            }
            if blockStatus.isRunning{
                if thisBLock!.position.x > blockMaxX {
                    thisBLock!.position.x -= CGFloat(self.groundSpeed)
                }else{
                    thisBLock!.position.x = self.origBlockPositionX
                    blockStatus.isRunning = false
                    self.score += 1
                    if (self.score % 5 == 0){
                        self.groundSpeed += 1
                    }
                    self.scoreText.text = String(self.score)
                }
            }else{
                blockStatus.currentInterval += 1
            }
        }
    }
}
