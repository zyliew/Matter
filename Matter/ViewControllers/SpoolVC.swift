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

let spoolArray = [
    Sanity(material: "PLA", diameter: 2.85, count: 1, color: "Blue"),
    Sanity(material: "ABS", diameter: 1.75, count: 3, color: "Black")
]

class SpoolTableViewCell: UITableViewCell {
    @IBOutlet weak var spoolImage: UIImageView!
    @IBOutlet weak var materialLabel: UILabel!
    @IBOutlet weak var diameterLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    
}

class SpoolVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }

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
        
        return cell
    }
    
    // deselects the row so it's not highlighted after click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}



