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
    
    @objc func done(_ sender: Any) {
        model.sendFeedBack()
        delegate?.results(viewController: self, didTapDone: ())
    }
    
    init(model: ResultsViewModelProtocol) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        title = NSLocalizedString("results.screen.title", comment: "results screens title")
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("done", comment: "fertig"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(done(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITableViewDataSource

extension ResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.extractions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.extractions[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: resultsTableCellIdentifier,
                                                 for: indexPath) as? ResultsTableViewCell
        cell?.fieldName.text = model.extractions[indexPath.section].items[indexPath.row].name
        cell?.fieldValue.text = model.extractions[indexPath.section].items[indexPath.row].value
        cell?.delegate = self
        cell?.indexPath = indexPath
        
        let fontSize: CGFloat = indexPath.section == 0 ? 20.0 : 16.0
        cell?.fieldName.font = cell?.fieldName.font.withSize(fontSize)

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
