//
//  ResultsViewController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

protocol ResultsViewControllerDelegate: class {
    func results(viewController: ResultsViewController, didTapDone: ())
}

final class ResultsViewController: UIViewController {
    
    weak var delegate: ResultsViewControllerDelegate?
    let model: ResultsViewModelProtocol
    var resultsTableCellIdentifier = "ResultsTableCellIdentifier"
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.allowsSelection = false
            tableView.register(UINib(nibName: "ResultsTableViewCell", bundle: nil),
                               forCellReuseIdentifier: resultsTableCellIdentifier)
        }
    }
    
    @IBAction func done(_ sender: Any) {
        model.sendFeedBack()
        delegate?.results(viewController: self, didTapDone: ())
    }
    
    init(model: ResultsViewModelProtocol) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITableViewDataSource

extension ResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: resultsTableCellIdentifier,
                                                 for: indexPath) as? ResultsTableViewCell
        cell?.fieldName.text = model.sections[indexPath.section].items[indexPath.row].name
        cell?.fieldValue.text = model.sections[indexPath.section].items[indexPath.row].value
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
        model.updateExtraction(at: indexPath, withValue: fieldValue)
    }
}
