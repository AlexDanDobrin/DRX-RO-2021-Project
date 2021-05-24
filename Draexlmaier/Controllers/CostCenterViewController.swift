//
//  CostCenterViewController.swift
//  Draexlmaier
//
//  Created by Alex Dobrin on 05/05/2021.
//

import UIKit
import CoreData

class CostCenterViewController: UITableViewController {
    
    var costCenters: [Costcenters] = [Costcenters]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCostCenters()
    }
    
    
    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return costCenters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CostCenterCell", for: indexPath) as! CostCenterCell
        
        if let manager = getManager(for: String(costCenters[indexPath.row].cstc_empl_id)) {
            cell.manager_name = manager.name
            cell.costCenter = costCenters[indexPath.row]
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AssetViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.costCenter = String(costCenters[indexPath.row].cstc_nr)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CCtoAsset", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            return UISwipeActionsConfiguration(actions: [
                makeDeleteContextualAction(forRowAt: indexPath),
                makeEditContextualAction(forRowAt: indexPath)
            ])
        }

    //MARK: - Contextual Actions
    private func makeDeleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: "Delete") { (action, swipeButtonView, completion) in
            
            self.costCenters[indexPath.row].cstc_delete_flag = true
            self.saveCostCenters()
            
            completion(true)
        }
    }

    private func makeEditContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: "Edit") { (action, swipeButtonView, completion) in
            
            var cstc_nr = UITextField()
            var cstc_delete_flag = UITextField()
            var cstc_empl_id = UITextField()
            
            let alert = UIAlertController(title: "Edit cost center", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Update", style: .default) { (action) in
                
                if let cc_nr = Int32(cstc_nr.text!), let manager_id = Int32(cstc_empl_id.text!), let delete = Bool(cstc_delete_flag.text!) {
                    if self.centerNumberTaken(for: cc_nr) && self.costCenters[indexPath.row].cstc_nr != Int32(cstc_nr.text!) {
                        self.showToast(controller: self, message: "The number is already taken!", seconds: 1.5)
                        return
                    }
                    guard let _ = self.getManager(for: cstc_empl_id.text!) else {
                        self.showToast(controller: self, message: "The manager with id \(cstc_empl_id.text!) does not exist!", seconds: 1.5)
                        return
                    }
                    self.costCenters[indexPath.row].cstc_nr = cc_nr
                    self.costCenters[indexPath.row].cstc_empl_id = manager_id
                    self.costCenters[indexPath.row].cstc_delete_flag = delete
                    
                }
                self.saveCostCenters()
                
            }
            
            alert.addTextField { (nrTextField) in
                nrTextField.placeholder = "Number of the cost center"
                cstc_nr = nrTextField
            }
            
            alert.addTextField { (managerTextField) in
                managerTextField.placeholder = "Id of the manager"
                cstc_empl_id = managerTextField
            }
            
            alert.addTextField { (deleteTextField) in
                deleteTextField.placeholder = "delete_flag true/false"
                cstc_delete_flag = deleteTextField
            }
            
            alert.addAction(action)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                // Dont do anything
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            completion(true)
        }
    }

    // MARK: - Add New Cost Center
    @IBAction func addNewCostCenter(_ sender: UIBarButtonItem) {
        
        var cstc_nr = UITextField()
        var cstc_empl_id = UITextField()
        
        let alert = UIAlertController(title: "Add new cost center", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in

            if let cc_nr = Int32(cstc_nr.text!), let manager_id = Int32(cstc_empl_id.text!) {
                if self.centerNumberTaken(for: cc_nr) {
                    self.showToast(controller: self, message: "The number is already taken!", seconds: 1.5)
                    return
                }
                guard let _ = self.getManager(for: cstc_empl_id.text!) else {
                    self.showToast(controller: self, message: "The manager with id \(cstc_empl_id.text!) does not exist!", seconds: 1.5)
                    return
                }
                
                let newCostCenter = Costcenters(context: self.context)
                newCostCenter.cstc_nr = cc_nr
                newCostCenter.cstc_empl_id = manager_id
                newCostCenter.cstc_delete_flag = false
                
                self.costCenters.append(newCostCenter)
            }
            
            self.saveCostCenters()
            
        }
        
        alert.addTextField { (nrTextField) in
            nrTextField.placeholder = "Number of the cost center"
            cstc_nr = nrTextField
        }
        
        alert.addTextField { (managerTextField) in
            managerTextField.placeholder = "Id of the manager"
            cstc_empl_id = managerTextField
        }
        
        alert.addAction(action)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            // Dont do anything
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveCostCenters() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCostCenters(with request: NSFetchRequest<Costcenters> = Costcenters.fetchRequest()) {
        do {
            costCenters = try context.fetch(request)
        } catch {
            print("Error fetching cost centers data, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func getManager(for empl_id: String) -> Employee? {
        let request : NSFetchRequest<Employee> = Employee.fetchRequest()
        
        let predicate = NSPredicate(format: "empl_id MATCHES %@", argumentArray: [empl_id])
        
        request.predicate = predicate
        
        do {
            let employees = try context.fetch(request)
            guard let employee = employees.first else {
                return nil
            }
            return employee
        } catch {
            print("Error fetching asset, \(error)")
        }
        return nil
    }
    
    func centerNumberTaken(for cc_nr: Int32) -> Bool {
        for center in costCenters {
            if center.cstc_nr == cc_nr {
                return true
            }
        }
        return false
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

class CostCenterCell: UITableViewCell {
    var manager_name: String?
    var costCenter: Costcenters? {
        didSet {
            idImage.image = UIImage(systemName: "\(costCenter!.cstc_nr).square")
//            idImage.image = UIImage(systemName: "5.square")
            managerIdLabel.text = "   Manager ID: \(costCenter!.cstc_empl_id)"
            managerNameLabel.text = "   Manager Name: \(manager_name ?? "Error")"
        }
    }
    
    @IBOutlet weak var idImage: UIImageView!
    
    @IBOutlet weak var managerIdLabel: UILabel!
    
    @IBOutlet weak var managerNameLabel: UILabel!
}
