//
// Copyright (c) 2017, Ugur Kilic
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

open class UKPullToRefreshView: UIView {

    public enum Position {
        case top, bottom
    }

    public enum State: Int {
        case stopped, triggered, loading
    }

    /// Static height for the item
    public var refreshViewHeight: CGFloat = 60.0

    /// Position of the item
    var position: Position = .top

    /// Action block to run when view is pulled
    var actionHandler: (() -> Void)?

    weak var scrollView: UIScrollView! {
        didSet {
            if let scrollView = scrollView {
                beginObserving(scrollView)

                scrollViewInitialInset = (scrollView.contentInset.top, scrollView.contentInset.bottom)
                refreshFrame()
            } else {
                endObserving(oldValue)
            }
        }
    }

    /// Initial values to reset back later

    fileprivate var initialOffset: CGPoint {
        switch position {
        case .top:
            return CGPoint(x: scrollView.contentOffset.x, y: -scrollViewInitialInset.0)
        case .bottom:
            return CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollViewInitialInset.1)
        }
    }

    fileprivate var scrollViewInitialInset: (CGFloat, CGFloat)!

    /// Current state of the view
    public var state: State = .stopped {
        didSet {
            if oldValue == state {
                return
            }

            switch state {
            case .stopped:
                resetScrollViewContentInset()

            case .loading:
                prepareScrollViewContentInsetForLoading()
                if oldValue == .triggered {
                    actionHandler?()
                }

            default:
                break
            }
        }
    }

    // MARK - Functions

    init() {
        super.init(frame: CGRect.zero)

        self.autoresizingMask = .flexibleWidth

        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.startAnimating()

        addSubview(activityIndicatorView)

        let horizontalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        addConstraints([horizontalConstraint, verticalConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func refreshFrame() {
        let yPosition = position == .top ? -refreshViewHeight : max(scrollView.contentSize.height, scrollView.bounds.size.height)
        frame = CGRect(x: 0, y: yPosition, width: scrollView.bounds.size.width, height: refreshViewHeight)

        layoutIfNeeded()
    }
}

// MARK - Observing

extension UKPullToRefreshView {

    override open func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?) {

        guard let path = keyPath,
            let change = change else {
            return
        }

        if path == #keyPath(UIScrollView.contentOffset) {
            if let value = change[.newKey] as? CGPoint {
                scrollViewDidScroll(to: value)
            }
        } else {
            refreshFrame()
        }
    }

    override open func willMove(toSuperview newSuperview: UIView?) {
        if let scrollView = self.superview as? UIScrollView {
            if newSuperview == nil {
                endObserving(scrollView)
            }
        }
    }

    func beginObserving(_ scrollView: UIScrollView) {
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: nil)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.frame), options: .new, context: nil)
    }

    func endObserving(_ scrollView: UIScrollView) {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.frame))
    }

    func scrollViewDidScroll(to contentOffset: CGPoint) {
        if state != .loading {
            var scrollOffsetThreshold: CGFloat = 0.0
            switch position {
            case .top:
                scrollOffsetThreshold = (frame.origin.y - scrollViewInitialInset.0)
            case .bottom:
                scrollOffsetThreshold = max(scrollView.contentSize.height - scrollView.bounds.size.height, 0) +
                    bounds.size.height + scrollViewInitialInset.1
            }

            if state == .triggered && !scrollView.isDragging {
                state = .loading

            } else if state != .stopped {
                let shouldStop = (contentOffset.y >= scrollOffsetThreshold && position == .top) ||
                    (contentOffset.y <= scrollOffsetThreshold && position == .bottom)
                if (shouldStop) {
                    state = .stopped
                }
            } else if self.scrollView.isDragging {
                let shouldTrigger = (contentOffset.y < scrollOffsetThreshold && position == .top) ||
                    (contentOffset.y > scrollOffsetThreshold && position == .bottom)
                if shouldTrigger {
                    state = .triggered
                }

            }
        } else {
            var  offset: CGFloat = 0.0
            var contentInset: UIEdgeInsets
            switch (self.position) {
            case .top:
                offset = max(scrollView.contentOffset.y * -1, 0.0)
                offset = min(offset, scrollViewInitialInset.0 + bounds.size.height)
                contentInset = scrollView.contentInset
                scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right)

            case .bottom:
                if (scrollView.contentSize.height >= scrollView.bounds.size.height) {
                    offset = max(scrollView.contentSize.height - scrollView.bounds.size.height + bounds.size.height, 0.0)
                    offset = min(offset, scrollViewInitialInset.1 + bounds.size.height)
                    contentInset = scrollView.contentInset
                    scrollView.contentInset = UIEdgeInsetsMake(contentInset.top, contentInset.left, offset, contentInset.right)
                }
            }
        }
    }
}

// MARK - ScrollView offset

extension UKPullToRefreshView {

    func resetScrollViewContentInset() {
        var currentInset = scrollView.contentInset
        currentInset.top = CGFloat(scrollViewInitialInset.0)
        if position == .bottom {
            currentInset.bottom = CGFloat(scrollViewInitialInset.1)
        }
        setScrollViewContentInsetAnimated(currentInset)
    }

    func prepareScrollViewContentInsetForLoading() {
        var currentInset = scrollView.contentInset
        let initialInset = position == .top ? scrollViewInitialInset.0 : scrollViewInitialInset.1

        let offset = max(-1 * scrollView.contentOffset.y, 0)
        currentInset.top = min(offset, initialInset + bounds.size.height)
        setScrollViewContentInsetAnimated(currentInset)
    }

    func setScrollViewContentInsetAnimated(_ inset: UIEdgeInsets) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options:[.allowUserInteraction, .beginFromCurrentState],
                       animations: { [unowned self] in self.scrollView?.contentInset = inset },
                       completion: nil)
    }
}
