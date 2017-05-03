//
//  SimpleActivityIndicatorRefreshView.swift
//  UKPullToRefresh
//
//  Created by Ugur Kilic on 03/05/2017.
//  Copyright © 2017 urklc. All rights reserved.
//

import UKPullToRefresh

class SimpleActivityIndicatorRefreshView: UKPullToRefreshView {

    required init() {
        super.init()

        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.startAnimating()

        addSubview(activityIndicatorView)

        let horizontalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        addConstraints([horizontalConstraint, verticalConstraint])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
