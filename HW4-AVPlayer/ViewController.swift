//
//  ViewController.swift
//  HW4-AVPlayer
//
//  Created by 沈庭鋒 on 2023/3/14.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var player = AVPlayer()
    var playerItem : AVPlayerItem?
    var songDuration : Double = 0
    var currentTime : Float = 0
    var currentSong = 0
    var randomSong = 0
    
    let songArray : [songDataModel] = [
        songDataModel(Name: "Desperado", singer: "Eagles", url: Bundle.main.url(forResource: "Desperado", withExtension: "mp3")!),
        songDataModel(Name: "OverYou", singer: "Daughtry", url: Bundle.main.url(forResource: "OverYou", withExtension: "mp3")!),
        songDataModel(Name: "萬千花蕊慈母悲哀", singer: "珂拉琪", url: Bundle.main.url(forResource: "萬千花蕊慈母悲哀", withExtension: "mp3")!)

    ]
    
   
    
    
    
    @IBOutlet weak var songImageView: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var singerName: UILabel!
    
    @IBOutlet weak var songTimeSlider: UISlider!
    
    @IBOutlet weak var backwardButtinOutlet: UIButton!
    
    @IBOutlet weak var playButtonOutlet: UIButton!
    
    @IBOutlet weak var forwardButtonOutlet: UIButton!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var lessTimeLabel: UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var pageOutlet: UIPageControl!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        replacementNewSong() // ???? 加了這個才能解決開啟程式第一下按 page 沒反應的問題。
        songImageView.image = UIImage(named: songArray[currentSong].Name!)
        songName.text = songArray[currentSong].Name!
        singerName.text = songArray[currentSong].singer!
        backgroundImage.image = UIImage(named: songArray[currentSong].Name!)
        songImageSet()
        //循環播放音樂，播到最後會接下一首
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { Notification in
            self.forwardAction()
        }
       
    }
    
    
    
    @IBAction func backwardButton(_ sender: Any) {
        backwardAction()
    }
    
    @IBAction func playButton(_ sender: Any) {
        

        if playerItem == nil{
            replacementNewSong()
            playNPause()
        }else{
            playNPause()
        }
        
        
    }
    
    @IBAction func forwardButton(_ sender: Any) {
        forwardAction()
    }
    
    // 加入UISlider 可移動Slider來控制播放區域
    @IBAction func timeSliderAction(_ sender: UISlider) {
        let time = CMTime(value: CMTimeValue(sender.value), timescale: 1)
                player.seek(to: time)
    }
    
    //隨機播放歌曲
    @IBAction func shuffleButton(_ sender: Any) {
    // 使用while迴圈直到隨機數字與當前數字相同時停止，會跑到數字相同時才會停止，擔心數量一大會影響記憶體或時間
        while randomSong == currentSong{

            randomSong = songArray.indices.randomElement()!
        }
            currentSong = randomSong
            replacementNewSong()
            player.play()
            playButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        
        //另一種不重複隨機歌曲寫法，但若遇到相同歌曲會像是按了沒反應
//            randomSong = songArray.indices.randomElement()!
//        if randomSong == currentSong{
//            randomSong = songArray.indices.randomElement()!
//        }else{
//            currentSong = randomSong
//            replacementNewSong()
//            player.play()
//            playButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//        }
    }
    
    
    @IBAction func pageChangeAction(_ sender: UIPageControl) {

        currentSong = sender.currentPage
        replacementNewSong()
    }
    
    
    // 加入左右滑手是，將兩個手勢加入同一個 Action
    /*
     手勢加入教學參考
     https://medium.com/彼得潘的試煉-勇者的-100-道-swift-ios-app-謎題/真愛的模樣-image-view-和-segmented-control-練習-675d64d5c94c
     */
    @IBAction func SwipeAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
                    forwardAction()
            } else if sender.direction == .right {
                    backwardAction()
            }
    }
    
    
    
    func backwardAction(){
        
        if currentSong == 0 {
            currentSong = songArray.count - 1
            replacementNewSong()
            player.play()
        }else{
            currentSong -= 1
            replacementNewSong()
            player.play()
        }
    playButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
    }
    
    
    func forwardAction(){
        

        if currentSong < songArray.count - 1 {
            currentSong += 1
            replacementNewSong()
            player.play()
        }else{
            currentSong = 0
            replacementNewSong()
            player.play()
        }
        playButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)


        
    }
    
    
    // 設定播放以及暫停鍵的功能
    func playNPause(){
        

        if player.timeControlStatus == .playing{
            playButtonOutlet.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
        }else{
            playButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
        }
        setOutlet()

    }

    
    func replacementNewSong(){
        
        playerItem = AVPlayerItem(url: songArray[currentSong].url!)
        player.replaceCurrentItem(with: playerItem)
        songDuration = playerItem?.asset.duration.seconds ?? 0
        pageOutlet.currentPage = currentSong
        setOutlet()


    }
    
    //設定Label Image 等 Outlet 的顯示
    func setOutlet(){
        // 加入Observer 來觀察歌曲進度

        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: .main) { (CMTime) in
                self.currentTime = Float(self.player.currentTime().seconds)
                self.songImageView.image = UIImage(named: self.songArray[self.currentSong].Name!)
                self.backgroundImage.image = UIImage(named: self.songArray[self.currentSong].Name!)
                self.songName.text = self.songArray[self.currentSong].Name
                self.singerName.text = self.songArray[self.currentSong].singer
                self.songTimeSlider.maximumValue = Float(self.songDuration)
                self.songTimeSlider.value = self.currentTime
                self.songTimeSlider.isContinuous = true
                self.exportTimeValue()
            }
        
      
    }
    // 轉換時間 秒變分
    func exportTimeValue(){
//        let totalTime = Int(songDuration).quotientAndRemainder(dividingBy: 60)
        let currentTimeExport = Int(currentTime).quotientAndRemainder(dividingBy: 60)
        currentTimeLabel.text = String("\(currentTimeExport.quotient):\(currentTimeExport.remainder)")
        let lessTime = Int(Int(songDuration) - Int(currentTime)).quotientAndRemainder(dividingBy: 60)
        lessTimeLabel.text = String("\(lessTime.quotient):\(lessTime.remainder)")
    }
    
    
        //加入歌曲圖片的邊框
    func songImageSet(){
        songImageView.layer.borderWidth = 10
        songImageView.layer.borderColor = CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.4)
        
    }
 /*
    // 加入page controller 控制切換上下首
    func pageChange(){
        
        switch pageOutlet.currentPage{
            
        case 0 :
            currentSong = 0
            if player.timeControlStatus == .playing{
                playButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                replacementNewSong()
            }else{
                replacementNewSong()
            }
        case 1 :
            currentSong = 1
            if player.timeControlStatus == .playing{
                playButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                replacementNewSong()
            }else{
                replacementNewSong()
            }
        case 2 :
            currentSong = 2
            if player.timeControlStatus == .playing{
                playButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                replacementNewSong()
            }else{
                replacementNewSong()
            }

        default:
            return
        }
      
    }
    */
    
}

