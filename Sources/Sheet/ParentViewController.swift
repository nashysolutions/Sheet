//
//  Created by Rob Nash on 05/04/2019.
//  Copyright © 2019 Nash Property Solutions Ltd. All rights reserved.
//

import UIKit

fileprivate final class ParentView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews.reversed() {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        return nil
    }
}

class ParentViewController: UIViewController {
    
    var runSetNeeds: (() -> Void)?
    
    override public func loadView() {
        self.view = ParentView()
    }
    
    var source: UIViewController? {
        return children.first
    }
    
    var destination: UIViewController? {
        return children.last
    }
    
    var sourceCentreXAnchorConstraint: NSLayoutConstraint?
    var destinationCentreXAnchorConstraint: NSLayoutConstraint?
    
    let insets: Sheet.Insets
    
    init(_ insets: Sheet.Insets) {
        self.insets = insets
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with vc: UIViewController) {
        vc.modalPresentationCapturesStatusBarAppearance = true
        view.addSubview(vc.view!)
        addChild(vc)
        vc.view!.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupInitialConstraints(_ traitCollection: UITraitCollection) {
        guard let source = source else {
            return
        }
        setupSourceConstraints(source, traitCollection)
    }
    
    private func setupSourceConstraints(_ primaryChild: UIViewController, _ traitCollection: UITraitCollection) {
        let constraints = self.constraints(for: primaryChild.view, widthInset: insets.width, bottomInset: insets.bottom)
        sourceCentreXAnchorConstraint = constraints.first
        NSLayoutConstraint.activate(constraints)
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        vc.modalPresentationCapturesStatusBarAppearance = true
        addChild(vc)
        view.addSubview(vc.view!)
        vc.view!.translatesAutoresizingMaskIntoConstraints = false
        let constraints = self.constraints(for: vc.view, widthInset: insets.width, bottomInset: insets.bottom)
        destinationCentreXAnchorConstraint = constraints.first
        NSLayoutConstraint.activate(constraints)
        runSetNeeds?()
    }
    
    func transitionCleanUp() {
        destination?.didMove(toParent: self)
        source?.willMove(toParent: nil)
        source?.view!.removeFromSuperview()
        source?.removeFromParent()
    }
    
    override public var childForStatusBarStyle: UIViewController? {
        return children.last
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return children.last
    }
    
    override public var childForStatusBarHidden: UIViewController? {
        return children.last
    }
    
    // MARK: - Constraints
    
    private func constraints(for childView: UIView, widthInset: CGFloat, bottomInset: CGFloat) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append(centerXConstraint(for: childView))
        constraints.append(bottomConstraint(for: childView, inset: -bottomInset))
        constraints.append(contentsOf: widthConstraints(for: childView, inset: -widthInset))
        return constraints
    }
    
    private func centerXConstraint(for childView: UIView) -> NSLayoutConstraint {
        return childView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    }
    
    private func bottomConstraint(for childView: UIView, inset: CGFloat) -> NSLayoutConstraint {
        return childView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: inset)
    }
    
    private func widthConstraints(for childView: UIView, inset: CGFloat) -> [NSLayoutConstraint] {
        return ChildControllerWidth.constraints(for: childView, inParent: view, inset: inset)
    }
    
    private struct ChildControllerWidth {
        
        static func constraints(for childView: UIView, inParent parent: UIView, inset: CGFloat) -> [NSLayoutConstraint] {
            let constraint = sameAsParent(for: childView, inParent: parent, inset: inset)
            let constraints = maxSize(for: childView)
            return constraints + [constraint]
        }
        
        private static func sameAsParent(for childView: UIView, inParent parent: UIView, inset: CGFloat) -> NSLayoutConstraint {
            let constraint = childView.widthAnchor.constraint(equalTo: parent.widthAnchor, constant: inset)
            constraint.priority = UILayoutPriority(rawValue: 999)
            return constraint
        }
        
        private static func maxSize(for childView: UIView) -> [NSLayoutConstraint] {
            let layout = "[childView(<=414@1000)]"
            let views: [String : Any] = ["childView" : childView]
            return NSLayoutConstraint.constraints(withVisualFormat: layout, options: [], metrics: nil, views: views)
        }
    }
}
