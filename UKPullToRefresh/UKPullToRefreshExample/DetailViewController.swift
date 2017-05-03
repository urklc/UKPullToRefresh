//
//  DetailViewController.swift
//  UKPullToRefreshExample
//
//  Created by Ugur Kilic on 23/04/2017.
//  Copyright © 2017 urklc. All rights reserved.
//

import UIKit
import UKPullToRefresh

class DetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var example: UKPullToRefreshExample!
    var items = ["Lorem", "Ipsum" , "Dolor", "Sit", "Amet", "Consectetur", "Adipiscing", "Elit"]
    var appendedItems = ["Lorem", "Ipsum", "Dolor"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        tableView.tableFooterView = UIView()

        tableView.addPullToRefresh(
            to: .bottom,
            type: example.viewType) { [unowned self] () -> (Void) in
                self.items.append(contentsOf: self.appendedItems)

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

                    func appendedIndexPaths() -> [IndexPath] {
                        let itemCount = self.items.count
                        var indexPaths: [IndexPath] = []
                        for i in itemCount - self.appendedItems.count...itemCount - 1 {
                            indexPaths.append(IndexPath(row: i, section: 0))
                        }
                        return indexPaths
                    }

                    self.tableView.insertRows(at: appendedIndexPaths(), with: .automatic)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tableView.pullToRefreshView.state = .stopped
                    }
                }
        }
    }
}

extension DetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = items[indexPath.row]
        
        return cell
    }
}
