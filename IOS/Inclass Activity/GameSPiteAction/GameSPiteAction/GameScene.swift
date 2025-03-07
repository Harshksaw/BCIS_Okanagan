import SpriteKit

class GameScene: SKScene {
    let label = SKLabelNode(text: "Hello SpriteKit!")

    override func didMove(to view: SKView) {
        addChild(label)
        label.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        label.fontSize = 45
        label.fontColor = SKColor.yellow
        label.fontName = "Avenir"

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(recognizer)
    }

    @objc func tap(recognizer: UIGestureRecognizer) {
        let viewLocation = recognizer.location(in: view)
        let sceneLocation = convertPoint(fromView: viewLocation)

        let moveToAction = SKAction.move(to: sceneLocation, duration: 1)
        label.run(moveToAction)
    }
}
