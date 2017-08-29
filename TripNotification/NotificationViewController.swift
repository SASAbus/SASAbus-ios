//
//  NotificationViewController.swift
//  TripNotification
//
//  Created by Alex Lardschneider on 04/04/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import ObjectMapper

class NotificationViewController: UIViewController, UNNotificationContentExtension,
        UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var subtitleText: UILabel!

    @IBOutlet weak var tableView: UITableView!

    var lineColor: UIColor! = nil
    var currentTrip: CurrentTrip! = nil

    var items = [Item]()

    class Item {

        var icon: String
        var time: NSAttributedString
        var delay: NSAttributedString
        var destination: NSAttributedString

        var delayColor: UIColor
        var isDot: Bool

        var height: Int

        init(icon: String, time: String, delay: String, destination: String, delayColor: UIColor, isDot: Bool = false) {
            self.icon = icon
            self.time = NSAttributedString(string: time)
            self.delay = NSAttributedString(string: delay)
            self.destination = NSAttributedString(string: destination)
            self.delayColor = delayColor
            self.isDot = isDot

            height = isDot ? 14 : 26
        }

        init(icon: String, time: NSAttributedString, delay: NSAttributedString, destination: NSAttributedString,
             delayColor: UIColor, isDot: Bool = false) {

            self.icon = icon
            self.time = time
            self.delay = delay
            self.destination = destination
            self.delayColor = delayColor
            self.isDot = isDot

            height = isDot ? 14 : 26
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "notification_cell")
        tableView.register(UINib(nibName: "NotificationCellDot", bundle: nil), forCellReuseIdentifier: "notification_cell_dot")
    }

    func didReceive(_ notification: UNNotification) {
        Log.error("Did receive notification: \(notification)")

        let json = notification.request.content.userInfo["trip"]

        if json == nil {
            Log.error("No json to decode")
            return
        }

        currentTrip = Mapper<CurrentTrip>().map(JSONString: json as! String)

        if currentTrip == nil {
            Log.error("No current trip available")
            return
        }

        lineColor = UIColor(hexString: Lines.getColorForId(id: currentTrip.beacon.lastLine))

        setTitles()
        setupViews()

        preferredContentSize = CGSize(width: 0, height: calculateHeight())
    }


    func setTitles() {
        let delay = currentTrip.delay
        var delayString: String

        if currentTrip.beacon.departure < 0 {
            delayString = "Departs in \(currentTrip.beacon.departure)\'"
            titleText.textColor = UIColor(hexString: "FF008094")
        } else {
            if delay > 0 {
                delayString = "\(delay)' delayed"
            } else if delay < 0 {
                delayString = "\(delay * -1)' ahead"
            } else {
                delayString = "Punctual"
            }

            titleText.text = delayString
            titleText.textColor = Color.delay(delay)
        }

        subtitleText.text = currentTrip.title
    }

    func calculateHeight() -> Int {
        let headerHeight = 64
        let taleViewMargin = 8

        var tableViewHeight = 0

        for item in items {
            tableViewHeight += item.height
        }

        return headerHeight + tableViewHeight + taleViewMargin
    }

    func setupViews() {
        items.removeAll()

        var path: [BBusStop] = currentTrip.path
        var times = currentTrip.times!

        let currentBusStop = currentTrip.beacon.busStop!

        var index = -1
        let startIndex = currentTrip.hasReachedSecondBusStop ? 1 : 0

        var i = startIndex
        let pathSize = path.count

        while i < pathSize {
            let busStop = path[i]
            if currentTrip.beacon.busStopType == BusBeacon.TYPE_REALTIME {
                if busStop.id == currentBusStop.id {
                    index = i
                    break
                }
            } else if busStop.family == currentBusStop.family {
                index = i
                break
            }

            i += 1
        }

        if index > 0 {
            currentTrip.hasReachedSecondBusStop = true
        }

        if index == -1 {
            Log.error("index == -1, current bus stop: \(currentBusStop.id), type: \(currentTrip.beacon.busStopType), path: \(path)")

            return
        }

        let delayColor = Color.delay(currentTrip.delay)

        // If the bus is not at the stop the notification will display the last bus stop
        // the bus passed by in the first row. The current bus stop will be displayed on the
        // second row instead.
        if index == 0 {
            let busStop = path[0]

            var timeSeconds = times[0].departure
            timeSeconds += currentTrip.delay * 60

            let item = Item(icon: "path_start", time: times[0].time, delay: ApiTime.toTime(seconds: timeSeconds),
                    destination: busStop.name(), delayColor: delayColor)

            items.append(item)

        } else if index > 0 {
            let tempIndex = index - 1
            let busStop = path[tempIndex]

            var timeSeconds = times[tempIndex].departure
            timeSeconds += currentTrip.delay * 60

            let item = Item(icon: "path_start", time: times[tempIndex].time, delay: ApiTime.toTime(seconds: timeSeconds),
                    destination: busStop.name(), delayColor: delayColor)

            items.append(item)
        }

        /*remoteViews.setImageViewBitmap(R.id.image_route_points,
                getTintedBitmap(context, R.drawable.path_etc, trip))*/

        // If the bus is at the first bus stop, there is no previous bus stop to display
        // in grey color. We need to increase the index so we don't display the departure bus
        // stop twice, one time as current bus stop and one time as previous one.
        // The boolean is there to indicate that we are at the first bus stop, which is needed
        // to hide the bus dot image, as the bus isn't between any two bus stops.
        let isAtDepartureBusStop = index == 0
        if isAtDepartureBusStop {
            index += 1
        }

        let isDepartsIn = currentTrip.beacon.departure < 0

        var shouldAddDot = true

        let length = 7
        for i in 1...length - 1 {
            if index + i <= path.count {
                var tempIndex: Int

                // Last bus stop
                if i == 6 || index + i > path.count - 1 {
                    tempIndex = path.count - 1
                    let busStop = path[tempIndex]

                    var timeSeconds = times[tempIndex].departure
                    timeSeconds += currentTrip.delay * 60

                    let item = Item(icon: "path_end", time: times[tempIndex].time, delay: ApiTime.toTime(seconds: timeSeconds),
                            destination: busStop.name(), delayColor: delayColor)

                    items.append(item)

                    continue
                }

                if i == 1 {
                    tempIndex = index
                    let busStop = path[tempIndex]

                    var timeSeconds = times[tempIndex].departure
                    timeSeconds += currentTrip.delay * 60

                    let busStopString = NSMutableAttributedString()
                    let timeString = NSMutableAttributedString()
                    let timeDelayString = NSMutableAttributedString()
                    var image = ""

                    if isAtDepartureBusStop || isDepartsIn {
                        _ = busStopString.normal(busStop.name())
                        _ = timeString.normal(times[tempIndex].time)
                        _ = timeDelayString.normal(ApiTime.toTime(seconds: timeSeconds))

                        image = "path_bus_stop"
                    } else {
                        image = "path_bus"

                        _ = busStopString.bold(busStop.name())
                        _ = timeString.bold(times[tempIndex].time)
                        _ = timeDelayString.bold(ApiTime.toTime(seconds: timeSeconds))
                    }

                    let item = Item(icon: image, time: timeString,
                            delay: timeDelayString, destination: busStopString, delayColor: delayColor)

                    items.append(item)

                    continue
                }

                tempIndex = index == 0 ? index + i : index + i - 1
                let busStop = path[tempIndex]

                var timeSeconds = times[tempIndex].departure
                timeSeconds += currentTrip.delay * 60

                let item = Item(icon: "path_bus_stop", time: times[tempIndex].time,
                        delay: ApiTime.toTime(seconds: timeSeconds), destination: busStop.name(), delayColor: delayColor)

                items.append(item)
            } else {
                shouldAddDot = false
            }
        }

        if shouldAddDot {
            let item = Item(icon: "path_etc", time: "",
                    delay: "", destination: "", delayColor: UIColor.red, isDot: true)

            items.insert(item, at: 6)
        }

        tableView.reloadData()
    }


    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]

        if item.isDot {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notification_cell_dot", for: indexPath) as! NotificationCellDot
            cell.icon.tint(with: lineColor)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notification_cell", for: indexPath) as! NotificationCell

            cell.time.attributedText = item.time

            cell.delay.attributedText = item.delay
            cell.delay.textColor = item.delayColor

            cell.busStop.attributedText = item.destination

            cell.icon.image = UIImage(named: item.icon)
            cell.icon.tint(with: lineColor)

            return cell
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(items[indexPath.row].height)
    }

}

extension NSMutableAttributedString {
    func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)]
        let boldString = NSMutableAttributedString(string: "\(text)", attributes: attrs)
        self.append(boldString)
        return self
    }

    func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}

extension UIColor {

    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()

        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32

        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
