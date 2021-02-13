//
//  PrintJobsVC.swift
//  Matter
//
//  Created by Ziyi Liew on 23/12/20.
//

import UIKit

// TODO: retrieve both completed and not completed printing items in this VC, pass to child VCs
// set up delegate to retrive the information back from childVCs if arrays are updated

class PrintJobsVC: UIViewController {
    @IBOutlet weak var printingView: UIView!
    @IBOutlet weak var completedView: UIView!
    @IBOutlet weak var viewSegmentControl: UISegmentedControl!
    
    var printer:PrinterDisplay?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Note, hiding the entire segmented view, printingView for now
        // until active tableView refresh can be implemented
//        setView(view: printingView, hidden: false)
//        setView(view: completedView, hidden: true)
        setView(view: completedView, hidden: false)
        setView(view: printingView, hidden: true)
        viewSegmentControl.isHidden = true
        
        print("printer is \(printer!.name)")
    }
    
    @IBAction func toggleSegmentedController(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // PrintingView
            setView(view: printingView, hidden: false)
            setView(view: completedView, hidden: true)
//            performSegue(withIdentifier: "toIndividualPrintingSegue", sender: nil)
        case 1:
            // CompletedView
            setView(view: printingView, hidden: true)
            setView(view: completedView, hidden: false)
//            performSegue(withIdentifier: "toIndividualCompletedSegue", sender: nil)
        default:
            // Shouldn't hit here
            print("hit default case of toggleSegmentedController")
            setView(view: printingView, hidden: false)
            setView(view: completedView, hidden: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toIndividualPrintingSegue", let nextVC = segue.destination as? IndividualPrintingVC {
            print("individualPrinting segue")
            nextVC.printer = printer
        } else if segue.identifier == "toIndividualCompletedSegue", let nextVC = segue.destination as? IndividualCompletedVC {
            print("completedSegue")
            nextVC.printer = printer
        }

    }
}

extension PrintJobsVC {
    // animation helper function to hide/show views
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
}
