//
//  AssetViewController.swift
//  Draexlmaier
//
//  Created by Alex Dobrin on 06/05/2021.
//

import UIKit
import CoreData

class AssetViewController: UITableViewController {
    
    var assets: [Asset] = [Asset]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var costCenter: String? {
        didSet {
            loadAssets(
                with: Asset.fetchRequest(),
                predicate: NSPredicate(format: "asset_cstc_nr MATCHES %@", argumentArray: [costCenter!])
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addAsset(_ sender: UIBarButtonItem) {
        var asset_id = UITextField()
        var name = UITextField()
        var description = UITextField()

        let alert = UIAlertController(title: "Add new asset", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let id = Int32(asset_id.text!), let desc = description.text, let asset_name = name.text {
                if self.assetIdTaken(for: id) {
                    self.showToast(controller: self, message: "Asset id is already taken!", seconds: 1.5)
                    return
                }
                
                let newAsset = Asset(context: self.context)
                newAsset.asset_id = id
                newAsset.asset_cstc_nr = self.costCenter!
                newAsset.name = asset_name
                newAsset.descript = desc
                newAsset.input_date = Date()
                newAsset.ofCostCenter = self.CostCenter_obj(self.costCenter!)
                
                self.assets.append(newAsset)
                
                self.saveAssets()
            }
        }
        
        alert.addTextField { (assetIdTextField) in
            assetIdTextField.placeholder = "Id of the asset"
            asset_id = assetIdTextField
        }
        
        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Name of the asset"
            name = nameTextField
        }
        
        alert.addTextField { (descTextField) in
            descTextField.placeholder = "Description of the asset"
            description = descTextField
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            // Dont do anything
        }))
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetCell", for: indexPath) as! AssetCell
        cell.asset = assets[indexPath.row]
        return cell
    }

    func saveAssets() {
        do {
            try context.save()
        } catch {
            print("Error saving assets, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadAssets(with request: NSFetchRequest<Asset>, predicate: NSPredicate? = nil) {
        request.predicate = predicate
        
        do {
            assets = try context.fetch(request)
        } catch {
            print("Error fetching assets from context, \(error)")
        }
        
        tableView.reloadData()
    }

    func Asset_obj(_ asset_id: String) -> Asset? {
        let request : NSFetchRequest<Asset> = Asset.fetchRequest()
        
        let predicate = NSPredicate(format: "asset_id MATCHES %@", argumentArray: [asset_id])
        
        request.predicate = predicate
        
        do {
            let asset = try context.fetch(request)
            if let result = asset.first {
                return result
            }
        } catch {
            print("Error fetching asset, \(error)")
        }
        return nil
    }
    
    func Employee_obj(_ empl_id: String) -> Employee? {
        let request : NSFetchRequest<Employee> = Employee.fetchRequest()
        
        let predicate = NSPredicate(format: "empl_id MATCHES %@", argumentArray: [empl_id])
        
        request.predicate = predicate
        
        do {
            let employee = try context.fetch(request)
            return employee.first!
        } catch {
            print("Error fetching asset, \(error)")
        }
        return nil
    }
    
    func CostCenter_obj(_ cstc_nr: String) -> Costcenters? {
        let request : NSFetchRequest<Costcenters> = Costcenters.fetchRequest()
        
        let predicate = NSPredicate(format: "cstc_nr MATCHES %@", argumentArray: [cstc_nr])
        
        request.predicate = predicate
        
        do {
            let costCenter = try context.fetch(request)
            return costCenter.first!
        } catch {
            print("Error fetching asset, \(error)")
        }
        return nil
    }
    
    func showToast(controller: UIViewController, message: String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.red
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    func assetIdTaken(for id: Int32) -> Bool {
        guard let _ = Asset_obj(String(id)) else {
            return false
        }
        return true
    }
}

class AssetCell: UITableViewCell {
    var asset: Asset? {
        didSet {
            idImage.image = UIImage(systemName: "\(asset!.asset_id).square")
            nameLabel.text = "\(asset!.name!)"
            if let day = asset!.input_date?.get(.day), let month = asset!.input_date?.get(.month), let year = asset!.input_date?.get(.year) {
                dateLabel.text = "Date: \(day)-\(month)-\(year)"
            } else {
                dateLabel.text = "Date: Error"
            }
            
        }
    }
    
    @IBOutlet weak var idImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
}
