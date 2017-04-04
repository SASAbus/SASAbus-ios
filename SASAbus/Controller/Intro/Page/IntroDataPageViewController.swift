import UIKit
import RxSwift
import RxCocoa

class IntroDataPageViewController: IntroPageViewController {

    @IBOutlet weak var doneImage: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!

    var parentVC: IntroViewController!

    var downloadComplete: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        UIUtils.tintImage(image: doneImage, tint: color)

        doneImage.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !downloadComplete {
            parentVC.setSwipeable(swipeable: false)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.downloadData()
            }
        }
    }


    // MARK: - Data downloading

    func downloadData() {
        if !NetUtils.isOnline() {
            self.deviceOffline()
            return
        }

        _ = PlannedData.downloadPlanData()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { progress in
                    self.progressView.progress = progress
                    print(progress)
                },
                onError: { error in
                    self.downloadComplete = false

                    Log.debug("Error: \(error)")

                    self.onError()
                },
                onCompleted: {
                    self.downloadComplete = true

                    UIView.animate(withDuration: 0.4) {
                        self.progressView.alpha = 0
                    }

                    self.doneImage.alpha = 0
                    self.doneImage.transform = CGAffineTransform(scaleX: 0, y: 0)

                    UIView.animate(withDuration: 0.3, delay: 0.45, animations: {
                        self.doneImage.alpha = 1
                        self.doneImage.transform = CGAffineTransform(scaleX: 1, y: 1)
                    })

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.parentVC.setSwipeable(swipeable: true)
                    }

                    Log.debug("Completed data download")
                })
    }

    func deviceOffline() {
        let alert = UIAlertController(title: "No internet connection", message: "Data download requires an internet connection.",
                preferredStyle: UIAlertControllerStyle.alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (_) in
            exit(1)
        }
        let defaultAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default) { (_) in
            self.downloadData()
        }

        alert.addAction(cancelAction)
        alert.addAction(defaultAction)

        present(alert, animated: true)
    }

    func onError() {
        let alert = UIAlertController(title: nil, message: "Could not download data", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (_) in
            exit(1)
        }
        let defaultAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default) { (_) in
            self.downloadData()
        }

        alert.addAction(cancelAction)
        alert.addAction(defaultAction)

        present(alert, animated: true)
    }
}
