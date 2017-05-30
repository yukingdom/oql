//
//  SecondViewController.swift
//  oqlApp
//
//  Created by yukingdom on 2016/07/08.
//  Copyright © 2016年 yukingdom. All rights reserved.
//

// GUI class

import UIKit
import AVFoundation

class ThirdViewController: UIViewController,AVAudioPlayerDelegate{
    
    @IBOutlet weak var Head: UIButton!
    @IBOutlet weak var Face: UIButton!
    @IBOutlet weak var Beak: UIButton!
    
    @IBOutlet weak var Body: UIButton!
    @IBOutlet weak var Wings: UIButton!
    
    @IBOutlet weak var wordBox: UIImageView!
    @IBOutlet weak var winkEye: UIImageView!
    @IBOutlet weak var LeftEye: UIImageView!
    @IBOutlet weak var RightEye: UIImageView!
    
    @IBOutlet weak var wordLabel: UILabel!
    
    let fileManager = FileManager.default
    var player : AVAudioPlayer?
    
    let folderName : [String] = ["Head","Face","Beak","Body","Wings"]
    var fileNameGui : [String] = []
    var stringAudioPath : String = ""
    var buttonNum : Int = 0
    
    
    let documentPath : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    var pathEncoded : String = ""
    var audioPath : NSURL = NSURL()
    
    func saveFolderPath(_ FolderNum: Int) -> String{
        return "\(self.documentPath)/\(self.folderName [(FolderNum)])"
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        allHideObject()
    
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func allHideObject () {
        wordBox.isHidden = true
        wordLabel.isHidden = true
        winkEye.isHidden = true
    }
    
    func eyeshide(_ hide: Bool){
        RightEye.isHidden = hide
        LeftEye.isHidden = hide
    }
    
    @IBAction func pushedHead(_ sender: UIButton) {
        pushedParts(0)
    }
    @IBAction func pushedFace(_ sender: UIButton) {
        eyeshide(true)
        winkEye.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // 0.8秒後に実行したい処理
            self.allHideObject()
            self.eyeshide(false)
        }
    }
    @IBAction func pushedBeak(_ sender: UIButton) {
        pushedParts(2)
    }
    @IBAction func pushedBody(_ sender: UIButton) {
        pushedParts(3)
    }
    @IBAction func pushedWings(_ sender: UIButton) {
        pushedParts(4)
    }
   
    
    
    func pushedParts(_ partsNum: Int){
        
        
        fileNameGui = fileManager.subpaths(atPath: self.saveFolderPath(partsNum))!
        
        if fileNameGui.isEmpty{
            //配列空の時何もしない
        }else{
            let randomNum = Int(arc4random_uniform(UInt32(fileNameGui.count)))
            stringAudioPath = "\(saveFolderPath(partsNum))/\(fileNameGui[randomNum])"
            pathEncoded = stringAudioPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            audioPath = URL(string: pathEncoded)! as NSURL
            
            
            wordLabel.text = fileNameGui[randomNum].replacingOccurrences(of: ".m4a", with: "")
            wordBox.isHidden = false
            wordLabel.isHidden = false
            //eyeshide(true)
            
            
            play()
            
        }
        
    }
    func play() {
        do {
            try player = AVAudioPlayer(contentsOf:audioPath as URL)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            
        } catch {
            print("再生時にerror出たよ")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        allHideObject()
        /*eyeshide(false)
        winkEye.hidden = true*/
        return
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

