//
//  ViewController.swift
//  animoji-chat
//
//  Created by xiang on 19/12/2017.
//  Copyright © 2017 dotEngine. All rights reserved.
//

import UIKit
import Animoji
import Toaster

let APP_SECRET = "dotEngine_secret"
let ROOM = "animoji-chat"
let TOKEN_URL = "https://dotengine2.dot.cc/api/generateToken"


class ViewController: UIViewController, DotEngineDelegate, DotStreamDelegate {
    
    var dotEngine: DotEngine!
    var localStream: DotStream!
    var videoCapturer: DotVideoCapturer?
    
    var animoji: Animoji!
    
    var selectButton: UIButton!
    
    var isStarted: Bool  = false
    var displayLink: CADisplayLink!
    var convert: CVPixelBufferConvert!
    
    var imageView: UIImageView!
    
    var queue = DispatchQueue(label: "cc.dot.dotengine.queue")
    
    
    @IBOutlet weak var animojiSelectButton: UIButton!
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
            collectionView.showsVerticalScrollIndicator = false
            collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        }
        
    }
    
    var layout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        convert = CVPixelBufferConvert()
        
        dotEngine = DotEngine.sharedInstance(with:self)
        localStream = DotStream(audio: true, video: true, videoProfile: DotEngineVideoProfile.DotEngine_VideoProfile_360P, delegate: self)
        
        videoCapturer = DotVideoCapturer()
        localStream.videoCaptuer = videoCapturer
        
        
        animoji = Animoji.init()
       
        animoji.frame = CGRect(x:0 ,y:0, width: self.view.frame.size.width, height: self.view.frame.size.height/2)
        
        
        let name = Animoji.PuppetName.all[7]
        animoji.setPuppet(name: name)
        self.view.addSubview(animoji)
        // todo need set frame
//
//        let frame = CGRect(x:0, y: self.view.frame.size.height/2 , width: self.view.frame.size.width, height: self.view.frame.size.height/2)
//
//        localStream.view?.frame = frame
//
//        localStream.view?.backgroundColor = UIColor.white
//
//        self.view.addSubview(localStream.view!)
        
        let randomNum = arc4random_uniform(10000)
        let userId = "stream\(randomNum)"
        
        dotEngine.generateTestToken(TOKEN_URL,appsecret: APP_SECRET, room: ROOM, userId: userId) { (token, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let token = token else {
                print("token is nil")
                return
            }
            
            self.dotEngine.joinRoom(withToken: token)
        }
        
        let displayLink = CADisplayLink(target: self, selector:  #selector(handleDisplayLink))
        displayLink.preferredFramesPerSecond = 20
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        collectionView.frame = CGRect(x:0,y:self.view.frame.size.height,width:self.view.frame.size.width,height:260)
        
        self.view.addSubview(collectionView)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(gestureRecognizer)
        
        self.setupCollectionView()
    }
    
    func setupCollectionView(){
        
        let itemsPerRow = 4
        let inset = collectionView.contentInset.left + collectionView.contentInset.right
        let spacing = layout.minimumInteritemSpacing + layout.minimumLineSpacing
        let availableWidth = self.view.bounds.width - inset - CGFloat(itemsPerRow - 1) * spacing
        let width = floor(availableWidth / CGFloat(itemsPerRow))
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showAnimoji(_ sender: Any) {
        
        let centerY = collectionView.center.y
        
        UIView.animate(withDuration: 0.3) {
            self.collectionView.center.y = centerY - 260
        }
        
        print("show collection view")
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer){
        
        if collectionView.center.y < self.view.frame.size.height  {
            let centerX = collectionView.center.x
            let centerY = collectionView.center.y
            
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionView.center = CGPoint(x:centerX,y:centerY + 260)
            })
            
            print("hide collection view")
        }
    }
    
    @objc func handleDisplayLink(displayLink: CADisplayLink){
        
       // queue.async {
            
        let image = self.animoji.snapshot(with:self.animoji.frame.size)
        
        let ciimage = CIImage(image: image!)
        
            let pixelBuffer = self.convert.processCIImage(ciimage)
            if pixelBuffer != nil {
                self.videoCapturer?.send(pixelBuffer!.takeUnretainedValue(), rotation: VideoRotation.roation_0)
                pixelBuffer?.release()
            }
        //}
    }
    
    //  MARK: - DotEngine Delegate
    
    func dotEngine(_ engine: DotEngine, didJoined peerId: String) {
        print("didJoined")
    }
    
    func dotEngine(_ engine: DotEngine, didLeave peerId: String) {
        print("didLeave")
    }
    
    func dotEngine(_ engine: DotEngine, stateChange state: DotStatus) {
        if state == .connected {
            dotEngine.add(localStream)
        }
    }
    
    func dotEngine(_ engine: DotEngine, didAddLocalStream stream: DotStream) {
        print("didAddLocalStream")
        
        let toast = Toast(text: "Waiting anohter one to join....")
        toast.show()
    }
    
    func dotEngine(_ engine: DotEngine, didRemoveLocalStream stream: DotStream) {
        
    }
    
    func dotEngine(_ engine: DotEngine, didAddRemoteStream stream: DotStream) {
        print("didAddRemoteStream")
        
        let toast = Toast(text: "Someone joined")
        toast.show()
        
        let frame = CGRect(x:0, y: self.view.frame.size.height/2 , width: self.view.frame.size.width, height: self.view.frame.size.height/2)
        
        stream.view?.frame = frame
        
        stream.view?.backgroundColor = UIColor.white
        
        self.view.addSubview(stream.view!)
        
    }
    
    func dotEngine(_ engine: DotEngine, didRemoveRemoteStream stream: DotStream) {
        print("didRemoveRemoteStream")
        
    }
    
    func dotEngine(_ engine: DotEngine, didOccurError errorCode: DotEngineErrorCode) {
        print("didOccurError \(errorCode)")
    }
    
    // MARK: - DotStream
    
    func stream(_ stream: DotStream?, didMutedVideo muted: Bool) {
    }
    
    func stream(_ stream: DotStream?, didMutedAudio muted: Bool) {
    }
    
    func stream(_ stream: DotStream?, didGotAudioLevel audioLevel: Int32) {
        print("didGotAudioLevel \(audioLevel)")
    }
}


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Animoji.PuppetName.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        let name = Animoji.PuppetName.all[indexPath.item]
        cell.imageView.image = Animoji.thumbnail(forPuppetNamed: name.rawValue)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let name = Animoji.PuppetName.all[indexPath.item]
        animoji.setPuppet(name: name)
    }
}


class Cell: UICollectionViewCell {
    lazy var imageView: UIImageView = { [unowned self] in
        let imageView = UIImageView(frame: self.contentView.bounds)
        imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView)
        return imageView
        }()
}


