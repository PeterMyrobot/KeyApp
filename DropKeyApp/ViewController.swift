//
//  ViewController.swift
//  DropKeyApp
//
//  Created by apple on 27/11/2016.
//  Copyright © 2016 Peter. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController , BLECentralDelegate{

    var BLEmanager: BLECentralManager!

    @IBOutlet weak var bleStateLabel: UILabel!
    @IBOutlet weak var bleButton: UIButton!

    @IBAction func bleFunction(_ sender: Any) {
        if bleButton.currentTitle == "Disconnect"{
            self.BLEmanager.manager.cancelPeripheralConnection(self.BLEmanager.Arduino)
        }else if bleButton.currentTitle == "Connect"{
            self.BLEmanager.manager.connect(BLEmanager.Arduino, options: nil)
        }
    }

    @IBAction func up(_ sender: Any) {
        BLEmanager.send(command: "a")
    }

    @IBAction func stop(_ sender: Any) {
        BLEmanager.send(command: "c")
    }
    @IBAction func down(_ sender: Any) {
        BLEmanager.send(command: "d")
    }
    @IBAction func auto(_ sender: Any) {
        BLEmanager.send(command: "b")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)

        BLEmanager = BLECentralManager(delegate: self)
        BLEmanager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func connectToDevice() {
        bleStateLabel.text = "Connected"
        bleButton.setTitle("Disconnect", for: .normal)
    }
    func disconnectFromDevice() {
        bleStateLabel.text = "disconnect"
        bleButton.setTitle("Connect", for: .normal)
    }

    func appMovedToBackground() {
        print("App moved to background!")
        self.BLEmanager.manager.cancelPeripheralConnection(self.BLEmanager.Arduino)
    }


}

