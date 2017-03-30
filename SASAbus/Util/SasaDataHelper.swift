//
// SasaDataHelper.swift
// SASAbus
//
// Copyright (C) 2011-2015 Raiffeisen Online GmbH (Norman Marmsoler, Jürgen Sprenger, Aaron Falk) <info@raiffeisen.it>
//
// This file is part of SASAbus.
//
// SASAbus is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SASAbus is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SASAbus.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import SwiftyJSON

class SasaDataHelper {

    static let ORT_HZT: String = "ORT_HZT"
    static let LID_VERLAUF: String = "LID_VERLAUF"
    static let SEL_FZT_FELD: String = "SEL_FZT_FELD"
    static let FIRMENKALENDER: String = "FIRMENKALENDER"
    static let BASIS_VER_GUELTIGKEIT: String = "BASIS_VER_GUELTIGKEIT"

    static let REC_LID: String = "REC_LID"
    static let REC_ORT: String = "REC_ORT"
    static let REC_FRT_HZT: String = "REC_FRT_HZT"
    static let REC_FRT_FZT: String = "REC_FRT_FZT"
    static let REC_LIVAR_HZT: String = "REC_LIVAR_HZT"

    static var cache = [String: AnyObject]()

    static func getData(_ file: String, defaultValue: String? = "") -> String? {
        var fileContent = String()

        do {
            let fileManager = FileManager.default
            let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let recFileName = directoryURL.appendingPathComponent(Config.PLANNED_DATA_FOLDER + file, isDirectory: false)

            fileContent = try String(contentsOfFile: recFileName.path, encoding: String.Encoding.utf8)
        } catch {
            Log.error("Cannot load \(file): \(error)")

            fileContent = defaultValue!
        }

        return fileContent
    }

    static func getData<T:JSONCollection>(_ file: String) -> [T] {
        Log.debug("Loading data from \(file)")

        var result: [T] = []

        if (SasaDataHelper.cache[file] != nil) {
            result = SasaDataHelper.cache[file] as! [T]
        } else {
            do {
                let contentAsString = self.getData(file)
                let content = contentAsString!.data(using: String.Encoding.utf8)
                let data = try JSONSerialization.jsonObject(with: content!, options:
                JSONSerialization.ReadingOptions.mutableContainers)

                result = T.collection(parameter: JSON(data))
                SasaDataHelper.cache[file] = result as AnyObject
            } catch {
                Log.error("Cannot load \(file): \(error)")
            }
        }

        return result
    }

    static func getData<T:JSONable>(_ file: String) throws -> T? {
        Log.debug("Loading single element from \(file)")

        let contentAsString = self.getData(file)
        let content = contentAsString!.data(using: String.Encoding.utf8)
        let data = try JSONSerialization.jsonObject(with: content!, options: JSONSerialization.ReadingOptions.mutableContainers)

        return T(parameter: JSON(data))

    }

    static func BusDayTypeTrip(_ busLine: Line, dayType: BusDayTypeItem) -> String {
        return "REC_FRT_LI_NR_" + String(busLine.id) + "_TAGESART_NR_" + String(dayType.dayTypeNumber)
    }
}
