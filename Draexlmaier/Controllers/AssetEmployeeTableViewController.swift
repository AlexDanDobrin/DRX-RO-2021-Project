//
//  AssetViewController.swift
//  Draexlmaier
//
//  Created by Alex Dobrin on 06/05/2021.
//

import UIKit
import CoreData

class AssetEmployeeViewController: UITableViewController {
    
    var assets: [Asset_employee] = [Asset_employee]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var empl_cstc: String?
    
    var employee: String? {
        didSet {
            loadAssets(
                with: Asset_employee.fetchRequest(),
                predicate: NSPredicate(format: "empl_id MATCHES %@", argumentArray: [employee!])
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAssets(
            with: Asset_employee.fetchRequest(),
            predicate: NSPredicate(format: "empl_id MATCHES %@", argumentArray: [employee!])
        )
    }
    
    @IBAction func addAssetEmployee(_ sender: UIBarButtonItem) {
        var asset_id = UITextField()
        var end_of_life = UITextField()
        var from = UITextField()
        var to = UITextField()
        
        let alert = UIAlertController(title: "Add new asset", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            
            if let id = asset_id.text, let cc_nr = self.empl_cstc, let str_from = from.text, let str_to = to.text {
                
                guard let asset = self.Asset_obj(id) else {
                    self.showToast(controller: self, message: "Asset with id \(id) does not exist!", seconds: 1.5)
                    return
                }
                
                if asset.asset_cstc_nr != self.empl_cstc {
                    self.showToast(controller: self, message: "Cost center of asset must be the same as employer!", seconds: 1.5)
                    return
                }
                
                let newAsset = Asset_employee(context: self.context)
                newAsset.empl_id = Int32(self.employee!)!
                newAsset.asset_id = Int32(id)!
                newAsset.cstc_nr = Int16(self.empl_cstc!)!
                newAsset.from = str_from
                newAsset.to = str_to
                newAsset.end_of_life = dateFormatter.date(from: end_of_life.text!)
                newAsset.ofAsset = asset
                newAsset.ofCostCenter = self.CostCenter_obj(cc_nr)
                newAsset.ofEmployee = self.Employee_obj(self.employee!)
                
                self.assets.append(newAsset)
                
                self.saveAssets()
            }
            
        }
        
        alert.addTextField { (assetIdTextField) in
            assetIdTextField.placeholder = "Id of the asset"
            asset_id = assetIdTextField
        }
        
        alert.addTextField { (fromTextField) in
            fromTextField.placeholder = "Date of asset reception"
            from = fromTextField
        }
        
        alert.addTextField { (toTextField) in
            toTextField.placeholder = "Date of asset termination"
            to = toTextField
        }
        
        alert.addTextField { (dateTextField) in
            dateTextField.placeholder = "Date of asset expiration dd/mm/yy"
            end_of_life = dateTextField
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetEmployeeCell", for: indexPath) as! AssetEmployeeCell
        if let found_asset = Asset_obj(String(assets[indexPath.row].asset_id)) {
            cell.asset_name = found_asset.name
        }
        cell.asset = assets[indexPath.row]
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            return UISwipeActionsConfiguration(actions: [
                makeDeleteContextualAction(forRowAt: indexPath),
                makeEditContextualAction(forRowAt: indexPath)
            ])
        }

    //MARK: - Contextual Actions
    private func makeDeleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: "Delete") { (action, swipeButtonView, completion) in
            
            self.context.delete(self.assets[indexPath.row])
            self.assets.remove(at: indexPath.row)
            self.saveAssets()
            
            completion(true)
        }
    }

    private func makeEditContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: "Edit") { (action, swipeButtonView, completion) in
            var asset_id = UITextField()
            var empl_id = UITextField()
            var cstc_nr = UITextField()
            var end_of_life = UITextField()
            var from = UITextField()
            var to = UITextField()
            
            let alert = UIAlertController(title: "Edit asset", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Add", style: .default) { (action) in
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy"
                
                let old_empl_id =  String(self.assets[indexPath.row].empl_id)
                
                if let new_empl_id = empl_id.text, let a_id = asset_id.text, let cc_nr = cstc_nr.text, let a_from = from.text, let a_to = to.text, let eol = dateFormatter.date(from: end_of_life.text!) {
                    
                    if old_empl_id != new_empl_id {
                        guard let asset = self.Asset_obj(a_id) else {
                            self.showToast(controller: self, message: "Asset with id \(asset_id) does not exist!", seconds: 1.5)
                            return
                        }
                        
                        guard let employee = self.Employee_obj(new_empl_id) else {
                            self.showToast(controller: self, message: "Employee with id \(new_empl_id) does not exist!", seconds: 1.5)
                            return
                        }
                        
                        if asset.asset_cstc_nr != employee.costcenter {
                            self.showToast(controller: self, message: "Cost center of asset must be the same as employer!", seconds: 1.5)
                            return
                        }
                        
                        let newAsset = Asset_employee(context: self.context.self)
                        newAsset.empl_id = Int32(new_empl_id)!
                        newAsset.ofEmployee = self.Employee_obj(String(new_empl_id))
                        newAsset.asset_id = Int32(a_id)!
                        newAsset.ofAsset = asset
                        newAsset.cstc_nr = Int16(cc_nr)!
                        newAsset.ofCostCenter = self.CostCenter_obj(String(cc_nr))
                        newAsset.from = a_from
                        newAsset.to = a_to
                        newAsset.end_of_life = eol
                        
                    } else {
                        guard let asset = self.Asset_obj(a_id) else {
                            self.showToast(controller: self, message: "Asset with id \(asset_id) does not exist!", seconds: 1.5)
                            return
                        }
                        
                        guard let employee = self.Employee_obj(old_empl_id) else {
                            self.showToast(controller: self, message: "Employee with id \(new_empl_id) does not exist!", seconds: 1.5)
                            return
                        }
                        
                        if asset.asset_cstc_nr != employee.costcenter {
                            self.showToast(controller: self, message: "Cost center of asset must be the same as employer!", seconds: 1.5)
                            return
                        }

                        self.assets[indexPath.row].asset_id = Int32(a_id)!
                        self.assets[indexPath.row].ofAsset = asset
                        self.assets[indexPath.row].cstc_nr = Int16(cc_nr)!
                        self.assets[indexPath.row].ofCostCenter = self.CostCenter_obj(String(cc_nr))
                        self.assets[indexPath.row].from = a_from
                        self.assets[indexPath.row].to = a_to
                        self.assets[indexPath.row].end_of_life = eol
                    }
                }
            
                
                self.saveAssets()
                
            }
            
            alert.addTextField { (assetIdTextField) in
                assetIdTextField.placeholder = "Id of the asset"
                asset_id = assetIdTextField
            }
            
            alert.addTextField { (emplTextField) in
                emplTextField.placeholder = "Id of the employee"
                empl_id = emplTextField
            }
            
            alert.addTextField { (centerTextField) in
                centerTextField.placeholder = "Number of the cost center"
                cstc_nr = centerTextField
            }
            
            alert.addTextField { (fromTextField) in
                fromTextField.placeholder = "Date of asset reception"
                from = fromTextField
            }
            
            alert.addTextField { (toTextField) in
                toTextField.placeholder = "Date of asset termination"
                to = toTextField
            }
            
            alert.addTextField { (dateTextField) in
                dateTextField.placeholder = "Date of asset termination dd/mm/yy"
                end_of_life = dateTextField
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                // Dont do anything
            }))
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
            
            completion(true)
        }
    }
    
    func saveAssets() {
        do {
            try context.save()
        } catch {
            print("Error saving assets, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadAssets(with request: NSFetchRequest<Asset_employee>, predicate: NSPredicate? = nil) {
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
            let assets = try context.fetch(request)
            if let asset = assets.first {
                return asset
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
            if let result = employee.first {
                return result
            }
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
            if let result = costCenter.first {
                return result
            }
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
    
    
}

class AssetEmployeeCell: UITableViewCell {
    var asset_name: String?
    var asset: Asset_employee? {
        didSet {
            assetImage.image = UIImage(systemName: "\(asset!.asset_id).square")
            employeeIdLabel.text = "\(asset!.ofAsset?.name ?? "Error")"
            costCenterLabel.text = "Cost Center: \(asset!.cstc_nr)"
            validFromLabel.text = "Valid from: \(asset!.from!)"
            validToLabel.text = "Valid until: \(asset!.to!)"
        }
    }
    
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var employeeIdLabel: UILabel!
    @IBOutlet weak var costCenterLabel: UILabel!
    @IBOutlet weak var validFromLabel: UILabel!
    @IBOutlet weak var validToLabel: UILabel!
}
