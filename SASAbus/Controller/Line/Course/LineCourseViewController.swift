import UIKit

import RxSwift
import RxCocoa

import Realm
import RealmSwift

class LineCourseViewController: UIViewController {

    @IBOutlet weak var containerList: UIView!
    @IBOutlet weak var containerMap: UIView!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var segmentedBackground: UIView!

    var vehicle: Int = 0
    var lineId: Int = 0
    var tripId: Int = 0

    var currentBusStop: Int = 0
    var busStopGroup: Int = 0
    
    var date: Date!

    var tempBusStop: Int = 0

    var listController: LineCourseListViewController!
    var mapController: LineCourseMapViewController!


    init(tripId: Int, lineId: Int, vehicle: Int, currentBusStop: Int, busStopGroup: Int, date: Date = Date()) {
        self.tripId = tripId
        self.lineId = lineId
        self.vehicle = vehicle
        self.currentBusStop = currentBusStop
        self.busStopGroup = busStopGroup
        
        self.date = date

        super.init(nibName: "LineCourseViewController", bundle: nil)

        title = L10n.Line.Course.title
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedBackground.backgroundColor = Theme.mint

        prepareListViewController()
        prepareMapViewController()
        
        segmentedControl.setTitle(L10n.Line.Course.Header.list, forSegmentAt: 0)
        segmentedControl.setTitle(L10n.Line.Course.Header.map, forSegmentAt: 1)

        parseData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navController = self.navigationController {
            navController.navigationBar.barTintColor = Theme.mint
            navController.hidesNavigationBarHairline = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navController = self.navigationController {
            navController.navigationBar.barTintColor = Theme.orange
            navController.hidesNavigationBarHairline = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        listController.view.frame = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: containerList.frame.width, height: containerList.frame.height)
        )

        mapController.view.frame = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: containerMap.frame.width, height: containerMap.frame.height)
        )
    }


    func prepareListViewController() {
        listController = LineCourseListViewController(parent: self, lineId: lineId, vehicle: vehicle)
        let view = listController.view!

        view.translatesAutoresizingMaskIntoConstraints = true

        containerList.addSubview(view)
        self.addChildViewController(listController)

        self.view.setNeedsLayout()
        view.setNeedsLayout()
    }

    func prepareMapViewController() {
        mapController = LineCourseMapViewController(lineId: lineId)
        let view = mapController.view!

        view.translatesAutoresizingMaskIntoConstraints = true

        containerMap.addSubview(view)
        self.addChildViewController(mapController)

        self.view.setNeedsLayout()
        view.setNeedsLayout()
    }


    // MARK: - Data loading

    func parseData() {
        let observer: Observable<[LineCourse]>
        
        if vehicle != 0 {
            Log.warning("Getting bus position for \(vehicle)")
            
            observer = RealtimeApi.vehicle(vehicle)
                .flatMap { bus -> Observable<[LineCourse]> in
                    guard let bus = bus else {
                        Log.warning("Bus \(self.vehicle) is not in service")
                        
                        return self.getObservable(
                            busStopGroup: self.busStopGroup,
                            currentBusStop: self.currentBusStop,
                            tripId: self.tripId,
                            date: self.date
                        )
                    }
                    
                    Log.warning("Got bus position for \(self.vehicle): \(bus.busStop)")
                    
                    return self.getObservable(
                        busStopGroup: self.busStopGroup,
                        currentBusStop: bus.busStop,
                        tripId: self.tripId,
                        date: self.date
                    )
            }
        } else {
            observer = getObservable(busStopGroup: busStopGroup, currentBusStop: currentBusStop, tripId: tripId, date: date)
        }
        
        _ = observer.subscribe(onNext: { items in
                self.listController.onSuccess(items: items)
                self.mapController.onSuccess(items: items)
            }, onError: { error in
                self.listController.onError(error: error as NSError)
                self.mapController.onError(error: error as NSError)
            })
    }
    
    private func getObservable(busStopGroup: Int, currentBusStop: Int, tripId: Int, date: Date) -> Observable<[LineCourse]> {
        return parseFromPlanData(busStopGroup: busStopGroup, currentBusStop: currentBusStop, tripId: tripId, date: date)
            .subscribeOn(MainScheduler.background)
            .map(passingLinesMap)
            .observeOn(MainScheduler.instance)
    }

    private func parseFromPlanData(busStopGroup: Int, currentBusStop: Int, tripId: Int, date: Date) -> Observable<[LineCourse]> {
        return Observable.create { subscriber in
            guard Api.todayExists() else {
                PlannedData.setUpdateAvailable(true)
                subscriber.onError(VdvError.vdvError(message: "Today does not exist"))
                return Disposables.create()
            }

            var items = [LineCourse]()
            let path: [VdvBusStop] = Api.getTrip(tripId: tripId, date: date).calcTimedPath()

            let realm = Realm.busStops()

            var active = currentBusStop == 0

            for stop in path {
                let busStop = BBusStop(fromRealm: BusStopRealmHelper.getBusStop(id: stop.id, realm: realm))

                var bus = false
                var pin = false

                // Iterate all times to see at which bus stop the bus currently is, and mark it
                // to make it stand out in the list (by either a dot or a bus depending if it
                // currently is in service).

                if (busStop.id == currentBusStop) {
                    active = true
                    bus = true
                }

                if (busStop.family == busStopGroup) {
                    pin = true
                }

                items.append(LineCourse(
                        id: stop.id,
                        busStop: busStop,
                        time: stop.time,
                        active: active,
                        pin: pin,
                        bus: bus
                ))
            }

            subscriber.on(.next(items))
            subscriber.onCompleted()

            return Disposables.create()
        }
    }


    // MARK: - Click handlers

    @IBAction func showComponent(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.containerList.alpha = 1
            self.containerMap.alpha = 0
        } else {
            self.containerList.alpha = 0
            self.containerMap.alpha = 1
        }
    }


    // MARK: - RxSwift

    func passingLinesMap(lineCourses: [LineCourse]) -> [LineCourse] {
        for lineCourse in lineCourses {
            let family = BusStopRealmHelper.getBusStopGroup(id: lineCourse.id)

            let passingLines: [Int] = Api.getPassingLines(group: family)

            var lines = ""

            for line in passingLines {
                let lineName = Lines.lidToName(id: line)
                let coloredLineName = getColoredString(text: lineName, color: "#" + Lines.getColorForId(id: line))
                lines += "\(coloredLineName), "
            }

            if lines.characters.count > 2 {
                lines = String(lines.characters.dropLast())
                lines = String(lines.characters.dropLast())
            }

            lines = Lines.lines(name: lines)

            let data = lines.data(using: String.Encoding.utf8)!
            let attributes = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]

            do {
                let attributedString = try NSAttributedString(data: data, options: attributes, documentAttributes: nil)

                let fullRange = NSRange(location: 0, length: attributedString.length)
                let mutableAttributeText = NSMutableAttributedString(attributedString: attributedString)

                attributedString.enumerateAttribute(
                        NSFontAttributeName,
                        in: fullRange,
                        options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired) {

                    (attribute: Any?, range: NSRange, _: UnsafeMutablePointer<ObjCBool>) -> Void in

                    if attribute is UIFont {
                        let scaledFont = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
                        mutableAttributeText.addAttribute(NSFontAttributeName, value: scaledFont, range: range)
                    }
                }

                lineCourse.lineText = mutableAttributeText
            } catch let error {
                ErrorHelper.log(error, message: "Could not format string")
            }
        }

        return lineCourses
    }

    func getColoredString(text: String, color: String) -> String {
        return "<font color=\"\(color)\">\(text)</font>"
    }
}
