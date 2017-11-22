//
//  HelpViewController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

typealias HelpLink = (title: String, url: URL?)
typealias HelpVersion = (title: String, version: String)

protocol HelpViewControllerDelegate: class {
    func help(viewController: HelpViewController, didSelectURL: URL)
    func help(viewController: HelpViewController, didTapClose: ())
}

final class HelpViewController: UIViewController {

    weak var delegate: HelpViewControllerDelegate?
    let linkCellReuseIdentifier = "linkCellReuseIdentifier"
    let versionCellReuseIdentifier = "versionCellReuseIdentifier"

    let versions: [HelpVersion] = [("GVL Version", "3.2.1"), ("App version", "0.0.1")]
    let links: [HelpLink] = [("GVL Changelog",
                              URL(string: "http://developer.gini.net/gini-vision-lib-ios/docs/changelog.html"))]

    lazy var sections: [(title: String, items: [Any])] = [("Version", self.versions), ("Links", self.links)]
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: linkCellReuseIdentifier)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: versionCellReuseIdentifier)
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 140
        }
    }
    @IBAction func close(_ sender: Any) {
        delegate?.help(viewController: self, didTapClose: ())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Help"
    }

}

// MARK: UITableViewDataSource

extension HelpViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let items = sections[indexPath.section].items
        if let links = items as? [HelpLink] {
            cell = tableView.dequeueReusableCell(withIdentifier: linkCellReuseIdentifier)
            cell?.textLabel?.text = links[indexPath.row].title
            cell?.accessoryType = .disclosureIndicator
        } else if let versions = items as? [HelpVersion] {
            cell = tableView.dequeueReusableCell(withIdentifier: versionCellReuseIdentifier)
            cell?.textLabel?.text = versions[indexPath.row].title
            cell?.detailTextLabel?.text = versions[indexPath.row].version
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
