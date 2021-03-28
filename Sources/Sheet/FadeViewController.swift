//
//  Created by Rob Nash on 05/04/2019.
//  Copyright © 2019 Nash Property Solutions Ltd. All rights reserved.
//

import UIKit

final class FadeViewController: ParentViewController {
    
    override func show(_ vc: UIViewController, sender: Any?) {
        super.show(vc, sender: sender) // must call super
        destination?.view!.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.source?.view!.alpha = 0
        }, completion: { (_) in
            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                self.destination?.view!.alpha = 1
            }, completion: { _ in
                self.transitionCleanUp()
            })
        })
    }
    
}
