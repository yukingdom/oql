//
//  SecondViewController.swift
//  oqlApp
//
//  Created by yukingdom on 2016/07/08.
//  Copyright © 2016年 yukingdom. All rights reserved.
//

//  Library class

//  タブバーで戻ってきた時にfolderTableViewを更新

import UIKit
import AVFoundation

class SecondViewController: UIViewController, UITableViewDelegate,UITableViewDataSource/*UITabBarDelegate*/
{
    
    // Button

    
    var fileName : [String] = []
    //var filesize : [String] = []
    let folderName : [String] = ["Head","Beak","Body","Wings"]
    var cellID = "MyCell"
    
    
    var path : String = ""
    var folderNum : Int = 0
    var stringAudioPath : String = ""
    var pathEncoded : String = ""
    var audioPath : NSURL = NSURL()
    
    let fileManager = FileManager.default
    let documentPath : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    
    func saveFolderPath(_ FolderNum: Int) -> String{
        return "\(self.documentPath)/\(self.folderName [(FolderNum)])"
    }
    
    func saveFilePath(_ FolderNum: Int, FileName: String) -> String{
        return "\(self.documentPath)/\(self.folderName [(FolderNum)])/\(FileName)"
    }
    
    

    //このviewを最初に読み込んだ時の処理
    override func viewDidLoad() {
        //tabBarController?.tabBar.delegate = self
        
        LibSlider.isEnabled = false
        LibPlayButton.isHidden = true
        super.viewDidLoad()
        filesTableView.delegate = self
        filesTableView.dataSource = self
        HeadButton.isEnabled = false
        fileName = fileManager.subpaths(atPath: self.saveFolderPath(0))!
        filesTableView.reloadData()
        LibSlider.value = 0
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    /*func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        filesTableView.reloadData()
    }*/

    
    @IBOutlet weak var HeadButton: UIButton!
    @IBOutlet weak var BeakButton: UIButton!
    @IBOutlet weak var BodyButton: UIButton!
    @IBOutlet weak var WingsButton: UIButton!
    @IBOutlet weak var filesTableView: UITableView!
    @IBOutlet weak var showSoundName: UILabel!
    
    
    @IBAction func PushedHead(_ sender: AnyObject) {
        allButtonShow()
        HeadButton.isEnabled = false
        folderNum = 0
        choseFolder()
    }
    @IBAction func PushedBeak(_ sender: AnyObject) {
        allButtonShow()
        BeakButton.isEnabled = false
        folderNum = 1
        choseFolder()
    }
    @IBAction func PushedBody(_ sender: AnyObject) {
        allButtonShow()
        BodyButton.isEnabled = false
        folderNum = 2
        choseFolder()
    }
    @IBAction func PushedWings(_ sender: AnyObject) {
        allButtonShow()
        WingsButton.isEnabled = false
        folderNum = 3
        choseFolder()
    }
    
    func choseFolder(){
        fileName.removeAll()
        //filesize.removeAll()
        fileName = fileManager.subpaths(atPath: saveFolderPath(folderNum))!
        filesTableView.reloadData()
    }
    
    
    
    //tableView実装
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileName.count//←セル数
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
        
        cell.textLabel?.text = fileName[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    //左スワイプでセルにボタン表示
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete") { (action, indexPath) -> Void in
            
            //削除処理
            self.stringAudioPath = "\(self.saveFolderPath(self.folderNum))/\(self.fileName[(indexPath as NSIndexPath).row])"
            
            try! FileManager.default.removeItem(atPath: self.stringAudioPath)
            self.fileName.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
        }
        let move = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Move") { (action, indexPath) -> Void in
            
            //移動処理
            self.alertMoveSetting(self.fileName[(indexPath as NSIndexPath).row])
            self.fileName.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            
            /*self.fileName.insert("行追加", atIndex: indexPath.row)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)*/
            //tableView.setEditing(false, animated: true)
        }
        delete.backgroundColor = UIColor.red
        move.backgroundColor = UIColor.blue

        
        return [delete, move]
    }
    
    
    //テーブルビューのセルタップ時操作
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LibPlayButton.isHidden = false
        LibSlider.isEnabled = true
        showSoundName.text = "\(fileName[(indexPath as NSIndexPath).row])"
        stringAudioPath = "\(saveFolderPath(folderNum))/\(fileName[(indexPath as NSIndexPath).row])"
        pathEncoded = stringAudioPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    audioPath = NSURL(string : pathEncoded)!
        
    
    }
    
    //player系
    var player = AVAudioPlayer()
    var timer = Timer()
    
    @IBOutlet weak var LibSlider: UISlider!
    @IBOutlet weak var LibPlayButton: UIButton!
    @IBOutlet weak var LibCurrentTimeLabel: UILabel!
    @IBOutlet weak var LibTotalTimeLabel: UILabel!
    
    @IBAction func pushedPlayBtn(_ sender: AnyObject) {
        
        do {
            try player = AVAudioPlayer(contentsOf: audioPath as URL)
            player.prepareToPlay()
        }catch{
            print("eroror")
        }
        
        LibTotalTimeLabel.text = formatTimeString(player.duration)
        LibSlider.maximumValue = Float(player.duration)
        
        if !player.isPlaying{
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SecondViewController.updatePlayingTime), userInfo: nil, repeats: true)
            player.play()
            LibPlayButton.setTitle("PLAY", for: UIControlState())
        } else {
            player.pause()
            LibPlayButton.setTitle("Play", for: UIControlState())
        }
    }
    
    @IBAction func sliderMove(_ sender: UISlider) {
        player.currentTime = Double(LibSlider.value)
        self.updatePlayingTime()
    }

    
    func updatePlayingTime() {
        LibSlider.value = Float(player.currentTime)
        LibCurrentTimeLabel.text = formatTimeString(player.currentTime)
    }
    
    //フレーム数の方で今度はやりたい。
    func formatTimeString(_ d: Double) -> String {
        let s: Int = Int(d.truncatingRemainder(dividingBy: 60))
        let m: Int = Int(((d-Double(s)) / 60).truncatingRemainder(dividingBy: 60))
        let str = String(format: "%02d:%02d", m, s)
        return str
    }
    
    
    
   
    func allButtonShow(){
        
        HeadButton.isEnabled = true
        BeakButton.isEnabled = true
        BodyButton.isEnabled = true
        WingsButton.isEnabled = true
        
    }
    
    
    
    func alertMoveSetting(_ saveSourceFile: String){
        let alertMove: UIAlertController = UIAlertController( title:"\(saveSourceFile)を移動", message:"移動先を選択", preferredStyle:UIAlertControllerStyle.alert)
        
        let defActionHead: UIAlertAction = UIAlertAction(title: "Head",style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            //headフォルダにdemo.cafをコピーし、filename.cafに名前を変更し格納
            //以下後で関数にした方がいいかも。
            try! FileManager.default.moveItem(atPath: "\(self.saveFolderPath(self.folderNum))/\(saveSourceFile)",toPath:self.saveFilePath(0,FileName: saveSourceFile))
            print (self.saveFilePath(0,FileName: saveSourceFile))
            
        })
        let defActionBeak: UIAlertAction = UIAlertAction(title: "Beak",style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            try! FileManager.default.moveItem(atPath: "\(self.saveFolderPath(self.folderNum))/\(saveSourceFile)",toPath:self.saveFilePath(1,FileName: saveSourceFile))
            print (self.saveFilePath(1,FileName: saveSourceFile))
        })
        let defActionBody: UIAlertAction = UIAlertAction(title: "Body",style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            try! FileManager.default.moveItem(atPath: "\(self.saveFolderPath(self.folderNum))/\(saveSourceFile)",toPath:self.saveFilePath(2,FileName: saveSourceFile))
            print (self.saveFilePath(2,FileName: saveSourceFile))
        })
        let defActionWings: UIAlertAction = UIAlertAction(title: "Wings",style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            try! FileManager.default.moveItem(atPath: "\(self.saveFolderPath(self.folderNum))/\(saveSourceFile)",toPath:self.saveFilePath(3,FileName: saveSourceFile))
            print (self.saveFilePath(3,FileName: saveSourceFile))
        })
        /*let cancelSave: UIAlertAction = UIAlertAction(title: "キャンセル",style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            print ("cancel")
        })
        */
        if folderNum == 0{
        }else{
            alertMove.addAction(defActionHead)
        }
        if folderNum == 1{
        }else{
        alertMove.addAction(defActionBeak)
        }
        if folderNum == 2{
        }else{
        alertMove.addAction(defActionBody)
        }
        if folderNum == 3{
        }else{
        alertMove.addAction(defActionWings)
        }
        //alertMove.addAction(cancelSave)
        
        
        present(alertMove, animated: true, completion: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




