//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization
import UIKit

public protocol SettingsViewControllerInteracting {
    func didTapLanguage()
    func didTapManageMyData()
}

public class SettingsViewController: UITableViewController {
    public typealias Interacting = SettingsViewControllerInteracting
    
    public class ViewModel {
        @InterfaceProperty
        var language: String
        
        public init() {
            _language = .constant(
                SupportedLanguage.getLanguageTermsFrom(
                    localeIdentifier: currentLocaleIdentifier()
            )?.exonym ?? localize(.settings_language_en))
        }
    }
    
    private struct Section {
        var rows: [Row]
    }
    
    private enum Row {
        case language(InterfaceProperty<String>)
        case manageMyData
    }
    
    private var content: [Section] {
        let languageRow = Row.language(viewModel.$language)
        let manageMyDataRow = Row.manageMyData
        let section = Section(rows: [languageRow, manageMyDataRow])
        return [section]
    }
    
    private let viewModel: ViewModel
    private let interacting: Interacting
    
    public init(viewModel: ViewModel, interacting: Interacting) {
        self.viewModel = viewModel
        self.interacting = interacting
        super.init(style: .plain)
        title = localize(.settings_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        view.styleAsScreenBackground(with: traitCollection)
        tableView.tableFooterView = UIView()
        clearsSelectionOnViewWillAppear = true
        
        tableView.register(LanguageCell.self, forCellReuseIdentifier: LanguageCell.reuseIdentifier)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: UITableViewCell
        switch content[indexPath.section].rows[indexPath.row] {
        case .language(let language):
            cell = LanguageCell.create(tableView: tableView, language: language)
        case .manageMyData:
            cell = TextCell.create(tableView: tableView, title: localize(.settings_row_manage_my_data_title), subtitle: localize(.settings_row_manage_my_data_subtitle))
        }
        return cell
    }
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return content.count
    }
    
    override public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return content[section].rows.count
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch content[indexPath.section].rows[indexPath.row] {
        case .language: interacting.didTapLanguage()
        case .manageMyData: interacting.didTapManageMyData()
        }
    }
}
