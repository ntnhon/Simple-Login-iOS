//
//  AboutViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import MessageUI
import UIKit

final class AboutViewController: BaseLeftMenuButtonViewController, Storyboarded {
    @IBOutlet private weak var tableView: UITableView!

    var openFromLoginViewController = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        GeneralInfoTableViewCell.register(with: tableView)
        HowAndSecurityTableViewCell.register(with: tableView)
        WhatAndFaqTableViewCell.register(with: tableView)
        TeamAndBlogTableViewCell.register(with: tableView)
        PricingAndBlogTableViewCell.register(with: tableView)
        HelpAndRoadmapTableViewCell.register(with: tableView)
        TermsAndPrivacyTableViewCell.register(with: tableView)

        // Don't show hamburger button when this controller is open from LoginViewController
        if openFromLoginViewController {
            navigationItem.leftBarButtonItem = nil
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let webViewController as WebViewController:

            switch segue.identifier {
            case "showTeam": webViewController.module = .team
            case "showPricing": webViewController.module = .pricing
            case "showBlog": webViewController.module = .blog
            case "showTerms": webViewController.module = .terms
            case "showPrivacy": webViewController.module = .privacy
            case "showSecurity": webViewController.module = .security
            case "showHelp": webViewController.module = .help
            default: return
            }

        default: return
        }
    }
}

// MARK: - UITableViewDataSource
extension AboutViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }

    // swiftlint:disable:next function_body_length
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return GeneralInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

        case 1:
            let cell = HowAndSecurityTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

            cell.didTapHowItWorksLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showHow", sender: nil)
            }

            cell.didTapSecurityLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showSecurity", sender: nil)
            }

            return cell

        case 2:
            let cell = WhatAndFaqTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

            cell.didTapWhatLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showWhat", sender: nil)
            }

            cell.didTapFaqLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showFaq", sender: nil)
            }

            return cell

        case 3:
            let cell = TeamAndBlogTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

            cell.didTapTeamLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showTeam", sender: nil)
            }

            cell.didTapBlogLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showBlog", sender: nil)
            }

            return cell

        case 4:
            let cell = HelpAndRoadmapTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

            cell.didTapHelpLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showHelp", sender: nil)
            }

            cell.didTapRoadmapLabel = {
                guard let url = URL(string: "https://trello.com/b/4d6A69I4/open-roadmap") else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }

            return cell

        case 5:
            let cell = TermsAndPrivacyTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

            cell.didTapTermsLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showTerms", sender: nil)
            }

            cell.didTapPrivacyLabel = { [unowned self] in
                self.performSegue(withIdentifier: "showPrivacy", sender: nil)
            }

            return cell

        default: return UITableViewCell()
        }
    }
}
