//
//  AddSpoolVC.swift
//  Matter
//
//  Created by Ziyi Liew on 16/12/20.
//

import UIKit
import CoreData

class AddSpoolVC: UIViewController {
    @IBOutlet weak var quantityTextBox: UITextField!
    @IBOutlet weak var materialTextBox: UITextField!
    @IBOutlet weak var colorTextBox: UITextField!
    @IBOutlet weak var weightTextBox: UITextField!
    @IBOutlet weak var diameterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var purchaseLinkTextBox: UITextField!
    @IBOutlet weak var remarksTextBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getData()
//        clearCoreData()
    }
    

    @IBAction func storeSpoolData(_ sender: Any) {
        
        
        if checkInputs() {
            addToCoreData()
            getData()
            
        
        } else {
            print("Bad input data")
        }
        
        
    }
    
    func checkInputs() -> Bool {
        // check for empty inputs
        if quantityTextBox.text!.isEmpty || materialTextBox.text!.isEmpty || colorTextBox.text!.isEmpty || weightTextBox.text!.isEmpty {
            return false
        }
        
        // check if inputs are the appropriate type
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        if quantityTextBox.text!.rangeOfCharacter(from: numberCharacters) != nil || weightTextBox.text!.rangeOfCharacter(from: numberCharacters) != nil {
            return false
        }
        
        return true
    }
    
    func addToCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let toAddQuantity = Int(quantityTextBox.text!) ?? 0
        for _ in 1...toAddQuantity {
            let spool = NSEntityDescription.insertNewObject(
                forEntityName: "Spool", into:context)
            

            spool.setValue(materialTextBox.text, forKey: "material")
            spool.setValue(colorTextBox.text, forKey: "color")
            spool.setValue(Int(weightTextBox.text!), forKey: "weight")
            spool.setValue(UUID().uuidString, forKey: "uid")
            spool.setValue(purchaseLinkTextBox.text, forKey: "link")
            spool.setValue(remarksTextBox.text, forKey: "remarks")
            switch diameterSegmentedControl.selectedSegmentIndex {
            case 0:
                spool.setValue(1.75, forKey: "diameter")
            case 1:
                spool.setValue(2.85, forKey: "diameter")
            default:
                break
            }
            
            // TODO: image
            
            // Commit the changes
            do {
                try context.save()
            } catch {
                // if an error occurs
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func getData() {
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
            if let color = spool.value(forKey: "color"),
               let diameter = spool.value(forKey: "diameter"),
               let link = spool.value(forKey: "link"),
               let material = spool.value(forKey: "material"),
               let remarks = spool.value(forKey: "remarks"),
               let uid = spool.value(forKey: "uid"),
               let weight = spool.value(forKey: "weight") {
                print("Color: \(color), Diameter: \(diameter), Link: \(link), Material: \(material), Remarks: \(remarks), UID: \(uid), Weight: \(weight)")
            }
        }
    }
    
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
                    print("\(result.value(forKey:"uid")!) has been deleted")
                }
            }
            try context.save()
            
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        
    }
    

}
