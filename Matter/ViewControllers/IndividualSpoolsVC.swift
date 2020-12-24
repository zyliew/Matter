//
//  IndividualSpoolsVC.swift
//  Matter
//
//  Created by Ziyi Liew on 17/12/20.
//

import UIKit
import CoreData

class IndividualSpoolsTableViewCell: UITableViewCell {
    @IBOutlet weak var rollNumberLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
}

class IndividualSpoolsVC: UIViewController {
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var spoolImage: UIImageView!
    @IBOutlet weak var colorAndMaterialLabel: UILabel!
    @IBOutlet weak var diameterLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var uids:[String] = []
    var spools:[IndividualSpool] = []
    
    var toPrint:ObjectDisplay?
    
    var brand = String()
    var material = String()
    var color = String()
    var diameter = Double()
    var link = String()
    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        populateCommonData()
        getCoreData()
        
        print("IndividualSpoolsVC viewDidLoad")
        if (toPrint != nil) {
            print("toPrint name is \(toPrint?.name)")
            print("toPrint weight is \(toPrint?.weight)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    // Pops up alert and presents the link to reorder
    @IBAction func Reorder(_ sender: Any) {
    }
    
}


// tableview methods
extension IndividualSpoolsVC: UITableViewDelegate, UITableViewDataSource {
    // set up how many rows are in the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spools.count
    }
    
    // sets up a cell in the tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IndividualSpoolCell", for: indexPath as IndexPath) as! IndividualSpoolsTableViewCell
        
        let material = spools[indexPath.row]
        cell.rollNumberLabel.text = String(indexPath.row + 1)
        cell.weightLabel.text = "\(material.weight)g left"
        
        return cell
    }
    
    // swipe to delete, only delete if count is 1, otherwise popup alert
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let spool = spools[indexPath.row]
            deleteSingleSpool(uid: spool.uid)
            spools.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // TODO: fix the row index, update it after deletion
        }
    }
    
    // deselects the row so it's not highlighted after click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // check that there is an item to be printed
        if toPrint != nil {
            let spool = spools[indexPath.row]
            // check that spool has enough filament left
            let newWeight = spool.weight - toPrint!.weight
            if newWeight < 0 {
                // not enough filament
                let alert = UIAlertController(title: "Warning", message: "Not enough filament to print \(toPrint!.name)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style:.cancel, handler: nil))
                self.present(alert, animated: true)
            } else {
                // enough filament, ask to confirm
                let alert = UIAlertController(title: "Print with this Spool?", message: "\(newWeight)g of filament will be left after printing \(toPrint!.name)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style:.default, handler: {action in self.printItem(spool: spool)}))
                
                alert.addAction(UIAlertAction(title: "Cancel", style:.cancel, handler: nil))
                self.present(alert, animated: true)
            }
        } else {
            // No item was selected
            let alert = UIAlertController(title: "Print", message: "Please select an item from the Items page", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style:.cancel, handler: nil))
            self.present(alert, animated: true)
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func printItem(spool: IndividualSpool) {
        // go to PrintersVC
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PrintersNavController") as? UINavigationController
        let editVC = nextViewController?.viewControllers.first as? PrintersVC
        editVC?.toPrintItem = toPrint
        editVC?.toPrintSpool = spool
        editVC?.showCancel = false
        nextViewController!.modalPresentationStyle = .fullScreen
        self.present(nextViewController!, animated:true, completion:nil)
        
        
        // pop 2 controllers back to ObjectsVC
//        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
//            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        
    }
  
}


extension IndividualSpoolsVC {
    // fills in the shared fields of the spools
    func populateCommonData() {
        spoolImage.image = image
        brandLabel.text = brand
        colorAndMaterialLabel.text = "\(color) \(material)"
        diameterLabel.text = String(diameter)
    }
    
    
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
        
        print("uids are")
        for id in uids {
            print(id)
        }
        
        // Filter and add the spools into spools
        for spool in fetchedResults! {
            let uid = spool.value(forKey: "uid") as! String
            print("spool uid is \(uid)")
            for id in uids {
                if id == uid {
                    print("match")
                    if let material = spool.value(forKey: "material") as? String,
                    let diameter = spool.value(forKey: "diameter") as? Double,
                    let color = spool.value(forKey: "color") as? String,
                    let image = spool.value(forKey: "image") as? Data,
                    let brand = spool.value(forKey: "brand") as? String,
                    let weight = spool.value(forKey: "weight") as? Double,
                    let link = spool.value(forKey: "link") as? String {
                        let newSpool = IndividualSpool(material: material, diameter: diameter, color: color, image: UIImage(data: image)!, brand: brand, uid: uid, weight: weight, link: link)
                        
                        spools.append(newSpool)
                        print("added spool")
                    }
                }
                
            }
        }
        
        print("end of getCoreData, spools has \(spools.count) spools")
    }
    
    func deleteSingleSpool(uid: String) {
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
        
        print("deleted single spool data")
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
                let updatedWeight = currentWeight - toPrint!.weight
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
