//
//  PrintersVC.swift
//  Matter
//
//  Created by Ziyi Liew on 23/12/20.
//

import UIKit
import CoreData

class PrinterTableViewCell: UITableViewCell {
    @IBOutlet weak var printerImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var diameterLabel: UILabel!
}

class PrintersVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var printers:[PrinterDisplay] = []
    var toPrintItem:ObjectDisplay?
    var toPrintSpool:IndividualSpool?
//    var spoolUID:String?
    var showCancel = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "Printers"
        cancelButton.isHidden = true
        
        getCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear: showCancel is \(showCancel)")
        cancelButton.isHidden = showCancel
        if toPrintItem != nil {
            print("toPrint is \(toPrintItem?.name), with weight \(toPrintItem?.weight)")
        }
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        print("clicked cancel")
        // TODO: restore the subtracted weight of the selected spool. Might be better to do the core data modification after selecting the printer
        toPrintItem = nil
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPrinterSegue",
           let nextVC = segue.destination as? AddPrinterVC {
            print("going to AddPrinterVC")
            nextVC.delegate = self
            nextVC.printers = printers
        }
    }
}

// get printers from AddPrinterVC
extension PrintersVC: passPrinters {
    func updatePrinterArray(printer: [PrinterDisplay]) {
        printers = printer
    }
}

// tableview methods
extension PrintersVC: UITableViewDelegate, UITableViewDataSource {
    // set up how many rows are in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return printers.count
    }
    
    // sets up a cell in the tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrinterCell", for: indexPath as IndexPath) as! PrinterTableViewCell
        
        let printer = printers[indexPath.row]
        cell.printerImage.image = printer.image
        cell.nameLabel.text = printer.name
        cell.diameterLabel.text = String(printer.diameter)
        
        return cell
    }
    
    // swipe to delete, only delete if count is 1, otherwise popup alert
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // check that only 1 spool is present
            let printer = printers[indexPath.row]
            let name = printer.name
            print("Delete object")
            print(name)
            
            // confirm that the user wants to delete multiple spools
            let alert = UIAlertController(title: "Are you sure?", message: "\(name) will be deleted", preferredStyle: .alert)
            
            // Delete
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
                self.deleteSingleObject(name: name)
                self.printers.remove(at: indexPath.row)
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
        // check that there is an item to be printed
        if toPrintItem != nil {
            let printer = printers[indexPath.row]
            
            // check the spool and printer diameters match
            if toPrintSpool?.diameter != printer.diameter {
                // can't use this printer, throw error
                let alert = UIAlertController(title: "Error", message: "Spool diameter does not match printer diameter. Choose another printer", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style:.cancel, handler: nil))
                self.present(alert, animated: true)
                return indexPath
            }
            
            // Able to print, confirm
            let alert = UIAlertController(title: "Confirm Print", message: "\(toPrintItem!.name) will be printed using \(printer.name)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style:.default, handler: {action in self.printItem(spool: self.toPrintSpool!, printer: printer)}))
            
            alert.addAction(UIAlertAction(title: "Cancel", style:.cancel, handler: nil))
            self.present(alert, animated: true)
        }
        
        return indexPath
        
    }
}

extension PrintersVC {
    func printItem(spool: IndividualSpool, printer: PrinterDisplay) {
        // update spool weight in core data
        updateSingleSpoolWeight(uid: spool.uid)
        
        // create and add new printing object to core data
        addToPrintJob(printer: printer)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBarController")
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:false, completion:nil)
    }
    
    func addToPrintJob(printer: PrinterDisplay) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let image = toPrintItem!.image?.pngData()
        let item = toPrintItem!.name
        let printerName = printer.name
        let diameter = printer.diameter
        let weight = toPrintItem!.weight
        let completed = false
        
        let currentDateTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyy HH:mm"
        let createdDate = dateFormatter.string(from: currentDateTime)
        let finishedDate = "none"
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Printing", into: context)
        
        object.setValue(image, forKey: "image")
        object.setValue(item, forKey: "item")
        object.setValue(printerName, forKey: "printer")
        object.setValue(diameter, forKey: "diameter")
        object.setValue(weight, forKey: "weight")
        object.setValue(completed, forKey: "completed")
        object.setValue(createdDate, forKey: "createdDate")
        object.setValue(finishedDate, forKey: "finishedDate")
        
        // Commit the changes
        do {
            try context.save()
            print("added print job")
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func getCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Printer")
        var fetchedResults: [NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        // add all objects into objectArray
        for object in fetchedResults! {
            let name = object.value(forKey: "name") as! String
            let diameter = object.value(forKey: "diameter") as! Double
            let image = object.value(forKey: "image") as! Data
            
            printers.append(PrinterDisplay(image: UIImage(data: image)!, name: name, diameter: diameter))
        }
    }
    
    // purges Core Data
    func clearCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Printer")
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
    
    func deleteSingleObject(name: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Printer")
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                // find spools with the matching uid and delete it
                for result:AnyObject in fetchedResults {
                    let currentName = result.value(forKey: "name") as! String
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
    
    func updateSingleSpoolWeight(uid: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Spool")
        var fetchedResults: [NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        for spool in fetchedResults! {
            let currentUid = spool.value(forKey: "uid") as? String
            if currentUid == uid {
                print("modifying spool in updateSingleSpoolWeight")
                let currentWeight = (spool.value(forKey: "weight") as? Double)!
                let updatedWeight = currentWeight - toPrintItem!.weight
                spool.setValue(updatedWeight, forKey: "weight")
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
}
