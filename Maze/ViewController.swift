//
//  ViewController.swift
//  Maze
//
//  Created by 森田貴帆 on 2020/05/12.
//  Copyright © 2020 森田貴帆. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var playerView: UIView!//プレイヤーを表す
    var playerMotionManager: CMMotionManager!//iPhomeの動きを感知
    var speedX: Double = 0.0//mプレイヤーが動く速さ
    var speedY: Double = 0.0
    
    
    let screenSize = UIScreen.main.bounds.size
    let maze = [
        [1,0,0,0,1,0],
        [1,0,1,0,1,0],
        [3,0,1,0,1,0],
        [1,1,1,0,0,0],
        [1,0,0,1,1,0],
        [0,0,1,0,0,0],
        [0,1,1,0,1,0],
        [0,0,0,0,1,1],
        [0,1,1,0,0,0],
        [0,0,1,1,1,2],
    ]
    
    //start.goal を表す
    var startView: UIView!
    var goalView: UIView!
    
    //wallviewのフレームを入れる
    var wallRectArray = [CGRect]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let cellWigth = screenSize.width / CGFloat(maze[0].count)
        let cellHeight = screenSize.height / CGFloat(maze.count)
        
        let cellOffsetX = cellWigth / 2
        let cellOffsetY = cellHeight / 2
        
        for y in 0 ..< maze.count {
            for x in 0 ..< maze[y].count{
                switch  maze[y][x] {
                case 1://当たるとおわ
                    let wallView = createView(x: x, y: y, width: cellWigth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                        wallView.backgroundColor = UIColor.black
                        view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                case 2://スタート地点
                    startView = createView(x: x, y: y, width: cellWigth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    startView.backgroundColor = UIColor.green
                    view.addSubview(startView)
                case 3://ごーる地点
                    goalView = createView(x: x, y: y, width: cellWigth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    goalView.backgroundColor = UIColor.red
                    view.addSubview(goalView)
                default:
                    break
                }
            }
        }
        //playerviewの作成
        playerView = UIView(frame: CGRect(x: 0, y: 0, width: cellWigth / 6, height: cellHeight / 6))//playerの幅高さは1マスの６分の１
        playerView.center = startView.center
        playerView.backgroundColor = UIColor.gray
        view.addSubview(playerView)
        //motionmanagerを作成
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        startAcceleremeter()
    }

    func createView(x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> UIView{
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView(frame: rect)
        
        let center = CGPoint (x: offsetX + width * CGFloat(x), y: offsetY + height * CGFloat(y))
        
        view.center = center
        
        return view
    }
    
    func startAcceleremeter(){
        //加速度を取得
        let handler: CMAccelerometerHandler = {(CMAccelerometerData: CMAccelerometerData?, error: Error?) -> Void in
            self.speedX += CMAccelerometerData!.acceleration.x
            self.speedY += CMAccelerometerData!.acceleration.y
            
            //プレイヤーの中心位置の設定
            var posX = self.playerView.center.x + (CGFloat(self.speedX) / 3)
            var posY = self.playerView.center.y - (CGFloat(self.speedY) / 3)
            
            //画面場からプがはみ出しそうだったらシュウせい
            if posX <= self.playerView.frame.width / 2{
                self.speedX = 0
                posX = self.playerView.frame.width / 2
            }
            if posY <= self.playerView.frame.height / 2{
                self.speedY = 0
                posY = self.playerView.frame.height / 2
            }
            if posX >= self.screenSize.width - (self.playerView.frame.width / 2){
                self.speedX = 0
                posX = self.screenSize.width - (self.playerView.frame.width / 2)
            }
            if posY >= self.screenSize.height - (self.playerView.frame.height / 2){
                self.speedY = 0
                posY = self.screenSize.height - (self.playerView.frame.height / 2)
            }
            
            for wallRect in self.wallRectArray{
                //playerviewとwallviewが当たっているかornot
                if wallRect.intersects(self.playerView.frame) {
                    self.gameCheck(result:"gameover", message: "壁に当たりました")
                    return
                }
                //playerviewとgalviewが当たっているかornot
                if self .goalView.frame.intersects(self.playerView.frame){
                    self.gameCheck(result:"clear", message: "クリアしました！")
                    return
                }
            }
           
            self.playerView.center = CGPoint(x: posX, y: posY)
        }
        //加速度の開始
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }
    
    func  gameCheck(result: String, message: String){
        //加速度とめっる
        if playerMotionManager.isAccelerometerActive{
            playerMotionManager.stopAccelerometerUpdates()
        }
        
        let gamecCheckAlert: UIAlertController = UIAlertController(title: result, message: message, preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "もう一度", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.retry()
        })
        
        gamecCheckAlert.addAction(retryAction)
        self.present(gamecCheckAlert, animated: true, completion: nil)
    }
    
    func retry(){
        //ぷれいやいち初期化
        playerView.center  = startView.center
        //加速度センサー始める
        if !playerMotionManager.isAccelerometerActive{
            self.startAcceleremeter()
        }
        //スピード初期化
        speedX = 0.0
        speedY = 0.0
    }
}

