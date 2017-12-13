//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

class HashUtils {

    static func getHashForTrip(beacon: BusBeacon) -> String {

        // Use the trip id as a identifier for this trip, as a trip with that id only drives once
        // a day.
        let trip = beacon.lastTrip

        let components: [Calendar.Component] = [.year, .month, .day, .hour, .minute, .second]
        let calendarUnitFlags = Set(components)
        let calendar = Calendar.current
        var start = calendar.dateComponents(calendarUnitFlags,
                from: beacon.startDate)

        // Use the day of the year to uniquely identify the trip. The trip id alone is not enough
        // to identify this trip, as a bus which drives the next day can have the same trip id
        // as the one we're generating the hash for.
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: beacon.startDate)!

        // Use the year to prevent beacons with the same id having the same hash if they happened
        // in a different year.
        let year = start.year!

        // Use the origin and destination bus stops to differentiate a trip which drives the same
        // line and trip as another one, but starts and ends at different bus stops (e.g. even though
        // a trip from stazione to ospedale might have the same trip id on the same day, the trip
        // from Stazione to Piazza Walther must have a different hash than a trip from Piazza Vittoria
        // to Via Sorrento).
        let origin = beacon.origin

        var accountId = AuthHelper.getUserId()
        if accountId == nil {
            // If the user isn't logged in, choose a random account id and add it to the hash.
            // As the trips are not synced if the user is not logged in, it won't matter if
            // the account id is random as the final hash is only used for sync.

            accountId = UUID().uuidString
        }

        // The raw trip hash. The final hash will be a md5 version of this hash.
        let identifier = String(format: "\(trip):\(dayOfYear):\(year):\(accountId!):\(origin)")

        Log.info("Generating hash for bus \(beacon.id): \(identifier)")

        return md5(string: identifier).substring(to: 16)
    }

    static func md5(string: String) -> String {
        let messageData = string.data(using: .utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }


        let md5Hex = digestData.map {
            String(format: "%02hhx", $0)
        }.joined()

        return md5Hex
    }

    static func md5File(url: URL) -> String? {
        let bufferSize = 4096

        do {
            // Open file for reading:
            let file = try FileHandle(forReadingFrom: url)
            defer {
                file.closeFile()
            }

            // Create and initialize MD5 context:
            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)

            // Read up to `bufferSize` bytes, until EOF is reached, and update MD5 context:
            while case let data = file.readData(ofLength: bufferSize), data.count > 0 {
                data.withUnsafeBytes {
                    _ = CC_MD5_Update(&context, $0, CC_LONG(data.count))
                }
            }

            // Compute the MD5 digest:
            var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
            digest.withUnsafeMutableBytes {
                _ = CC_MD5_Final($0, &context)
            }

            let hexDigest = digest.map {
                String(format: "%02hhx", $0)
            }.joined()

            return hexDigest
        } catch {
            ErrorHelper.log(error, message: "Cannot compute md5 of file '\(url)', error: '\(error)'")
            return nil
        }
    }
}
