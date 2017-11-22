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
    func help(viewController: HelpViewController, didSelectItem item: HelpLink)
    func help(viewController: HelpViewController, didTapClose: ())
}

final class HelpViewController: UIViewController {

    weak var delegate: HelpViewControllerDelegate?
    let linkCellReuseIdentifier = "linkCellReuseIdentifier"
    let versionCellReuseIdentifier = "versionCellReuseIdentifier"

    let versions: [HelpVersion] = [("GVL Version", "3.2.1"), ("App version", "0.0.1")]
    let links: [HelpLink] = [("GVL Changelog",
                              URL(string: "http://developer.gini.net/gini-vision-lib-ios/docs/changelog.html")),
                             ("GVL Readme",
                              URL(string: "http://developer.gini.net/gini-vision-lib-ios/docs/index.html"))]

    lazy var sections: [(title: String, items: [Any])] = [("Version", self.versions), ("Links", self.links)]
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: linkCellReuseIdentifier)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: versionCellReuseIdentifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
        }
    }
    
    func close(_ sender: Any) {
        delegate?.help(viewController: self, didTapClose: ())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("help.screen.title", comment: "help screen title for navigation bar")
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: NSLocalizedString("help.screen.close.button",
                                                     comment: "help screen title for navigation bar"),
                            style: .done,
                            target: self, action: #selector(close(_:)))
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
            cell = UITableViewCell(style: .value1, reuseIdentifier: versionCellReuseIdentifier)
            cell?.textLabel?.text = versions[indexPath.row].title
            cell?.detailTextLabel?.text = versions[indexPath.row].version
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: UITableViewDelegate

extension HelpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let items = sections[indexPath.section].items
        if let links = items as? [HelpLink] {
            delegate?.help(viewController: self, didSelectItem: links[indexPath.row])
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let items = sections[indexPath.section].items
        return items is [HelpLink]
    }
}
