//
//  ViewController.swift
//  LedControl
//
//  Created by Sam Leitch on 2017-02-09.
//  Copyright © 2017 Sam Leitch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let allNodesAddress = "224.0.1.187"
    let port : UInt16 = 5683
    let resourcePathString = "led_ring"
    
    var coapClient: SCClient!
    var isSolidColor = true;
    var discoveryMessageId: UInt16! = nil;
    var nodeAddresses: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let client = SCClient(delegate: self)
        client.sendToken = true
        client.autoBlock1SZX = 2
        
        self.coapClient = client
        ledRingGet()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var logTextView: UITextView!
    
    @IBAction func onGetCurrent(_ sender: Any) {
        ledRingGet()
    }
    
    @IBAction func onColorValueChanged(_ sender: UISlider) {
        if(!isSolidColor) { return }
        let r = Int(redSlider.value)
        let g = Int(greenSlider.value)
        let b = Int(blueSlider.value)
        ledRingPut("[\"solid_color\", \(r), \(g), \(b)]")
    }
    
    @IBAction func onSolidColorButton(_ sender: UIButton) {
        isSolidColor = true;
        let r = Int(redSlider.value)
        let g = Int(greenSlider.value)
        let b = Int(blueSlider.value)
        ledRingPut("[\"solid_color\", \(r), \(g), \(b)]")
    }
    
    @IBAction func onStaticRainbowButton(_ sender: UIButton) {
        isSolidColor = false;
        ledRingPut("[\"static_rainbow\"]")
     }
    
    @IBAction func onStrobingRainbowButton(_ sender: UIButton) {
        isSolidColor = false;
        ledRingPut("[\"strobing_rainbow\"]")
    }
    
    @IBAction func onSpinningRainbowButton(_ sender: UIButton) {
        isSolidColor = false;
        ledRingPut("[\"spinning_rainbow\"]")
    }
    
    @IBAction func onStaticDotsButton(_ sender: UIButton) {
        isSolidColor = false;
        ledRingPut("[\"static_dots\"]")
    }
    
    @IBAction func onStrobingDotsButton(_ sender: UIButton) {
        isSolidColor = false;
        ledRingPut("[\"strobing_dots\"]")
    }
    
    @IBAction func onSpinningDotsButton(_ sender: UIButton) {
        isSolidColor = false;
        ledRingPut("[\"spinning_dots\"]")
    }
    
    func ledRingGet() {
        let m = SCMessage(code: SCCodeSample.get.codeValue(), type: .nonConfirmable, payload: nil)
        m.addOption(SCOption.uriPath.rawValue, data: resourcePathString.data(using: String.Encoding.utf8)!)
        coapClient.sendCoAPMessage(m, hostName:allNodesAddress,  port: port)
    }
    
    func ledRingPut(_ message: String) {
        let m = SCMessage(code: SCCodeSample.put.codeValue(), type: .confirmable, payload: message.data(using: String.Encoding.utf8))
        m.addOption(SCOption.uriPath.rawValue, data: resourcePathString.data(using: String.Encoding.utf8)!)
        for nodeAddress in nodeAddresses {
            coapClient.sendCoAPMessage(m, hostName:nodeAddress,  port: port)
        }
    }
}

extension ViewController: SCClientDelegate {
    func swiftCoapClient(_ client: SCClient, didReceiveMessage message: SCMessage) {
        if message.messageId == discoveryMessageId {
            let nodeAddress = message.hostName!
            if !nodeAddresses.contains(nodeAddress) {
                let nodeMessage = "Found new node \(nodeAddress)\n"
                logTextView.text = nodeMessage + logTextView.text
                nodeAddresses.append(nodeAddress)
            }
        }
        
        var payloadstring = ""
        if let pay = message.payload {
            if let string = NSString(data: pay as Data, encoding:String.Encoding.utf8.rawValue) {
                payloadstring = "Payload: \(String(string))\n"
            }
        }
        let firstPartString = "Received t: \(message.type.shortString()) c: \(message.code.toString()) id: \(message.messageId)\n"
        logTextView.text = firstPartString + payloadstring + logTextView.text
        
        if logTextView.text.characters.count > 65536 {
            let middle = logTextView.text.index(logTextView.text.startIndex, offsetBy: 32768)
            logTextView.text = logTextView.text.substring(to: middle)
        }
    }
    
    func swiftCoapClient(_ client: SCClient, didFailWithError error: NSError) {
        logTextView.text = "Failed with Error \(error.localizedDescription)" + logTextView.text
        
        if logTextView.text.characters.count > 65536 {
            let middle = logTextView.text.index(logTextView.text.startIndex, offsetBy: 32768)
            logTextView.text = logTextView.text.substring(to: middle)
        }
    }
    
    func swiftCoapClient(_ client: SCClient, didSendMessage message: SCMessage, number: Int) {
        if message.hostName == allNodesAddress && message.code == SCCodeSample.get.codeValue() {
            discoveryMessageId = message.messageId
        }

        var payloadstring = ""
        if let pay = message.payload {
            if let string = NSString(data: pay as Data, encoding:String.Encoding.utf8.rawValue) {
                payloadstring = "Payload: \(String(string))\n"
            }
        }
        logTextView.text = "Sent (\(number)) t: \(message.type.shortString()) c: \(message.code.toString()) id: \(message.messageId)\n" + payloadstring + logTextView.text
        
        if logTextView.text.characters.count > 65536 {
            let middle = logTextView.text.index(logTextView.text.startIndex, offsetBy: 32768)
            logTextView.text = logTextView.text.substring(to: middle)
        }
    }
}
