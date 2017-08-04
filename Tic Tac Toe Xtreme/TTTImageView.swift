//
//  TTTImageView.swift
//  Tic Tac Toe Xtreme
//
//  Created by Ashley Gustafson on 4/8/17.
//  Copyright © 2017 Ashley Bassett. All rights reserved.
//

import UIKit

class TTTImageView: UIImageView {
    var player:String?
    var activated:Bool! = false
    
    func setPlayer(_player:String){
        self.player = _player
        if activated == false{
            if _player == "x"{
                self.image = UIImage(named: "x")
            }
            else{
                self.image = UIImage(named: "o")
            }
            activated = true
        }
        
    }


}
