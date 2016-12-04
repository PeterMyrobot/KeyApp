//
//  BleCentralManager.swift
//  DropKeyApp
//
//  Created by apple on 27/11/2016.
//  Copyright © 2016 Peter. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol BLECentralDelegate {
    func connectToDevice()
    func disconnectFromDevice()
}

class BLECentralManager:NSObject, CBCentralManagerDelegate,CBPeripheralDelegate{
    var manager: CBCentralManager!

    var delegate: BLECentralDelegate?
    var Arduino: CBPeripheral!
    var writeValue: CBCharacteristic?
    var readValue: CBCharacteristic?


    init(delegate: BLECentralDelegate){
        super.init()

        manager = CBCentralManager(delegate: self, queue: nil)
    }
    func startScan() {
        if manager.state == CBManagerState.poweredOn {
            print("start Scan")
            manager.scanForPeripherals(withServices: nil, options: nil)
        }
    }


    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state){
        case.poweredOff:
            print( "Device powered off")
        case.poweredOn:
            print( "Device Ready")
            startScan()
        case.resetting:
            print( "Device is resetting")
        case.unauthorized:
            print( "Device not authorized")
        case.unknown:
            print( "BLE state unknow")
        case.unsupported:
            print("Device not supported")
        }

    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("didDisconnectPeripheral")
        if(peripheral.name == "UART"){

            self.Arduino = peripheral
            self.Arduino.delegate = self
            manager.stopScan()
            manager.connect(Arduino, options: nil)
        }

    }


    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
         print("didConnect")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        delegate?.connectToDevice()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.disconnectFromDevice()
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        if let sericePeripherals = peripheral.services as [CBService]!{
            for service in sericePeripherals{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characterArray = service.characteristics as [CBCharacteristic]!{
            for cc in characterArray{
                print(cc)
                if(cc.uuid.uuidString == "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"){
                    print("UART Characteristic UUID found !")
                }
                if(cc.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"){
                    print ("RX Characteristic UUID found !")
                    self.readValue = (cc)
                    peripheral.setNotifyValue(true, for: cc )
                }
                if(cc.uuid.uuidString == "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"){
                    self.writeValue = (cc)
                    send(command: "v")
                    print("TX Characteristic UUID found !")

                }
            }
        }
    }


    func send(command: String){
        if let writeValue = self.writeValue{
            let value:NSData = command.data(using: .utf8)! as NSData

            self.Arduino.writeValue(value as Data, for: writeValue, type: CBCharacteristicWriteType.withoutResponse)
            print("send value \(command)")
        }
    }
}
