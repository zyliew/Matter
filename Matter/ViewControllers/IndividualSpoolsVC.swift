//
//  IndividualSpoolsVC.swift
//  Matter
//
//  Created by Ziyi Liew on 17/12/20.
//

import UIKit

class IndividualSpoolsTableViewCell: UITableViewCell {
    @IBOutlet weak var rollNumberLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
}

class IndividualSpoolsVC: UIViewController {
    @IBOutlet weak var spoolImage: UIImageView!
    @IBOutlet weak var colorAndMaterialLabel: UILabel!
    @IBOutlet weak var diameterLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var spoolList: [String] = []
    var material = String()
    var color = String()
    var diameter = Int()
    var link = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
