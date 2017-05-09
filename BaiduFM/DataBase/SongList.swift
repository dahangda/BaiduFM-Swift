//
//  SongList.swift
//  BaiduFM
//
//  Created by lumeng on 15/4/18.
//  Copyright (c) 2015年 lumeng. All rights reserved.
//

import Foundation

class SongList:BaseDb {
    
    func getAll()->[Song]?{
        if self.open(){
            let sql = "SELECT * FROM tbl_song_list"
            if let rs = self.db.executeQuery(sql, withArgumentsIn: nil){
                return self.fetchResult(rs)
            }
        }
        return nil
    }
    
    func get(_ sid:String)->Song?{
        if self.open(){
            let sql = "SELECT * FROM tbl_song_list WHERE sid=?"
            if let rs = self.db.executeQuery(sql, withArgumentsIn: [sid]){
                var ret = self.fetchResult(rs)
                if ret.count == 0 {return nil}
                return ret[0]
            }
        }
        return nil
    }
    
    func getAllDownload()->[Song]?{
        if self.open(){
            let sql = "SELECT * FROM tbl_song_list WHERE is_dl=1"
            if let rs = self.db.executeQuery(sql, withArgumentsIn: nil){
                return self.fetchResult(rs)
            }
        }
        return nil
    }
    
    func getAllLike()->[Song]?{
        if self.open(){
            let sql = "SELECT * FROM tbl_song_list WHERE is_like=1"
            if let rs = self.db.executeQuery(sql, withArgumentsIn: nil){
                return self.fetchResult(rs)
            }
        }
        return nil
    }
    
    func getAllRecent()->[Song]?{
        if self.open(){
            let sql = "SELECT * FROM tbl_song_list WHERE is_recent=1 ORDER BY id DESC LIMIT 20 OFFSET 0"
            if let rs = self.db.executeQuery(sql, withArgumentsIn: nil){
                return self.fetchResult(rs)
            }
        }
        return nil
    }
    
    func fetchResult(_ rs:FMResultSet)->[Song]{
        
        // id:String name:String artist:String album:String song_url:String pic_url:String
        //lrc_url:String time:Int is_dl:Int dl_file:String is_like:Int is_recent:Int
        var ret:[Song] = []
        while rs.next(){
            
            let sid = String(Int(rs.int(forColumn: "sid")))
            let name = rs.string(forColumn: "name") as String
            let artist = rs.string(forColumn: "artist") as String
            let album = rs.string(forColumn: "album") as String
            let song_url = rs.string(forColumn: "song_url") as String
            let pic_url = rs.string(forColumn: "pic_url") as String
            let lrc_url = rs.string(forColumn: "lrc_url") as String
            let time = Int(rs.int(forColumn: "time"))
            let is_dl = Int(rs.int(forColumn: "is_dl"))
            let dl_file_tmp = rs.string(forColumn: "dl_file")
            let is_like = Int(rs.int(forColumn: "is_like"))
            let is_recent = Int(rs.int(forColumn: "is_recent"))
            let format = rs.string(forColumn: "format")
            
            var dl_file = ""
            if dl_file_tmp != nil {
                dl_file = dl_file_tmp as! String
            }
            
            let song = Song(sid: sid, name: name, artist: artist, album: album, song_url: song_url, pic_url: pic_url, lrc_url: lrc_url, time: time, is_dl: is_dl, dl_file: dl_file, is_like: is_like, is_recent: is_recent,format:format!)
            
            ret.append(song)
        }
        self.close()
        return ret
    }
    
    func insert(_ info:SongInfo, link:SongLink)->Bool{
        if self.open(){
            
            if let song = self.get(info.id) {
                println("\(info.id)已经添加")
                return false
            }
            
            if self.open(){
                var sql = "INSERT INTO tbl_song_list(sid,name,artist,album,song_url,pic_url,lrc_url,time,format) VALUES(?,?,?,?,?,?,?,?,?)"
                
                var songUrl = Common.getCanPlaySongUrl(link.songLink)
                var img = Common.getIndexPageImage(info)
                
                var args:[AnyObject] = [info.id,info.name,info.artistName,info.albumName,songUrl,img,link.lrcLink,link.time,link.format]
                var ret = self.db.executeUpdate(sql, withArgumentsIn: args)
                self.close()
                return ret
            }
        }
        return false
    }
    
    func delete(_ sid:String)->Bool{
        if self.open(){
            let sql = "DELETE FROM tbl_song_list WHERE sid=?"
            let ret = self.db.executeUpdate(sql, withArgumentsIn: [sid])
            self.close()
            return ret
        }
        return false
    }
    
    func updateDownloadStatus(_ sid:String, status:Int)->Bool{
        if self.open(){
            let sql = "UPDATE tbl_song_list set is_dl=? WHERE sid=?"
            let ret = self.db.executeUpdate(sql, withArgumentsIn: [status,sid])
            self.close()
            return ret
        }
        return false
    }
    
    func updateLikeStatus(_ sid:String, status:Int)->Bool{
        // status = 0 取消喜欢  1喜欢
        if status != 0 && status != 1 {return false}
        
        if self.open(){
            let sql = "UPDATE tbl_song_list set is_like=? WHERE sid=?"
            let ret = self.db.executeUpdate(sql, withArgumentsIn: [status,sid])
            self.close()
            return ret
        }
        return false
    }

// MARK: - Clear
    func clearLikeList()->Bool{
        if self.open(){
            let sql = "update tbl_song_list set is_like = 0"
            let ret = self.db.executeUpdate(sql, withArgumentsIn: nil)
            self.close()
            return ret
        }
        return false
    }
    
    func cleanDownloadList()->Bool{
        if self.open(){
            let sql = "update tbl_song_list set is_dl = 0"
            let ret = self.db.executeUpdate(sql, withArgumentsIn: nil)
            self.close()
            return ret
        }
        return false
    }
    
    func cleanRecentList()->Bool{
        
        if self.open(){
            var sql = "update tbl_song_list set is_recent=0 where is_dl = 1 or is_like=1"
            let ret1 = self.db.executeUpdate(sql, withArgumentsIn: nil)
            sql = "delete from tbl_song_list where is_recent = 1"
            let ret2 = self.db.executeUpdate(sql, withArgumentsIn: nil)
            self.close()
            return ret1 && ret2
        }
        return false
    }
}
