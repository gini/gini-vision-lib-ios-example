//
//  ResultsViewController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

typealias Results = (title: String, items: [(name: String, value: String)])

protocol ResultsViewControllerDelegate: class {
    func results(viewController: ResultsViewController, didTapClose: ())
}

final class ResultsViewController: UIViewController {
    
    weak var delegate: ResultsViewControllerDelegate?
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
        delegate?.results(viewController: self, didTapClose: ())
    }
    
    @IBAction func edit(_ sender: Any) {
        isEditModeEnabled = !isEditModeEnabled
        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource

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
        cell?.delegate = self
        cell?.indexPath = indexPath

        return cell!
    }
}

// MARK: ResultsTableViewCellDelegate

extension ResultsViewController: ResultsTableViewCellDelegate {
    func results(tableViewCell: ResultsTableViewCell,
                 atIndexPath indexPath: IndexPath,
                 didChangeFieldValue fieldValue: String?) {
        sections[indexPath.section].items[indexPath.row].value = fieldValue ?? ""
    }
}
