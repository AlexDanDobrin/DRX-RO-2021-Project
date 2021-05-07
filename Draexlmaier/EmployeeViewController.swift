//
//  EmployeeViewController.swift
//  Draexlmaier
//
//  Created by Alex Dobrin on 05/05/2021.
//

import UIKit

class EmployeeViewController: UITableViewController {
    
    let employees = [ "Alex", "John", "Michael"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath)
        cell.textLabel?.text = employees[indexPath.row]
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EtoAsset", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AssetViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.employee = employees[indexPath.row]
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
            print("DELETE HERE")
            completion(true)
        }
    }

    private func makeEditContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: "Edit") { (action, swipeButtonView, completion) in
            print("EDIT HERE")
            completion(true)
        }
    }
    
    // MARK: - Add New Employee
    @IBAction func addNewEmployee(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new employee", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            print("Success!")
        }
        
        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Name of the employee"
        }
        
        alert.addTextField { (costCenterTextField) in
            costCenterTextField.placeholder = "Employee's cost center"
        }
        
        alert.addTextField { (managerTextField) in
            managerTextField.placeholder = "Manager of the employee"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
}
