//
//  AssetViewController.swift
//  Draexlmaier
//
//  Created by Alex Dobrin on 06/05/2021.
//

import UIKit

class AssetViewController: UITableViewController {
    
    var employee: String?
    var costCenter: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let e = employee {
            print(e)
        }
        
        if let cc = costCenter {
            print(cc)
        }
    }
    
    @IBAction func addAssetE(_ sender: UIBarButtonItem) {
        print("Button was pressed from E Asset VC.")
    }
    
    @IBAction func addAssetCC(_ sender: UIBarButtonItem) {
        print("Button was pressed from CC Asset VC.")
    }

}
