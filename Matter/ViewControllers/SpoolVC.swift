//
//  SpoolVC.swift
//  Matter
//
//  Created by Ziyi Liew on 15/12/20.
//

import UIKit
import CoreData

struct Sanity {
    var material:String
    var diameter:Double
    var count:Int
    var color:String
}


class SpoolTableViewCell: UITableViewCell {
    @IBOutlet weak var spoolImage: UIImageView!
    @IBOutlet weak var materialLabel: UILabel!
    @IBOutlet weak var diameterLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    
}

var spoolArray:[SpoolDisplay] = []
var uids:[String] = []

class SpoolVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
//        clearCoreData()
        getCoreData()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        getCoreData()
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

}

extension SpoolVC {
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
        
        for spool in fetchedResults! {
            checkAndAdd(compare: spool)
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
//                    print("\(result.value(forKey:"uid")!) has been deleted")
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
    
    // checks if spool is already in the spoolArray, add or increment count accordingly
    func checkAndAdd(compare: NSManagedObject) {
//        print("check and add")
        let otherColor = compare.value(forKey: "color") as! String
        let otherDiameter = compare.value(forKey: "diameter") as! Double
        let otherMaterial = compare.value(forKey: "material") as! String
        let uid = compare.value(forKey: "uid") as! String
//        print("otherColor: \(otherColor), otherDiameter: \(otherDiameter), otherMaterial: \(otherMaterial)")
        
        for spool in spoolArray {
            let color = spool.color
            let diameter = spool.diameter
            let material = spool.material
//            print("color: \(color), diameter: \(diameter), material: \(material), uid: \(uid)")
//            print("uids \(uids)")
            
            if color == otherColor && diameter == otherDiameter && material == otherMaterial {
                if uids.contains(uid) { return }
                // already in spoolArray, increment count
//                print("material already in spoolArray")
                spool.count += 1
                uids.append(uid)
                return
            }
        }
        
        // new material, add to spoolArray
        if let otherImage = compare.value(forKey: "image") {
//            print("add to spoolArray")
            spoolArray.append(SpoolDisplay(color: otherColor, material: otherMaterial, diameter: otherDiameter, count: 1, image: UIImage(data: otherImage as! Data)!))
//            print("uid is \(uid)")
            uids.append(uid)
        } else {
            // TODO
            // don't have an image, use a placeholder
            print("hit else")
            let image = #imageLiteral(resourceName: "noun_3d printer filament_2602507")
            spoolArray.append(SpoolDisplay(color: otherColor, material: otherMaterial, diameter: otherDiameter, count: 1, image: image))
        }
    }
}



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
        
        return cell
    }
    
    // deselects the row so it's not highlighted after click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
