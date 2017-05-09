//
//  InterfaceController.swift
//  BaiduFM WatchKit Extension
//
//  Created by lumeng on 15/4/26.
//  Copyright (c) 2015年 lumeng. All rights reserved.
//

import WatchKit
import Foundation
import Async

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var songImage: WKInterfaceImage!
    @IBOutlet weak var songNameLabel: WKInterfaceLabel!
    @IBOutlet weak var playButton: WKInterfaceButton!
    @IBOutlet weak var prevButton: WKInterfaceButton!
    @IBOutlet weak var nextButton: WKInterfaceButton!
    var curPlaySongId:String? = nil
    
    @IBOutlet weak var progressLabel: WKInterfaceLabel!
    @IBOutlet weak var songTimeLabel: WKInterfaceLabel!
    @IBOutlet weak var lrcLabel: WKInterfaceLabel!
    
    @IBOutlet weak var nextLrcLabel: WKInterfaceLabel!
    var timer:Timer? = nil
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let chid = UserDefaults.standard.string(forKey: "LAST_PLAY_CHANNEL_ID"){
            DataManager.shareDataManager.chid = chid
        }
    
        if DataManager.shareDataManager.songInfoList.count == 0 {
            DataManager.getTop20SongInfoList({ () -> Void in
                if let song = DataManager.shareDataManager.curSongInfo{
                    self.playSong(song)
                }
            })
        }else{
            if let song = DataManager.shareDataManager.curSongInfo{
                self.playSong(song)
            }
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(InterfaceController.progresstimer(_:)), userInfo: nil, repeats: true)
        
        // Configure interface objects here.
    }
    
    func playSong(_ info:SongInfo){
        
        self.curPlaySongId = info.id
        
        //UI
        Async.main{
            
            self.progressLabel.setText("00:00")
            self.songTimeLabel.setText("00:00")
            self.lrcLabel.setText("")
            self.nextLrcLabel.setText("")
            
            self.songImage.setImageData(NSData(contentsOfURL: NSURL(string: info.songPicRadio)!)!)
            self.songNameLabel.setText(info.name + "-" + info.artistName)
            
            if DataManager.shareDataManager.curIndex == 0 {
                self.prevButton.setEnabled(false)
            }else{
                self.prevButton.setEnabled(true)
            }
            
            if DataManager.shareDataManager.curIndex >= DataManager.shareDataManager.songInfoList.count-1{
                self.nextButton.setEnabled(false)
            }else{
                self.nextButton.setEnabled(true)
            }
        }
        
        println("curIndex:\(DataManager.shareDataManager.curIndex),all:\(DataManager.shareDataManager.songInfoList.count)")
        println(Double(DataManager.shareDataManager.curIndex) / Double(DataManager.shareDataManager.songInfoList.count))
        if Double(DataManager.shareDataManager.curIndex) / Double(DataManager.shareDataManager.songInfoList.count) >= 0.75{
            self.loadMoreData()
        }
        
        //请求歌曲地址信息
        HttpRequest.getSongLink(info.id, callback: {(link:SongLink?) -> Void in
            if let songLink = link {
                DataManager.shareDataManager.curSongLink = songLink
                //播放歌曲
                DataManager.shareDataManager.mp.stop()
                var songUrl = Common.getCanPlaySongUrl(songLink.songLink)
                DataManager.shareDataManager.mp.contentURL = URL(string: songUrl)
                DataManager.shareDataManager.mp.prepareToPlay()
                DataManager.shareDataManager.mp.play()
                DataManager.shareDataManager.curPlayStatus = 1
                
                //显示歌曲时间
                Async.main{
                    self.songTimeLabel.setText(Common.getMinuteDisplay(songLink.time))
                }
                
                HttpRequest.getLrc(songLink.lrcLink, callback: { lrc -> Void in
                    if let songLrc = lrc {
                        DataManager.shareDataManager.curLrcInfo = Common.praseSongLrc(songLrc)
                        //println(songLrc)
                    }
                })
            }
        })
    }
    
    @IBAction func playButtonAction() {
        
        if DataManager.shareDataManager.curPlayStatus == 1 {
            DataManager.shareDataManager.mp.pause()
            DataManager.shareDataManager.curPlayStatus = 2
            self.playButton.setBackgroundImage(UIImage(named: "btn_play"))
        }else{
            DataManager.shareDataManager.mp.play()
            DataManager.shareDataManager.curPlayStatus = 1
            self.playButton.setBackgroundImage(UIImage(named: "btn_pause"))
        }
    }
    
    @IBAction func prevButtonAction() {
        
        self.prev()
    }
    
    @IBAction func nextButtonAction() {
        
        self.next()
    }
    
    
    func prev(){
        
        DataManager.shareDataManager.curIndex -= 1
        if let song = DataManager.shareDataManager.curSongInfo{
            self.playSong(song)
        }
    }
    
    func next(){
        
        DataManager.shareDataManager.curIndex += 1
        if let song = DataManager.shareDataManager.curSongInfo{
            self.playSong(song)
        }
    }
    
    @IBAction func songListAction() {
        
        self.pushController(withName: "SongListInterfaceController", context: nil)
    }
    
    @IBAction func channelListAction() {
        self.pushController(withName: "ChannelListInterfaceController", context: nil)
    }
    
    func loadMoreData(){
        
        if DataManager.shareDataManager.songInfoList.count >= DataManager.shareDataManager.allSongIdList.count{
            println("no more data:\(DataManager.shareDataManager.songInfoList.count),\(DataManager.shareDataManager.allSongIdList.count)")
            return
        }
        
        var curMaxCount = (Int(DataManager.shareDataManager.curIndex / 20) + 2) * 20
        println("curMaxCount:\(curMaxCount)")
        if DataManager.shareDataManager.songInfoList.count >= curMaxCount {
            return
        }
        
        var startIndex = DataManager.shareDataManager.songInfoList.count
        var endIndex = startIndex + 20
        
        if endIndex > DataManager.shareDataManager.allSongIdList.count-1 {
            endIndex = DataManager.shareDataManager.allSongIdList.count-1
        }
        
        var ids = [] + DataManager.shareDataManager.allSongIdList[startIndex..<endIndex]
        
        println("start load more data:\(startIndex),\(endIndex)")
        HttpRequest.getSongInfoList(ids, callback:{ (infolist:[SongInfo]?) -> Void in
            if let sInfoList = infolist {
                DataManager.shareDataManager.songInfoList += sInfoList
                println("load more data success,count=\(DataManager.shareDataManager.songInfoList.count)")
            }
        })

    }
    
    func progresstimer(_ time:Timer){
    
        if let link = DataManager.shareDataManager.curSongLink {
            var currentPlaybackTime = DataManager.shareDataManager.mp.currentPlaybackTime
            if currentPlaybackTime.isNaN {return}
            
            var curTime = Int(currentPlaybackTime)
            self.progressLabel.setText(Common.getMinuteDisplay(curTime))
            
            if link.time == curTime{
                self.next()
            }
            
            var (curLrc,nextLrc) = Common.currentLrcByTime(curTime, lrcArray: DataManager.shareDataManager.curLrcInfo)
            self.lrcLabel.setText(curLrc)
            self.nextLrcLabel.setText(nextLrc)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if let cur = curPlaySongId {
            if let song = DataManager.shareDataManager.curSongInfo{
                if cur != song.id {
                    self.playSong(song)
                }
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
