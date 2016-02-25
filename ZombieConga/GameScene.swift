//
//  GameScene.swift
//  ZombieConga
//
//  Created by Oscar Villavicencio on 2/12/16.
//  Copyright (c) 2016 Xanadu Games. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    //properties
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let background = SKSpriteNode(imageNamed: "background1")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480
    var velocity = CGPoint.zero
    let playableRect: CGRect
    var lastTouchLocation = UITouch()
    var differenceInPosition = CGPoint.zero
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //start of program
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.blackColor()
        background.anchorPoint = CGPointZero
        background.position = CGPointZero
        background.zPosition = -1
        
        zombie.position = CGPoint(x: 400, y: 400)
        //zombie.setScale(2)
        
        addChild(background)
        addChild(zombie)
        spawnEnemy()
        
        debugDrawPlayableArea()
    }
    
    func debugDrawPlayableArea(){
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func spawnEnemy(){
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: size.height/2)
        
        addChild(enemy)
        
        let actionMove = SKAction.moveTo((CGPoint(x: -enemy.size.width/2, y: enemy.position.y)), duration: 2.0)
        enemy.runAction(actionMove)
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint){
        
        let amountToMove = velocity * CGFloat(dt)
        //print ("amount to move: \(amountToMove)")
        
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint){
        let offset = location - zombie.position
        
        let direction = offset.normalized()
        
        velocity =  direction * zombieMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint){
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        guard let touch = touches.first else{
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        //uncomment below to stop where you last touched
        //lastTouchLocation = touch
        
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        //uncomment below to stop where you last touched
        //lastTouchLocation = touch
        
        sceneTouched(touchLocation)
    }
   
    func boundsCheckZombie(){
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie.position.x <= bottomLeft.x{
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x{
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y{
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y{
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat){
        
        var shortest = shortestAngleBetween(sprite.zPosition, angle2: direction.angle)
        
        var amtToRotate = rotateRadiansPerSec * CGFloat(dt)
        
        if (abs(shortest) < amtToRotate){
            shortest = shortest * shortest.sign()
            sprite.zRotation += shortest
        }else{
            amtToRotate = amtToRotate * amtToRotate.sign()
            sprite.zRotation += amtToRotate
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if lastUpdateTime > 0{
            dt = currentTime - lastUpdateTime
        }else{
            dt = 0
        }
        lastUpdateTime = currentTime
        
        /* //uncomment these lines to stop where you last tapped
        differenceInPosition = lastTouchLocation.locationInNode(self) - zombie.position
        let zombieMoveFrame = zombieMovePointsPerSec * CGFloat(dt)
        
        if(differenceInPosition.length() <= zombieMoveFrame){
            moveSprite(zombie, velocity: CGPoint.zero)
            zombie.position = lastTouchLocation.locationInNode(self)
        }else{
        */
        
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        moveSprite(zombie, velocity: velocity)
        
        //}
        
        boundsCheckZombie()
        
    }
}
