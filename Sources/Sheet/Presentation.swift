//
//  Created by Rob Nash on 05/04/2019.
//  Copyright © 2019 Nash Property Solutions Ltd. All rights reserved.
//

import UIKit

fileprivate final class ControllerAnimator: NSObject {
    var isPresentation: Bool = false
}

extension ControllerAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        let controller = transitionContext.viewController(forKey: isPresentation ? .to : .from)!
        
        if isPresentation {
            containerView.addSubview(controller.view)
        }
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        dismissedFrame.origin.y = containerView.frame.size.height
        
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        
        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       usingSpringWithDamping: 300,
                       initialSpringVelocity: 5,
                       options: .beginFromCurrentState,
                       animations: {
                        controller.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}

fileprivate class PresentationController: UIPresentationController {
    
    private let dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        view.alpha = 0.0
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        backgroundTapped?()
    }
    
    var backgroundTapped: (() -> Void)?

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        containerView!.addSubview(dimmingView)
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView!.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView!.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView!.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView!.trailingAnchor)
            ])
        
        let controller = presentedViewController as! ParentViewController
        controller.setupInitialConstraints(traitCollection)
        
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1.0
            })
        } else {
            dimmingView.alpha = 1.0
        }
    }
    
    override var adaptivePresentationStyle: UIModalPresentationStyle {
        return .overFullScreen
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        for child in presentedViewController.children {
            let isAppearing = false
            child.beginAppearanceTransition(isAppearing, animated: true)
            child.willMove(toParent: nil)
        }
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            })
        } else {
            dimmingView.alpha = 0
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return parentSize
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return containerView!.frame
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        for child in presentedViewController.children {
            child.endAppearanceTransition()
            child.view!.removeFromSuperview()
            child.removeFromParent()
        }
    }
}

final class ControllerTransitioningDelegate: NSObject {
    var chromeViewTapped: (() -> Void)?
    fileprivate let animator = ControllerAnimator()
}

extension ControllerTransitioningDelegate: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = PresentationController(presentedViewController: presented, presenting: presenting)
        controller.backgroundTapped = chromeViewTapped
        return controller
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresentation = true
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresentation = false
        return animator
    }
}
