//
//  ViewController.swift
//  mobile-geth
//
//  Created by tina on 6/5/2018.
//  Copyright © 2018 tina. All rights reserved.
//

import UIKit
import Geth
import Alamofire
import SwiftyJSON


class ViewController: UIViewController {
    

    @IBOutlet weak var textbox: UITextView!
    
    func reqDone(requestURL: String, completionHandler: @escaping (_ result: Bool) -> ()) {
        Alamofire.request(requestURL).responseJSON { response in
                
                //to get status code
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        //to get JSON return value
                        if let result = response.result.value {
                            let JSON = result as! NSDictionary
                            print(JSON)
                        }
                        completionHandler(true)
                    default:
                        print("error with response status: \(status)")
                        completionHandler(false)
                    }
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        reqDone(requestURL: "https://hupay.herokuapp.com/token/balance/0x5ff2c17ada131e5D9fa0f927395Abe35657e4768") { (result) in
            if(result)
            {
                print("Correct!")
            }
            else{
                print("Wrong Credentials")
            }
        }
        
        let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let ks = GethNewKeyStore(datadir + "/keystore", GethLightScryptN, GethLightScryptP)
        
        // Create a new account with the specified encryption passphrase.
        let newAcc = try! ks?.newAccount("Creation password")
        textbox.text = "New: "+newAcc!.getAddress().getHex()+"\n"
        
        // Export the newly created account with a different passphrase. The returned
        // data from this method invocation is a JSON encoded, encrypted key-file.
        let jsonKey = try! ks?.exportKey(newAcc!, passphrase: "Creation password", newPassphrase: "Export password")
        textbox.text = textbox.text! + "JSON: " + ((NSString(data: jsonKey!, encoding: String.Encoding.utf8.rawValue)! as String) as String) + "\n"
        
        // Update the passphrase on the account created above inside the local keystore.
        try! ks?.update(newAcc, passphrase: "Creation password", newPassphrase: "Update password")
        
        
        // Delete the account updated above from the local keystore.
        try! ks?.delete(newAcc, passphrase: "Update password")
        textbox.text = textbox.text!+"Accs: \(String(describing: ks?.getAccounts().size())) \n"
        
        // Import back the account we've exported (and then deleted) above with yet
        // again a fresh passphrase.
        let impAcc  = try! ks?.importKey(jsonKey, passphrase: "Export password", newPassphrase: "Import password")
        textbox.text = textbox.text!+"Imp: "+impAcc!.getAddress().getHex()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

