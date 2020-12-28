//
//  SpoolVC.swift
//  Matter
//
//  Created by Ziyi Liew on 15/12/20.
//

import UIKit
import CoreData

//// Pass single item between ObjectVC and SpoolVC
//protocol passSingleObject {
//    func passSingleObject(object: ObjectDisplay)
//}

class SpoolTableViewCell: UITableViewCell {
    @IBOutlet weak var spoolImage: UIImageView!
    @IBOutlet weak var materialLabel: UILabel!
    @IBOutlet weak var diameterLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    
}

class SpoolVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    // variables for passing print item to IndividualSpoolsVC
    // set from ObjectVC
    var showCancel = true
//    var printItemName:String?
//    var printItemWeight:Double?
    
//    var delegate:passSingleObject?
    var spoolArray:[SpoolDisplay] = []
    var uids:[String] = []
    
    var toPrint:ObjectDisplay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // setup tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "My Spools"
        cancelButton.isHidden = true
//        clearCoreData()
        getCoreData()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        if (toPrint != nil) {
            self.navigationItem.title = "Select Spool"
        }
        
        cancelButton.isHidden = showCancel

        getCoreData()
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    @IBAction func cancelPrint(_ sender: Any) {
//        self.navigationController?.dismiss(animated: true, completion: nil)
        toPrint = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "individualSpoolsSegue",
            let nextVC = segue.destination as? IndividualSpoolsVC,
            let row = tableView.indexPathForSelectedRow?.row {
            let spools = spoolArray[row]
            nextVC.uids = spools.uids
            nextVC.brand = spools.brand
            nextVC.material = spools.material
            nextVC.color = spools.color
            nextVC.diameter = spools.diameter
            nextVC.image = spools.image
            
            nextVC.toPrint = toPrint
        }
    }
    
}

//extension SpoolVC: ObjectTableViewCellDelegate {
//    func printObject(name: String, weight: Double) {
//        itemName = name
//        itemWeight = weight
//            }
//}

// Core Data methods
extension SpoolVC {
    // Retrieve all spools from Core Data
    func getCoreData() {
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
        
        // Filter and add the spools into spoolArray
        for spool in fetchedResults! {
            checkAndAdd(compare: spool)
        }
    }
    
    // purges Core Data
    func clearCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Spool")
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
    
    // delete a single spool with the given uid
    func deleteSingleData(uid: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Spool")
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                // find spools with the matching uid and delete it
                for result:AnyObject in fetchedResults {
                    let currentUID = result.value(forKey: "uid") as! String
                    if uid == currentUID {
                        context.delete(result as! NSManagedObject)
                        print("Spool with UID: \(uid) deleted from Core Data")
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
        
        print("deleted single data")
    }
    
    // delete the list of spools with the given uids
    func deleteMultipleData(uids: [String]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Spool")
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                // find spools with matching uid and delete it
                for result:AnyObject in fetchedResults {
                    let currentUID = result.value(forKey: "uid") as! String
                    if uids.contains(currentUID) {
                        context.delete(result as! NSManagedObject)
                        print("Spool with UID: \(currentUID) deleted from Core Data")
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
        
        print("deleted multiple data")
    }
    
    // checks if spool is already in the spoolArray, add or increment count accordingly
    func checkAndAdd(compare: NSManagedObject) {
//        print("check and add")
        let otherColor = compare.value(forKey: "color") as! String
        let otherDiameter = compare.value(forKey: "diameter") as! Double
        let otherMaterial = compare.value(forKey: "material") as! String
        let otherBrand = compare.value(forKey: "brand") as! String
        let uid = compare.value(forKey: "uid") as! String
//        print("otherColor: \(otherColor), otherDiameter: \(otherDiameter), otherMaterial: \(otherMaterial)")
        
        for spool in spoolArray {
            let color = spool.color
            let diameter = spool.diameter
            let material = spool.material
            let brand = spool.brand
//            print("color: \(color), diameter: \(diameter), material: \(material), uid: \(uid)")
//            print("uids \(uids)")
            
            // Existing material
            if color == otherColor && diameter == otherDiameter && material == otherMaterial && brand == otherBrand {
                // check if spool is already in spoolArray
                if uids.contains(uid) { return }
                // already in spoolArray, increment count
//                print("material already in spoolArray")
                
                spool.count += 1
                spool.addUid(uid: uid)
                uids.append(uid)
                return
            }
        }
        
        // New material, add to spoolArray
        print("spoolArray empty, add to spoolArray")
        if let otherImage = compare.value(forKey: "image") {
            // create with the uploaded image
            print("add with image")
            let newSpool = SpoolDisplay(color: otherColor, material: otherMaterial, diameter: otherDiameter, count: 1, image: UIImage(data: otherImage as! Data)!, brand: otherBrand)
            spoolArray.append(newSpool)
//            print("uid is \(uid)")
            newSpool.addUid(uid: uid)
            uids.append(uid)
        } else {
            // don't have an image, use a placeholder
            print("add without image")
            let image = #imageLiteral(resourceName: "noun_3d printer filament_2602507")
            let newSpool = SpoolDisplay(color: otherColor, material: otherMaterial, diameter: otherDiameter, count: 1, image: image, brand: otherBrand)
            spoolArray.append(newSpool)
            newSpool.addUid(uid: uid)
            uids.append(uid)
        }
    }
}


// tableview methods
extension SpoolVC: UITableViewDelegate, UITableViewDataSource {
    // set up how many rows are in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spoolArray.count
    }
    
    // sets up a cell in the tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpoolCell", for: indexPath as IndexPath) as! SpoolTableViewCell
        
        let material = spoolArray[indexPath.row]
//        cell.textLabel?.text = teams[row]
        cell.colorLabel.text = material.color
        cell.materialLabel.text = material.material
        cell.diameterLabel.text = String(material.diameter)
        cell.countLabel.text = String(material.count)
        cell.spoolImage.image = material.image!
        cell.brandLabel.text = material.brand
        
        return cell
    }
    
    // swipe to delete, only delete if count is 1, otherwise popup alert
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // check that only 1 spool is present
            let spool = spoolArray[indexPath.row]
            print("Delete spool")
            print(spool.material)
            print(spool.uids)
            if spool.count == 1 {
                // delete from Core Data
                deleteSingleData(uid: spool.uids.first!)
                // delete from spoolArray, tableView
                spoolArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                // confirm that the user wants to delete multiple spools
                let alert = UIAlertController(title: "Are you sure?", message: "\(spool.count) spools will be deleted", preferredStyle: .alert)
                
                // Delete
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
                    self.deleteMultipleData(uids: spool.uids)
                    self.spoolArray.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }))
                
                // Cancel
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                self.present(alert, animated: true)
            }
        }
    }
    
    // Rearrange the items in tableview
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = spoolArray[sourceIndexPath.item]
        spoolArray.remove(at: sourceIndexPath.item)
        spoolArray.insert(temp, at: destinationIndexPath.item)
    }
    
    // deselects the row so it's not highlighted after click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
