//
//  ObjectVC.swift
//  Matter
//
//  Created by Ziyi Liew on 19/12/20.
//

import UIKit
import CoreData

// pass objectArray between ObjectVC and AddObjectVC
protocol ObjectTableViewCellDelegate {
    func printObject(name: String, weight: Double)
}

// Custom TableView cell
class ObjectTableViewCell: UITableViewCell {
    var delegate: ObjectTableViewCellDelegate?
    
    @IBOutlet weak var objectImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    var name:String?
    var weight:Double?
    
    @IBAction func printObject(_ sender: Any) {
        delegate?.printObject(name: name!, weight: weight!)
    }
}

class ObjectVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var objectArray:[ObjectDisplay] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
//        clearCoreData()
        getCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addModelSegue",
           let nextVC = segue.destination as? AddObjectVC {
            nextVC.delegate = self
            nextVC.objects = objectArray
        }
    }
}

extension ObjectVC: passObjects {
    func updateArray(object: [ObjectDisplay]) {
        objectArray = object
    }
}

// tableview methods
extension ObjectVC: UITableViewDelegate, UITableViewDataSource, ObjectTableViewCellDelegate {
    func printObject(name: String, weight: Double) {
        print("printing \(name) with weight \(weight)")
    }
    
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
        cell.name = item.name
        cell.weight = item.weight
        cell.delegate = self
        
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
                self.deleteSingleObject(name: name)
                self.objectArray.remove(at: indexPath.row)
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
            
            objectArray.append(ObjectDisplay(name: name, weight: weight, image: UIImage(data: image)!))
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
    
    func deleteSingleObject(name: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
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
}
