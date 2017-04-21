# UKPullToRefresh

A simple pull-to-refresh solution for UIScrollView, supports UITableView and UICollectionView.

iOS doesn't have built-in refresh control support for pulling up. This solution can be used with both pulling-up and down.

## Installation

## Carthage
To install with [Carthage](https://github.com/Carthage/Carthage), simply add this in your `Cartfile`:
```ruby
github "urklc/UKPullToRefresh"
```

## Usage

```swift
tableView.addPullToRefresh(to: .bottom) { [unowned self] () -> (Void) in
     // .....
     tableView.pullToRefreshView.state = .stopped
}
```

## Credits

A simplified and Swift based version of [SVPullToRefresh](https://github.com/samvermette/SVPullToRefresh) .

## License

MIT License
