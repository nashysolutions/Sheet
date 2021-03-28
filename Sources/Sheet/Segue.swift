//
//  Created by Rob Nash on 05/04/2019.
//  Copyright © 2019 Nash Property Solutions Ltd. All rights reserved.
//

import UIKit

open class StoryboardSegue: UIStoryboardSegue {
    
    override open func perform() {
        super.perform()
        executeTransition {
            self.transitionCleanUp()
        }
    }
    
    open func executeTransition(_ completion: @escaping () -> Void) {}
    
    private func transitionCleanUp() {
        if let parent = self.destination.parent {
            self.destination.didMove(toParent: parent)
            self.source.view.removeFromSuperview()
            self.source.removeFromParent()
        }
    }
}
