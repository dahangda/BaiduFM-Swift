//
//  DownloadTableViewController.swift
//  BaiduFM
//
//  Created by lumeng on 15/4/18.
//  Copyright (c) 2015年 lumeng. All rights reserved.
//

import UIKit

class DownloadTableViewController: UITableViewController {
    
    var list: [Song]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadData()
    }
    
    func loadData(){
        self.list = DataCenter.shareDataCenter.dbSongList.getAllDownload()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadData()
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
        return self.list!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        
        // Configure the cell...
        let song = self.list![indexPath.row]
        
        cell.textLabel?.text = song.name
        cell.detailTextLabel?.text = song.artist
        
        if let url = URL(string:song.pic_url) {
            if let data = try? Data(contentsOf: url){
                cell.imageView?.image = UIImage(data: data)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = self.list![indexPath.row]
        let data:Dictionary<String,AnyObject> = ["song":song]
        NotificationCenter.default.post(name: Notification.Name(rawValue: OTHER_MUSIC_LIST_CLICK_NOTIFICATION), object: nil, userInfo: data)
        
        //导航控制器 跳转到root播放页面
        self.tabBarController?.selectedIndex = 0
        let mainView = self.tabBarController?.viewControllers![0] as! UINavigationController
        mainView.popToRootViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }

    @IBAction func delAllSong(_ sender: UIBarButtonItem) {
        
        Common.cleanAllDownloadSong()
        //更新db
        DataCenter.shareDataCenter.dbSongList.cleanDownloadList()
        self.loadData()
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
