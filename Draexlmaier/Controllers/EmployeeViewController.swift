//
//  EmployeeViewController.swift
//  Draexlmaier
//
//  Created by Alex Dobrin on 05/05/2021.
//

import UIKit
import CoreData

class EmployeeViewController: UITableViewController {
    
    var employees: [Employee] = [Employee]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadEmployees()
    }

    
    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeCell
        cell.employee = employees[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EtoAsset", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AssetEmployeeViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.employee = String(employees[indexPath.row].empl_id)
            destinationVC.empl_cstc = employees[indexPath.row].costcenter
        }
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
            
            self.context.delete(self.employees[indexPath.row])
            self.employees.remove(at: indexPath.row)

            self.saveEmployees()
            
            completion(true)
        }
    }

    private func makeEditContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: "Edit") { (action, swipeButtonView, completion) in
            var id = UITextField()
            var costCenter = UITextField()
            var name = UITextField()
            var manager = UITextField()
            
            let alert = UIAlertController(title: "Edit employee", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Update", style: .default) { (action) in
                
                if let empl_id = Int32(id.text!), let cc_nr = costCenter.text, let empl_name = name.text, let manager_id = manager.text {
                    guard let _ = self.CostCenter_obj(cc_nr) else {
                        self.showToast(controller: self, message: "Cost center with no \(cc_nr) does not exist!", seconds: 1.5)
                        return
                    }
                    
                    if self.employees[indexPath.row].empl_id != empl_id, let _ = self.Employee_obj(id.text!) {
                        self.showToast(controller: self, message: "Id is already taken", seconds: 1.5)
                        return
                    }
                    
                    self.employees[indexPath.row].empl_id = empl_id
                    self.employees[indexPath.row].costcenter = cc_nr
                    self.employees[indexPath.row].name = empl_name
                    self.employees[indexPath.row].manager = manager_id
                    self.saveEmployees()
                }
              
            }
            
            alert.addTextField { (idTextField) in
                idTextField.placeholder = "Id of the employee"
                id = idTextField
            }
            
            alert.addTextField { (nameTextField) in
                nameTextField.placeholder = "Name of the employee"
                name = nameTextField
            }
            
            alert.addTextField { (costCenterTextField) in
                costCenterTextField.placeholder = "Employee's cost center"
                costCenter = costCenterTextField
            }
            
            alert.addTextField { (managerTextField) in
                managerTextField.placeholder = "Manager of the employee"
                manager = managerTextField
            }
            
            alert.addAction(action)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                // Dont do anything
            }))
            
            self.present(alert, animated: true, completion: nil)
            completion(true)
        }
    }
    
    // MARK: - Add New Employee
    @IBAction func addNewEmployee(_ sender: UIBarButtonItem) {
        var id = UITextField()
        var costCenter = UITextField()
        var name = UITextField()
        var manager = UITextField()
        
        let alert = UIAlertController(title: "Add new employee", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let empl_id = Int32(id.text!), let cc_nr = costCenter.text, let empl_name = name.text, let manager_id = manager.text {
                guard let _ = self.CostCenter_obj(cc_nr) else {
                    self.showToast(controller: self, message: "Cost center with no \(cc_nr) does not exist!", seconds: 1.5)
                    return
                }
                
                if let _ = self.Employee_obj(id.text!) {
                    self.showToast(controller: self, message: "Id is already taken", seconds: 1.5)
                    return
                }
                
                let newEmployee = Employee(context: self.context)
                newEmployee.empl_id = empl_id
                newEmployee.costcenter = cc_nr
                newEmployee.name = empl_name
                newEmployee.manager = manager_id
                
                self.employees.append(newEmployee)
                
                self.saveEmployees()
            }
            
        }
        
        alert.addTextField { (idTextField) in
            idTextField.placeholder = "Id of the employee"
            id = idTextField
        }
        
        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Name of the employee"
            name = nameTextField
        }
        
        alert.addTextField { (costCenterTextField) in
            costCenterTextField.placeholder = "Employee's cost center"
            costCenter = costCenterTextField
        }
        
        alert.addTextField { (managerTextField) in
            managerTextField.placeholder = "Manager of the employee"
            manager = managerTextField
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            // Dont do anything
        }))
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveEmployees() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadEmployees(with request: NSFetchRequest<Employee> = Employee.fetchRequest()) {
        do {
            employees = try context.fetch(request)
        } catch {
            print("Error fetching employees data, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func query(by keyword: String) -> Employee?{
        let request : NSFetchRequest<Employee> = Employee.fetchRequest()
        
        let predicate = NSPredicate(format: "empl_id MATCHES[cd] %@", argumentArray: [keyword])
        
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request)
            if let employee = result.first {
                return employee
            }
        } catch {
            print("Error fetching the queried data, '\(error)")
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
    
    
}

class EmployeeCell: UITableViewCell {
    var employee: Employee? {
        didSet {
            print()
            numberImage.image = UIImage(systemName: "\(employee!.empl_id).square")
            nameLabel.text = "Name: \(employee!.name ?? "Error")"
            nameLabel.textAlignment = .center
            costCenterLabel.text = "Cost Center: \(employee!.costcenter ?? "Error")"
            costCenterLabel.textAlignment = .center
            managerLabel.text = "Manager: \(employee!.manager ?? "Error")"
            managerLabel.textAlignment = .center
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberImage: UIImageView!
    @IBOutlet weak var costCenterLabel: UILabel!
    @IBOutlet weak var managerLabel: UILabel!
}
