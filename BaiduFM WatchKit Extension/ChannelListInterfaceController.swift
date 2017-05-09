//
//  ChannelListInterfaceController.swift
//  BaiduFM
//
//  Created by lumeng on 15/4/26.
//  Copyright (c) 2015年 lumeng. All rights reserved.
//

import WatchKit
import Foundation


class ChannelListInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var table: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if DataManager.shareDataManager.chList.count == 0 {
            HttpRequest.getChannelList({(list:[Channel]?) -> Void in
                if let chlist = list {
                    DataManager.shareDataManager.chList = chlist
                    self.loadTable()
                }
            })
        }else{
            self.loadTable()
        }
        
        // Configure interface objects here.
    }
    
    func loadTable(){
        
        self.table.setNumberOfRows(DataManager.shareDataManager.chList.count, withRowType: "tableRow")
        
        for i:Int in 0..<self.table.numberOfRows {
            let row:ChannelTableRow = self.table.rowController(at: i) as! ChannelTableRow
            row.nameLabel.setText(DataManager.shareDataManager.chList[i].name)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        var ch = DataManager.shareDataManager.chList[rowIndex]
        println("\(ch.id),\(ch.name)")
        DataManager.shareDataManager.chid = ch.id
        
        self.pushController(withName: "SongListInterfaceController", context: self)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
