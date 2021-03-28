//
//  Created by Rob Nash on 05/04/2019.
//  Copyright © 2019 Nash Property Solutions Ltd. All rights reserved.
//

import UIKit

final class SlideViewController: ParentViewController {
    
    enum Animation {
        case slideRight, slideLeft
        init(_ animation: Sheet.Animation) {
            switch animation {
            case .slideRight:
                self = .slideRight
            default:
                self = .slideLeft
            }
        }
    }
        
    var animation: Animation = .slideRight
    
    override func show(_ vc: UIViewController, sender: Any?) {
        super.show(vc, sender: sender) // must call super
        let width = view.bounds.width
        switch animation {
        case .slideRight:
            destinationCentreXAnchorConstraint?.constant -= width
            destination!.view!.layoutIfNeeded()
            view.layoutIfNeeded()
            sourceCentreXAnchorConstraint?.constant += width
            destinationCentreXAnchorConstraint?.constant += width
        case .slideLeft:
            destinationCentreXAnchorConstraint?.constant += width
            destination?.view!.layoutIfNeeded()
            view.layoutIfNeeded()
            sourceCentreXAnchorConstraint?.constant -= width
            destinationCentreXAnchorConstraint?.constant -= width
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.transitionCleanUp()
        }
    }
}
