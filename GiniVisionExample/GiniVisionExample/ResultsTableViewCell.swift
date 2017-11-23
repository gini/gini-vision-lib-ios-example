//
//  ResultsTableViewCell.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/23/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

protocol ResultsTableViewCellDelegate: class {
    func results(tableViewCell: ResultsTableViewCell,
                 atIndexPath indexPath: IndexPath,
                 didChangeFieldValue fieldValue: String?)
}

final class ResultsTableViewCell: UITableViewCell {

    weak var delegate: ResultsTableViewCellDelegate?
    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var fieldValue: UITextField!
    
    @IBAction func changedValue(_ sender: UITextField) {
        delegate?.results(tableViewCell: self, atIndexPath: indexPath, didChangeFieldValue: sender.text)
    }
    
    var indexPath: IndexPath!
}
