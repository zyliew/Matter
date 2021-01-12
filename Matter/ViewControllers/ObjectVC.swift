//
//  ObjectVC.swift
//  Matter
//
//  Created by Ziyi Liew on 19/12/20.
//

import UIKit
import CoreData

// Struct to pass print info to SpoolVC
//struct PrintItem {
//    var name:String
//    var weight:Double
//}
protocol ObjectTableViewCellDelegate {
    func tappedEdit(name: String, weight: Double, row: Int)
}

// Custom TableView cell
class ObjectTableViewCell: UITableViewCell {
    var delegate:ObjectTableViewCellDelegate?
    @IBOutlet weak var objectImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    var objectRow:Int?
    
    @IBAction func editPressed(_ sender: Any) {
        delegate?.tappedEdit(name: nameLabel.text!, weight: Double(weightLabel.text!)!, row: objectRow!)
    }
}
    
class ObjectVC: UIViewController {
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var objectArray:[ObjectDisplay] = []
//    var itemArray:[PrintItem] = []
    var row = Int()
    
    // variables to pass to SpoolVC

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "Objects"
        
        // hide the nav bar edit button, don't think we need it. Delete when ready
        editButton.isHidden = true
//        clearCoreData()
        getCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    // change edit text when pressed, set tableview editing priviledges
    @IBAction func editPressed(_ sender: Any) {
        self.tableView.isEditing = !self.tableView.isEditing
        let text = (self.tableView.isEditing) ? "Done" : "Edit"
        editButton.setTitle(text, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addModelSegue",
           let nextVC = segue.destination as? AddObjectVC {
            print("going to addModelSegue")
            nextVC.delegate = self
            nextVC.objects = objectArray
        } else if segue.identifier == "printButtonSegue" {
            print("printButtonSegue")
            
            let nextVC = segue.destination as? SpoolVC
            let item = objectArray[row]
            nextVC?.toPrint = item
            nextVC?.showCancel = false
            nextVC?.hidesBottomBarWhenPushed = true
            
        }
    }
}

extension ObjectVC: passObjects {
    func updateArray(object: [ObjectDisplay]) {
        objectArray = object
    }
}

// tableview methods
extension ObjectVC: UITableViewDelegate, UITableViewDataSource {
    // set up how many rows are in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectArray.count
    }
    
    // sets up a cell in the tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath as IndexPath) as! ObjectTableViewCell
        
        let item = objectArray[indexPath.row]
        cell.objectImage.image = item.image!
        cell.nameLabel.text = item.name
        cell.weightLabel.text = String(item.weight)
        cell.objectImage.image = item.image
        cell.delegate = self
        cell.objectRow = indexPath.row
        
        return cell
    }
    
    // swipe to delete, only delete if count is 1, otherwise popup alert
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // check that only 1 spool is present
            let item = objectArray[indexPath.row]
            let name = item.name
            print("Delete object")
            print(name)
            
            // confirm that the user wants to delete multiple spools
            let alert = UIAlertController(title: "Are you sure?", message: "\(name) spools will be deleted", preferredStyle: .alert)
            
            // Delete
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
                self.deleteSingleObject(uid: item.uid)
                self.objectArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            
            // Cancel
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }
    }
    
    // Rearrange the items in tableview
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = objectArray[sourceIndexPath.item]
        objectArray.remove(at: sourceIndexPath.item)
        objectArray.insert(temp, at: destinationIndexPath.item)
    }
    
    // deselects the row so it's not highlighted after click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        row = indexPath.row
        return indexPath
    }
}

extension ObjectVC: ObjectTableViewCellDelegate {
    
    // pops up an alert and updates the object's name and weight
    func tappedEdit(name: String, weight: Double, row: Int) {
        print("implement alert")
        print("name is \(name), weight is \(weight)")
        var editName:UITextField?
        var editWeight:UITextField?
        
//        var updatedName:String
//        var updatedWeight:Double

        let alert = UIAlertController(
            title: "Edit", message: nil,
                preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(nameTextField) in
            editName = nameTextField
            editName?.text = name
        })
        alert.addTextField(configurationHandler: {(weightTextField) in
            editWeight = weightTextField
            editWeight?.keyboardType = .decimalPad
            editWeight?.text = String(weight)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler:{ action in
            self.updateInfo(originalName: name, updatedName: editName!.text!, weight: Double(editWeight!.text!)!)
            DispatchQueue.main.async { self.tableView.reloadData() }
        }))

        self.present(alert, animated: true)
        
    }
    
    // updates this object's name and weight in objectArray and core data
    func updateInfo(originalName: String, updatedName: String, weight: Double) {
        // retrive the object from objectArray and update
        for target in objectArray {
            if target.name == originalName {
                target.name = updatedName
                target.weight = weight
                break
            }
        }
        
        updateSingleObject(originalName: originalName, updatedName: updatedName, weight: weight)
    }
}

extension ObjectVC {
    func getCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
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
            let weight = object.value(forKey: "weight") as! Double
            let image = object.value(forKey: "image") as! Data
            let uid = object.value(forKey: "uid") as! String
            
            objectArray.append(ObjectDisplay(name: name, weight: weight, image: UIImage(data: image)!, uid: uid))
//            itemArray.append(PrintItem(name: name, weight: weight))
        }
    }
    
    func updateSingleObject(originalName: String, updatedName: String, weight: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        var fetchedResults: [NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        for object in fetchedResults! {
            let currentName = object.value(forKey: "name") as? String
            if currentName == originalName {
                print("modified object in updateSingleObject")
                object.setValue(updatedName, forKey: "name")
                object.setValue(weight, forKey: "weight")
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
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
    
    func deleteSingleObject(uid: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                // find spools with the matching uid and delete it
                for result:AnyObject in fetchedResults {
                    let currentUid = result.value(forKey: "uid") as! String
                    if uid == currentUid {
                        context.delete(result as! NSManagedObject)
                        print("Object with uid: \(uid) deleted from Core Data")
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
