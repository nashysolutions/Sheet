# Sheet

Cool pop ups assembled using interface builder and minimal code.

<img src="https://user-images.githubusercontent.com/64097812/112761116-83705700-8ff1-11eb-9b50-a698b0a601cf.gif" width="187.5"/> | <img src="https://user-images.githubusercontent.com/64097812/113262152-34177880-92c8-11eb-9928-d394451e8f2e.gif" width="187.5"/>

### Just a normal storyboard

![](https://user-images.githubusercontent.com/64097812/113262263-5610fb00-92c8-11eb-982d-29cf94e6ae36.png)

## Usage

```swift
final class ViewController: UIViewController {

    private let sheet = Sheet(animation: .slideLeft)
        
    @objc 
    func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "WelcomeSheet", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()!
        sheet.show(viewController, above: self)
    }
}
```

To handle touch events outside of the action sheett.

```swift
sheet.chromeTapped = { [unowned self] in
    self.dismiss(animated: true)
}
```

To handle dismiss at the end of the workflow, set up an observer at the beginning and post a notification at the end.

```swift
extension Notification.Name {
    static let dismiss = Notification.Name(rawValue: "Dismiss")
}

NotificationCenter.default.addObserver(
    forName: .dismiss, 
    object: nil, 
    queue: nil) { [weak self] _ in
        self?.dismiss(animated: true)
}
```

This will also give you the opportunity to dismiss from other locations, should you deem it necessary.

```swift
func applicationDidEnterBackground(_ application: UIApplication) {
    NotificationCenter.default.post(
        name: .dismiss,
        object: self,
        userInfo: [dismissSheetAnimatedKey : false]
    )
}
```

Responding to size class changes or dynamic type is the responsibility of your view controllers.

```swift
final class CompleteSheetViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        iconImageView.isHidden = (traitCollection.verticalSizeClass == .compact)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        iconImageView.isHidden = (newCollection.verticalSizeClass == .compact)
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
```

If your view controller workflow uses [func show(_ vc: UIViewContoller, sender: Any?)](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621377-show), then you're good to go.

```swift
@IBAction func startButtonPressed(_ sender: UIButton) {
    let viewController = UIStoryboard(name: "CompleteSheet", bundle: nil).instantiateInitialViewController()!
    show(viewController, sender: self)
}
```

If you would like to use custom transition animations, instantiate `Sheet` with `.custom` and sublcass `StoryboardSegue`.

```swift
final class FlipFromLeftSegue: StoryboardSegue {
    
    override func executeTransition(_ completion: @escaping () -> Void) {
        UIView.transition(
            from: source.view!,
            to: destination.view!,
            duration: 0.3,
            options: [.transitionFlipFromLeft]) { (_) in
                completion()
            }
    }
}

final class DropSegue: StoryboardSegue {

    override func executeTransition(_ completion: @escaping () -> Void) {
        destination.view.layoutIfNeeded()
        destination.view.transform = CGAffineTransform(translationX: 0, y: destination.view.bounds.height)
        let height = source.view.bounds.height
        UIView.animate(withDuration: 0.3, animations: {
            self.source.view.transform = CGAffineTransform(translationX: 0, y: height)
            self.destination.view.transform = CGAffineTransform.identity
        }) { _ in
            completion()
        }
    }
}
```
