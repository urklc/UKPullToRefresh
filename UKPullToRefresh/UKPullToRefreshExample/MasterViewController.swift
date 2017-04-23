//
//  MasterViewController.swift
//  UKPullToRefreshExample
//
//  Created by Ugur Kilic on 23/04/2017.
//  Copyright © 2017 urklc. All rights reserved.
//

import UIKit

enum UKPullToRefreshExample: Int {
    case simple

    func description() -> String {
        switch self {
        case .simple:
            return "Simple Activity Indicator"
        }
    }
}

class MasterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var examples: [UKPullToRefreshExample] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        var i = 0
        repeat {
            if let item = UKPullToRefreshExample(rawValue: i) {
                examples.append(item)
                i += 1
            } else {
                break
            }
        } while (true)
    }
}

extension MasterViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = examples[indexPath.row].description()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        viewController.example = examples[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

