//
//  ResultsViewController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

typealias Results = (title: String, items: [(name: String, value: String)])

final class ResultsViewController: UIViewController {
    
    var sections: [Results] = [("Section 0", [("item 1", "value 1"), ("item 2", "value 1")])]
    var resultsTableCellIdentifier = "ResultsTableCellIdentifier"
    var isEditModeEnabled = false

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.allowsSelection = false
            tableView.register(UINib(nibName: "ResultsTableViewCell", bundle: nil),
                               forCellReuseIdentifier: resultsTableCellIdentifier)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        
    }
    
    @IBAction func edit(_ sender: Any) {
        isEditModeEnabled = !isEditModeEnabled
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension ResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: resultsTableCellIdentifier,
                                                 for: indexPath) as? ResultsTableViewCell
        cell?.fieldName.text = sections[indexPath.section].items[indexPath.row].name
        cell?.fieldValue.text = sections[indexPath.section].items[indexPath.row].value
        cell?.fieldValue.isEnabled = isEditModeEnabled

        return cell!
    }
}
