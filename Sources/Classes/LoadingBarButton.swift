//
//  Copyright (c) 2018 Touch Instinct
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the Software), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import RxSwift
import RxCocoa

/// Side to which activity indicator applied
public enum LoadingBarButtonSide {
    case left
    case right
}

/// Workaround with navigationBarButton, that can change state (UI) into activity indicator
public class LoadingBarButton {

    fileprivate weak var navigationItem: UINavigationItem?
    fileprivate var initialBarButton: UIBarButtonItem?
    private let side: LoadingBarButtonSide

    private var barButtonItem: UIBarButtonItem? {
        get {
            switch side {
            case .left:
                return navigationItem?.leftBarButtonItem

            case .right:
                return navigationItem?.rightBarButtonItem
            }
        }
        set {
            switch side {
            case .left:
                navigationItem?.leftBarButtonItem = newValue

            case .right:
                navigationItem?.rightBarButtonItem = newValue
            }
        }
    }

    /**
     Create an instance of LoadingBarButton
     
     - Parameters:
       - navigationItem: item to which apply changes
       - side: side where navigationItem would be placed
     */
    public init(navigationItem: UINavigationItem, side: LoadingBarButtonSide) {
        self.navigationItem = navigationItem
        self.side = side
        initialBarButton = barButtonItem
    }

    fileprivate func setState(waiting: Bool = false) {
        if waiting {
            let activityIndicatorItem = UIBarButtonItem.activityIndicator
            barButtonItem = activityIndicatorItem.barButton
            activityIndicatorItem.activityIndicator.startAnimating()
        } else {
            barButtonItem = initialBarButton
        }
    }
}

public extension Observable {

    /**
     Reactive extension for LoadingBarButton
     Apply transformations on subscribe and on dispose events
     
     - Parameters:
       - barButton: LoadingBarButton instance to which transformations would applied
     - Returns:
       - observable, that handles LoadingBarButton behaviour
     */
    func changeLoadingUI(using barButton: LoadingBarButton) -> Observable<Observable.E> {
        return observeOn(MainScheduler.instance)
            .do(onSubscribe: {
                barButton.setState(waiting: true)
            }, onDispose: {
                barButton.setState(waiting: false)
            })
    }
}
