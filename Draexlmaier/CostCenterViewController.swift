//
//  CostCenterViewController.swift
//  Draexlmaier
//
//  Created by Alex Dobrin on 05/05/2021.
//

import UIKit

class CostCenterViewController: UITableViewController {
    
    let costCenters = ["Pitesti", "Timisoara", "Cluj"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return costCenters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CostCenterCell", for: indexPath)
        cell.textLabel?.text = costCenters[indexPath.row]
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AssetViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.costCenter = costCenters[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CCtoAsset", sender: self)
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
            action.image?.withTintColor(.systemGreen)
            action.backgroundColor = .systemOrange
            print("EDIT HERE")
            completion(true)
        }
    }

    // MARK: - Add New Cost Center
    @IBAction func addNewCostCenter(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new cost center", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            print("Success!")
        }
        
        alert.addTextField { (noTextField) in
            noTextField.placeholder = "Cost center's number"
        }
        
        alert.addTextField { (managerIdTextField) in
            managerIdTextField.placeholder = "ID of the manager"
        }
        
        alert.addTextField { (deleteFlagTextField) in
            deleteFlagTextField.placeholder = "true / false"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}
