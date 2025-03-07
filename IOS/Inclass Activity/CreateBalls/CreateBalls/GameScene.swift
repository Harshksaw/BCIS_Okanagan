import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.white
        scene!.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        run(SKAction.repeat(SKAction.sequence([
            SKAction.run(createBall),
            SKAction.wait(forDuration: 0.05)
        ]), count: 200))
    }
    
    func createBall() {
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.position = CGPoint(
            x: CGFloat(Int(arc4random()) % Int(size.width)),
            y: size.height - ball.size.height
        )
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        addChild(ball)
    }
}
