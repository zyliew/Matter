//
//  IndividualPrintingVC.swift
//  Matter
//
//  Created by Ziyi Liew on 25/12/20.
//

import UIKit
import CoreData

protocol updateCompletedList {
    func addItemToArray(item: PrintingDisplay)
}

extension IndividualPrintingVC: updatePrintingList {
    func addItemToArray(item: PrintingDisplay) {
        printingArray.append(item)
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

class IndividualPrintingVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var printer:PrinterDisplay?
    var printingArray:[PrintingDisplay] = []
    var delegate:updateCompletedList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        getCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        getCoreData()
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    

}

// tableview methods
extension IndividualPrintingVC: UITableViewDelegate, UITableViewDataSource {
    // set up how many rows are in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return printingArray.count
    }
    
    // sets up a cell in the tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrintingCell", for: indexPath as IndexPath) as! PrintingTableViewCell
        
        let item = printingArray[indexPath.row]
        cell.itemImage.image = item.image
        cell.itemLabel.text = item.item
        cell.printerLabel.text = item.printer
        cell.diameterLabel.text = String(item.diameter)
        cell.materialLabel.text = item.material
        cell.weightLabel.text = String(item.weight)
        cell.cellRow = indexPath.row
        cell.cellIndexPath = indexPath
        cell.delegate = self
        
        return cell
    }
    
    // swipe to delete, only delete if count is 1, otherwise popup alert
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // check that only 1 spool is present
            let item = printingArray[indexPath.row]
            let name = item.item
            print("Delete object")
            print(name)
            
            // confirm that the user wants to delete multiple spools
            let alert = UIAlertController(title: "Are you sure?", message: "\(name) will be removed from the print page", preferredStyle: .alert)
            
            // Delete
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
                self.deleteSingleObject(name: name)
                self.printingArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            
            // Cancel
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }
    }
    
    // deselects the row so it's not highlighted after click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
}

extension IndividualPrintingVC: PrintingTableViewCellDelegate {
    func markCompleted(row: Int, indexPath: IndexPath) {
        print("row \(row) completed button pressed")
        
        let item = printingArray[row]
        // confirm that the user wants to complete print
        let alert = UIAlertController(title: "Are you sure?", message: "\(item.item) will be marked as completed. It can be found in the printer's individual page", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.markCompletedCoreData(uid: item.uid)
            self.printingArray.remove(at: row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            let currentDateTime = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyy HH:mm"
            let finishedDate = dateFormatter.string(from: currentDateTime)
            item.finishedDate = currentDateTime
            self.updateFinishedDate(uid: item.item, date: finishedDate)
            
            self.delegate?.addItemToArray(item: item)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}

extension IndividualPrintingVC {
    func getCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Printing")
        var fetchedResults: [NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        // add not yet completed prints into printingArray
        for object in fetchedResults! {
            let image = object.value(forKey: "image") as! Data
            let item = object.value(forKey: "item") as! String
            let printerCurrent = object.value(forKey: "printer") as! String
            let diameter = object.value(forKey: "diameter") as! Double
            let weight = object.value(forKey: "weight") as! Double
            let material = object.value(forKey: "material") as! String
            let completed = object.value(forKey: "completed") as! Bool
            let uid = object.value(forKey: "uid") as! String
            let createdDateString = object.value(forKey: "createdDate") as! String
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyy HH:mm"
            let createdDate = formatter.date(from: createdDateString)
            
            // check that object is not completed yet
            if !completed  && printerCurrent == printer!.name {
                let toAdd = PrintingDisplay(image: UIImage(data: image)!, item: item, printer: printerCurrent, diameter: diameter, weight: weight, completed: completed, uid: uid, material: material)
                toAdd.createdDate = createdDate!
                
                printingArray.append(toAdd)
            }
        }
    }
    
    // flip bool value of completed for the given PrintingDisplay object
    func markCompletedCoreData(uid: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Printing")
        var fetchedResults: [NSManagedObject]? = nil
        
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        for print in fetchedResults! {
            let currentPrint = print.value(forKey: "uid") as? String
            if currentPrint == uid {
                let completed = !((print.value(forKey: "completed") as? Bool)!)
                print.setValue(completed, forKey: "completed")
                break
            }
        }
        
        do {
            try context.save()
            print("modified core data")
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    // purges Core Data
    func clearCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Printing")
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                }
            }
            try context.save()
            
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        print("core data cleared")
    }
    
    func updateFinishedDate(uid: String, date: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Printing")
        var fetchedResults: [NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        for print in fetchedResults! {
            let currentPrint = print.value(forKey: "item") as? String
            if currentPrint == uid {
                print.setValue(date, forKey: "finishedDate")
                break
            }
        }
        
        do {
            try context.save()
            print("modified core data, updated finishedDate")
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func deleteSingleObject(name: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Printing")
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                // find spools with the matching uid and delete it
                for result:AnyObject in fetchedResults {
                    let currentName = result.value(forKey: "item") as! String
                    if name == currentName {
                        context.delete(result as! NSManagedObject)
                        print("Object with name: \(name) deleted from Core Data")
                        break
                    }
                }
            }
            try context.save()
            
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        print("deleted single object")
    }
}
