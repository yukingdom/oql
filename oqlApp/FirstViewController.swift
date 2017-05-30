
//
//  FirstViewController.swift
//  oqlApp
//
//  Created by yukingdom on 2016/07/08.
//  Copyright © 2016年 yukingdom. All rights reserved.
//

//  Record class

//　同名ファイルは落ちるのでそれの回避処理が必要

import UIKit
import AVFoundation

class FirstViewController: UIViewController,AVAudioPlayerDelegate{
    
    var demoRecorder : AVAudioRecorder?
    var demoPlayer : AVAudioPlayer?
    let fileManager = FileManager.default
    let defaultName : String = "demo.m4a"
    let folderName : [String] = ["Head","Beak","Body","Wings"]
    
    
    let documentPath : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    func saveFilePath(_ folderNum: Int) -> String{
        return "\(self.documentPath)/\(self.folderName [(folderNum)])/\(self.fileName)\(self.fileExtension)"
    }
    
    var fileName : String = ""
    let fileExtension : String = ".m4a"
    
    @IBOutlet weak var RecordStart: UIButton!
    @IBOutlet weak var RecordStop: UIButton!
    @IBOutlet weak var Rerecord: UIButton!
    @IBOutlet weak var PlayMusic: UIButton!
    @IBOutlet weak var ActivityCircle: UIActivityIndicatorView!
    @IBOutlet weak var TextField: UITextField!
    @IBOutlet weak var Save1: UIButton!
    @IBOutlet weak var Save2: UIButton!
    @IBOutlet weak var Delete: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.startView()
        self.setupAudioRecorder()
        
        for i in 0..<4 {
            let path = documentPath + "/" + folderName[i]
            if fileManager.fileExists(atPath: path) {
    
            } else {
                try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                print(path)
                print("")
            }
        }
        
        
    }
    
    
    
    //録音開始ボタンを押した時の挙動
    @IBAction func PushedRecStart(_ sender: AnyObject) {
        self.AllObjectHide()
        self.UnderRecording()
        
    }
    //再録音ボタンを押した時の挙動Rerecord
    @IBAction func PushedRerecord(_ sender: Any) {
        self.AllObjectHide()
        self.UnderRecording()
    }
    
    
    //録音停止ボタンを押した時の挙動
    @IBAction func PushedRecStop(_ sender: AnyObject) {
        AllObjectHide()
        Rerecord.isHidden = false
        PlayMusic.isHidden = false
        Save1.isHidden = false
        ActivityCircle.isHidden = false
        ActivityCircle.stopAnimating()
        demoRecorder?.stop()
        //録音終了stopメソッド
        
    }
    
    //再生ボタンを押した時の挙動
    @IBAction func PushedPlayMusic(_ sender: AnyObject) {
        ActivityCircle.color = UIColor.blue
        ActivityCircle.stopAnimating()
        ActivityCircle.startAnimating()
        self.play()
        //録音ファイルを参照し再生
    }
    
    //再生終了の処理
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        ActivityCircle.stopAnimating()
        return
    }
    
    
    //保存1ボタンを押した時の挙動Save1
    @IBAction func PushedSave1(_ sender: UIButton) {
        if fileName == "" {
            AllObjectHide()
        } else {
        }
        Delete.isHidden = false
        TextField.isHidden = false
        TextField.placeholder = "タップして名前を入力"
        //textfield右端に×ボタン表示
        TextField.clearButtonMode = UITextFieldViewMode.always
        //勝手にテキストにカーソル行かせる。TextField.becomeFirstResponder() ※課題
    }
    


    //@テキスト入力中に他ボタン無効化
    @IBAction func EditDidBeginTextField(_ sender: AnyObject) {
        Save2.isEnabled = false
        Delete.isEnabled = false
    
    }
    //@テキスト入力後の挙動
    @IBAction func DidEndOnTextField(_ sender: AnyObject) {
        fileName = TextField.text!
        Save2.isHidden = false
        Save2.isEnabled = true
        Delete.isEnabled = true
    }
    
    //保存2押した時の挙動
    @IBAction func PushedSave2(_ sender: Any) {
        alertSaveSetting(defaultName)
    }

    
    //削除押した時の挙動
    @IBAction func PushedDelete(_ sender: AnyObject) {
        alertDeleteSetting()
    }
    
    
    // 再生
    func play() {
        do {
            try demoPlayer = AVAudioPlayer(contentsOf: self.documentFilePath())
            demoPlayer?.delegate = self
            demoPlayer?.prepareToPlay()
            demoPlayer?.play()
            
        } catch {
            print("再生時にerror出たよ")
        }
    }
    
    
    //再生と録音機能を使うための設定
    func setupAudioRecorder(){
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        let recordSetting  = [
            
            AVFormatIDKey : Int (kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue,
            AVNumberOfChannelsKey: 1 ,
            //AVEncoderBitRateKey : 128,
            //AVSampleRateKey: 40000
        ] as [String : Any]
        
        do {
            try demoRecorder = AVAudioRecorder(url: self.documentFilePath(), settings: recordSetting)
        } catch {
            print("初期設定でerror")
        }
    }
    
    //demo.cafファイルの保存先のパス
    func documentFilePath()-> URL {
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask) as [URL]
        let dirURL = urls[0]
        return dirURL.appendingPathComponent(defaultName)
    }

    
    //全てのオブジェクトを非表示にする関数
    func AllObjectHide(){
        TextField.isHidden = true
        RecordStart.isHidden = true
        RecordStop.isHidden = true
        Rerecord.isHidden = true
        PlayMusic.isHidden = true
        Save1.isHidden = true
        ActivityCircle.isHidden = true
        Save2.isHidden = true
        Delete.isHidden = true
    }
    
    //録音中に見せるボタンとクルクル
    func UnderRecording(){
        RecordStop.isHidden = false
        ActivityCircle.isHidden = false
        ActivityCircle.color = UIColor.red
        ActivityCircle.startAnimating()
        demoRecorder?.record()
        return
    }
    
    //このviewConのスタート画面
    func startView(){
        AllObjectHide()
        RecordStart.isHidden = false
        fileName = ""
        TextField.text?.removeAll()
    }
    
    //タグ分けアラート
    func alertSaveSetting(_ saveSouseFile: String){
        let alertSave: UIAlertController = UIAlertController( title: "\(fileName)\(fileExtension)を保存", message: "タグを選択", preferredStyle: UIAlertControllerStyle.alert)
        
        let defActionHead: UIAlertAction = UIAlertAction(title: "Head",style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            //headフォルダにdemo.cafをコピーし、filename.cafに名前を変更し格納
            //以下後で関数にした方がいいかも。
            try! FileManager.default.moveItem(atPath: "\(self.documentPath)/\(saveSouseFile)",toPath:self.saveFilePath(0))
            print (self.saveFilePath(0))
            self.startView()
                    
        })
        let defActionBeak: UIAlertAction = UIAlertAction(title: "Beak",style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            try! FileManager.default.moveItem(atPath: "\(self.documentPath)/\(saveSouseFile)",toPath:self.saveFilePath(1))
            print (self.saveFilePath(1))
            self.startView()
        })
        let defActionBody: UIAlertAction = UIAlertAction(title: "Body",style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            try! FileManager.default.moveItem(atPath: "\(self.documentPath)/\(saveSouseFile)",toPath:self.saveFilePath(2))
            print (self.saveFilePath(2))
            self.startView()
        })
        let defActionWings: UIAlertAction = UIAlertAction(title: "Wings",style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            try! FileManager.default.moveItem(atPath: "\(self.documentPath)/\(saveSouseFile)",toPath:self.saveFilePath(3))
            print (self.saveFilePath(3))
            self.startView()
        })
        let cancelSave: UIAlertAction = UIAlertAction(title: "キャンセル",style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            print ("cancel")
        })
        alertSave.addAction(defActionHead)
        alertSave.addAction(defActionBeak)
        alertSave.addAction(defActionBody)
        alertSave.addAction(defActionWings)
        alertSave.addAction(cancelSave)
        
        
        present(alertSave, animated: true, completion: nil)
    }
    
    
    
    //削除アラート
    func alertDeleteSetting(){
        
        let alertDelete: UIAlertController = UIAlertController( title: "確認", message: "削除しますか？", preferredStyle: UIAlertControllerStyle.alert)
        
        
        let defActionYes: UIAlertAction = UIAlertAction(title: "はい",style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            //cafデータ削除処理
            self.startView()
            print ("Yes")
        })
        let cancelDelet: UIAlertAction = UIAlertAction(title: "キャンセル",style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            //ここに処理入力
            print ("cancel")
        })
        alertDelete.addAction(defActionYes)
        alertDelete.addAction(cancelDelet)
        
        present(alertDelete, animated: true, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



