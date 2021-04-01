# Sheet

Cool pop ups assembled using interface builder and minimal code.

<img src="https://user-images.githubusercontent.com/64097812/112761116-83705700-8ff1-11eb-9b50-a698b0a601cf.gif" width="187.5"/> | <img src="https://user-images.githubusercontent.com/64097812/113262152-34177880-92c8-11eb-9928-d394451e8f2e.gif" width="187.5"/>

### Just a normal storyboard

![](https://user-images.githubusercontent.com/64097812/113262263-5610fb00-92c8-11eb-982d-29cf94e6ae36.png)

## Usage

```swift
final class ViewController: UIViewController {

    private let sheetManager = Sheet(animation: .slideLeft)
    
    private var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        observer = NotificationCenter.default.addObserver(
            forName: .dismiss, 
            object: nil, 
            queue: nil) { [weak self] _ in
                self?.dismiss(animated: true)
        }
        sheetManager.chromeTapped = { [unowned self] in
            self.dismiss(animated: true)
        }
        let action = #selector(tapGestureRecognized(_:))
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "WelcomeSheet", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()!
        sheetManager.show(viewController, above: self)
    }
}
```

The notification name `dismiss` is created the typical way. You may create any name you like.

```swift
extension Notification.Name {
    static let dismiss = Notification.Name(rawValue: "Dismiss")
}
``` 
> Observed: by the controller that presents the action sheet. 
> Posted: by the last controller in the action sheet sequence (or `didEnterBackground` for example).

Here are a sequence of two actions sheets `WelcomeSheetViewController` being the 1st and `CompleteSheetViewController` being the last.

```swift
final class WelcomeSheetViewController: BaseViewController {
        
    @IBAction func startButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "CompleteSheet", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()!
        show(viewController, sender: self)
    }
}

final class CompleteSheetViewController: BaseViewController {
        
    @IBAction func finishButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: .dismiss, object: nil)
    }
}

class BaseViewController: UIViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.clipsToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.1
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
```
> You may create a network of storyboard segue's, each segue pushing via `show` in storyboard or by calling UIKit's `show` `show(:sender:)` in code.

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // iconImageView is an IBOutlet property to a UIImageView embedded in a stack view.
    iconImageView.isHidden = (traitCollection.verticalSizeClass == .compact)
}

override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    iconImageView.isHidden = (newCollection.verticalSizeClass == .compact)
    coordinator.animate(alongsideTransition: { [unowned self] _ in
        self.view.layoutIfNeeded()
    }, completion: nil)
}
```
> Make sure your layout works in all environments. The above preview shows a paper plan icon which is hidden in compact height environments.

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
