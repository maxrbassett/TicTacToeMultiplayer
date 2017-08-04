//
//  ViewController.swift
//  Tic Tac Toe Xtreme
//
//  Created by Ashley Gustafson on 4/8/17.
//  Copyright © 2017 Ashley Bassett. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate  {
    @IBOutlet var fields: [TTTImageView]!
    @IBOutlet weak var gamefield: UIImageView!
    
    var appDelegate:AppDelegate!
    var currentPlayer:String!
    var fieldImage:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(displayname: UIDevice.current.name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(advertise: true)
        
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.peerChangedStateWithNotification(_:)), name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.handleReceivedDataWithNotification(notification:)), name: NSNotification.Name(rawValue:"MPC_DidReceiveDataNotification"), object: nil)
        
        //setupField()
        currentPlayer = "x"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func connectWithPlayer(_ sender: Any) {

        print("made it to connectwithplayer")
        if appDelegate.mpcHandler.session != nil{
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            self.present(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    
    
    func peerChangedStateWithNotification(_ notification:NSNotification){
        print("In peerChangedStateWithNotification")
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.object(forKey: "state") as! Int
        if state != MCSessionState.connecting.rawValue{
            self.navigationItem.title = "Let's Get Started!"
            setupField();
        }
    }
    
    
    
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        print("In handleReceivedDataWithNotification")
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData
        
        do{
            let message = try JSONSerialization.jsonObject(with: receivedData as Data, options: .allowFragments) as! NSDictionary
            let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
            let senderDisplayName = senderPeerId.displayName
            print(message)
            
            if (message.object(forKey: "string") as AnyObject).isEqual("Let's Play Again!") == true {
                let alert = UIAlertController(title: "Tic Tac Toe", message: "\(senderDisplayName) has started a new game", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Play Again!", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in print("This is the handler")}))
                resetField()
            }else{
                
                let field:Int? = message.object(forKey: "field") as! Int?
                let player:String? = message.object(forKey: "player") as! String?
                
                if field != nil && player != nil{
                    fields[field!].player = player
                    fields[field!].setPlayer(_player: player!)
                    
                    if player == "x"{
                        currentPlayer = "o"
                    }else{
                        currentPlayer = "x"
                    }
                }
                
                checkResults();
                
            }
        }catch {
            print(error.localizedDescription)
        }
        
    }
    
    func checkResults(){
        var winner = ""
        
        if fields[0].player == "x" && fields[1].player == "x" && fields[2].player == "x"{
            winner = "x"
        }else if fields[0].player == "o" && fields[1].player == "o" && fields[2].player == "o"{
            winner = "o"
        }else if fields[3].player == "x" && fields[4].player == "x" && fields[5].player == "x"{
            winner = "x"
        }else if fields[6].player == "x" && fields[7].player == "x" && fields[8].player == "x"{
            winner = "x"
        }else if fields[3].player == "o" && fields[4].player == "o" && fields[5].player == "o"{
            winner = "o"
        }else if fields[6].player == "o" && fields[7].player == "o" && fields[8].player == "o"{
            winner = "o"
        }else if fields[0].player == "x" && fields[4].player == "x" && fields[8].player == "x"{
            winner = "x"
        }else if fields[0].player == "o" && fields[4].player == "o" && fields[8].player == "o"{
            winner = "o"
        }else if fields[2].player == "x" && fields[4].player == "x" && fields[6].player == "x"{
            winner = "x"
        }else if fields[2].player == "o" && fields[4].player == "o" && fields[6].player == "o"{
            winner = "o"
        }else if fields[0].player == "x" && fields[3].player == "x" && fields[6].player == "x"{
            winner = "x"
        }else if fields[0].player == "o" && fields[3].player == "o" && fields[6].player == "o"{
            winner = "o"
        }else if fields[1].player == "x" && fields[4].player == "x" && fields[7].player == "x"{
            winner = "x"
        }else if fields[1].player == "o" && fields[4].player == "o" && fields[7].player == "o"{
            winner = "o"
        }else if fields[2].player == "x" && fields[5].player == "x" && fields[8].player == "x"{
            winner = "x"
        }else if fields[2].player == "o" && fields[5].player == "o" && fields[8].player == "o"{
            winner = "o"
        }
        
        if winner != "" {
            let alert = UIAlertController(title: "Tic Tac Toe", message: "The winner is \(winner)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Play Again!", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.resetField()}))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    
    func fieldTapped(_ recognizer:UITapGestureRecognizer){
        print("I am in fieldTapper")
        let tappedField = recognizer.view as! TTTImageView
        tappedField.setPlayer(_player: currentPlayer)
        
        
        let messageDict = ["field":tappedField.tag, "player":currentPlayer] as [String : Any]
        do {
            let messageData = try JSONSerialization.data(withJSONObject: messageDict, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            let decoded = try JSONSerialization.jsonObject(with: messageData, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data
            
            // you can now cast it with the right type
            if decoded is [String:String] {
                // use dictFromJSON
            }
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
            
            checkResults()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func setupField(){
        gamefield.image = UIImage(named: "field")
        print("I am in setupField")
        for index in 0 ... fields.count - 1{
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.fieldTapped(_:)))
            gestureRecognizer.numberOfTapsRequired = 1
            fields[index].addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func resetField(){
        for index in 0 ... fields.count - 1{
            fields[index].image = nil
            fields[index].activated = false
            fields[index].player = ""
        }
        currentPlayer = "x"
    }
    
    
    @IBAction func newGame(_ sender: Any) {
        resetField()
        
        let messageDict = ["string":"Let's Play Again!"]
        do{
            let messageData = try JSONSerialization.data(withJSONObject: messageDict, options: .prettyPrinted)
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}




