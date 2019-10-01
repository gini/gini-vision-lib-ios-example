//
//  HelpViewController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/21/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit
import GiniVision
import Gini

typealias HelpLink = (title: String, url: URL?)
typealias HelpKeyValueItem = (title: String, version: String)

enum HelpAction {
    case resetToDefaults, apiSelection
    
    var title: String {
        switch self {
        case .resetToDefaults: return "Reset to default settings"
        case .apiSelection: return ""
        }
    }
}

protocol HelpViewControllerDelegate: class {
    func help(viewController: HelpViewController, didSelectLink link: HelpLink)
    func help(viewController: HelpViewController, didTapClose: ())
}

final class HelpViewController: UIViewController {
    weak var delegate: HelpViewControllerDelegate?
    let linkCellReuseIdentifier = "linkCellReuseIdentifier"
    let versionCellReuseIdentifier = "versionCellReuseIdentifier"
    let othersCellReuseIdentifier = "othersCellReuseIdentifier"
    var selectedAPIDomain: APIDomain
    let credentials: [HelpKeyValueItem] = {
        let credentials = CredentialsHelper.fetchCredentials()
        let password = credentials.password == nil ? "" : "******"
        
        return [("Id", credentials.id ?? ""), ("Password", password)]
    }()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: linkCellReuseIdentifier)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: versionCellReuseIdentifier)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: othersCellReuseIdentifier)
            tableView.register(APISelectionTableViewCell.self,
                               forCellReuseIdentifier: APISelectionTableViewCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
        }
    }
    
    // Data source
    let versions: [HelpKeyValueItem] = [("GVL Version", AppVersion.gvlVersion),
                                   ("API SDK Version", AppVersion.apisdkVersion)]

    let links: [HelpLink] = [("GVL Changelog",
                              URL(string: "http://developer.gini.net/gini-vision-lib-ios/docs/changelog.html")),
                             ("GVL Readme",
                              URL(string: "http://developer.gini.net/gini-vision-lib-ios/docs/index.html"))]
    

    lazy var sections: [(title: String, items: [Any])] = [("Version", self.versions),
                                                          ("Gini client", self.credentials),
                                                          ("Links", self.links),
                                                          ("API", [HelpAction.apiSelection]),
                                                          ("Others", [HelpAction.resetToDefaults])]
    


    init(selectedAPIDomain: APIDomain) {
        self.selectedAPIDomain = selectedAPIDomain
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func close(_ sender: Any) {
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

// MARK: - UITableViewDataSource

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
        } else if let versions = items as? [HelpKeyValueItem] {
            cell = UITableViewCell(style: .value1, reuseIdentifier: versionCellReuseIdentifier)
            cell?.textLabel?.text = versions[indexPath.row].title
            cell?.detailTextLabel?.text = versions[indexPath.row].version
        } else if let others = items as? [HelpAction] {
            let item = others[indexPath.row]
            switch item {
            case .resetToDefaults:
                cell = UITableViewCell(style: .value1, reuseIdentifier: versionCellReuseIdentifier)
                cell?.textLabel?.text = item.title
                cell?.textLabel?.textColor = .red
            case .apiSelection:
                let cell = tableView.dequeueReusableCell(withIdentifier: APISelectionTableViewCell.identifier,
                                                         for: indexPath) as? APISelectionTableViewCell
                cell?.control.selectedSegmentIndex = selectedAPIDomain == .default ? 0 : 1
                cell?.control.addTarget(self, action: #selector(apiSelectionDidChange), for: .valueChanged)
                return cell!
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    @objc func apiSelectionDidChange(_ sender: UISegmentedControl) {
        selectedAPIDomain = sender.selectedSegmentIndex == 0 ? .default : .accounting
    }
}

// MARK: - UITableViewDelegate

extension HelpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let items = sections[indexPath.section].items
        if let links = items as? [HelpLink] {
            delegate?.help(viewController: self, didSelectLink: links[indexPath.row])
        } else if let others = items as? [HelpAction] {
            switch others[indexPath.row] {
            case .resetToDefaults:
                UserDefaults().removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            default: break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let item = sections[indexPath.section].items[indexPath.row]
        if case HelpAction.resetToDefaults = item {
            return true
        }
        
        return item is HelpLink
    }
}

// MARK: - APISelectionTableViewCell

final class APISelectionTableViewCell: UITableViewCell {
    static let identifier = "APISelectionTableViewCell"
    
    lazy var control: UISegmentedControl = {
        let control = UISegmentedControl(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.insertSegment(withTitle: "Default", at: 0, animated: false)
        control.insertSegment(withTitle: "Accounting", at: 1, animated: false)
        control.selectedSegmentIndex = 0
        control.tintColor = .giniBlue
        
        return control
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(control)
        
        control.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        control.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        control.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        control.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
