//
//  ChannelTableViewController.swift
//  BaiduFM
//
//  Created by lumeng on 15/4/13.
//  Copyright (c) 2015年 lumeng. All rights reserved.
//

import UIKit

class ChannelTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DataCenter.shareDataCenter.channelListInfo.count == 0 {
            HttpRequest.getChannelList { (list) -> Void in
                if list == nil {
                    return
                }
                DataCenter.shareDataCenter.channelListInfo = list!
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return DataCenter.shareDataCenter.channelListInfo.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 

        // Configure the cell...
        cell.textLabel?.text = DataCenter.shareDataCenter.channelListInfo[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let channel = DataCenter.shareDataCenter.channelListInfo[indexPath.row]
        DataCenter.shareDataCenter.currentChannel = channel.id
        DataCenter.shareDataCenter.currentChannelName = channel.name
        DataCenter.shareDataCenter.curShowStartIndex = 0
        DataCenter.shareDataCenter.curShowEndIndex = 20
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }

}
