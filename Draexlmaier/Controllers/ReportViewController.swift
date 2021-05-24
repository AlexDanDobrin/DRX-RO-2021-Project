//
//  ReportViewController.swift
//  Draexlmaier
//
//  Created by Alex Dobrin on 05/05/2021.
//

import UIKit
import CoreData

class ReportViewController: UITableViewController {

    var assets: [Asset_employee] = [Asset_employee]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let currentDate = Date()
//
//        print(currentDate)
//
//        loadAssets(
//            with: Asset_employee.fetchRequest(),
//            predicate: NSPredicate(format: "end_of_life > %@", currentDate as NSDate),
//            by: NSSortDescriptor(key: "end_of_life", ascending: true)
//        )
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let currentDate = Date()
        
        loadAssets(
            with: Asset_employee.fetchRequest(),
            predicate: NSPredicate(format: "end_of_life > %@", currentDate as NSDate),
            by: NSSortDescriptor(key: "end_of_life", ascending: true)
        )
    }
    
    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as! ReportCell
        cell.asset = assets[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func loadAssets(with request: NSFetchRequest<Asset_employee>, predicate: NSPredicate? = nil, by sortDescriptor: NSSortDescriptor? = nil) {
        request.predicate = predicate
        if let descriptor = sortDescriptor {
            request.sortDescriptors = [descriptor]
        }
        do {
            assets = try context.fetch(request)
        } catch {
            print("Error fetching assets from context, \(error)")
        }
        
        tableView.reloadData()
    }
}

func dayPrinter(of day: Int) -> String {
    switch day {
    case 1:
        return "1st"
    case 2:
        return "2nd"
    case 3:
        return "3rd"
    case 4...31:
        return "\(day)th"
    default:
        return "Error"
    }
}

func monthPrinter(of month: Int) -> String {
    switch month {
    case 1:
        return("of January")
    case 2:
        return("of February")
    case 3:
        return("of March")
    case 4:
        return("of April")
    case 5:
        return("of May")
    case 6:
        return("of June")
    case 7:
        return("of July")
    case 8:
        return("of August")
    case 9:
        return("of September")
    case 10:
        return("of October")
    case 11:
        return("of November")
    case 12:
        return("of December")
    default:
        return("Error")
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

class ReportCell: UITableViewCell {
    var asset: Asset_employee? {
        didSet {
            assetImage.image = UIImage(systemName: "\(asset!.asset_id).square")
            employeeIdLabel.text = "Employee: \(String(asset!.empl_id))"
            costCenterIdLabel.text = "Center: \(String(asset!.cstc_nr))"
            if let month = asset!.end_of_life?.get(.month), let day = asset!.end_of_life?.get(.day), let year = asset!.end_of_life?.get(.year) {
                dateLabel.text = "Until: \(dayPrinter(of: day)) \(monthPrinter(of: month)), \(year)"
            } else {
                dateLabel.text = "Until: Error"
            }
            dateLabel.textAlignment = .center
        }
    }
    
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var employeeIdLabel: UILabel!
    @IBOutlet weak var costCenterIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}
