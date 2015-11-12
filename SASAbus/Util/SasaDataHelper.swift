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

class SasaDataHelper {
    
    static let BusDayTypeList:String = "FIRMENKALENDER"
    static let BusPathList:String = "LID_VERLAUF"
    static let BusStandardTimeBetweenStopsList:String = "SEL_FZT_FELD"
    static let BusDefaultWaitTimeAtStopList:String = "ORT_HZT"
    static let BusLineWaitTimeAtStopList:String = "REC_LIVAR_HZT"
    static let BusWaitTimeAtStopList:String = "REC_FRT_HZT"
    static let BusLines:String = "REC_LID"
    static let BusStations:String = "REC_ORT"
    static let BusExceptionTimeBetweenStops:String = "REC_FRT_FZT"
    static let ExpirationDate:String = "BASIS_VER_GUELTIGKEIT"
    
    static let instance = SasaDataHelper()
    
    static var cache = [String: Any]()
    func getData(file:String, defaultValue:String? = "") -> String? {
        //init rec_ort
        var fileContent = String()
        do {
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let recFileName = directoryURL.URLByAppendingPathComponent(Configuration.dataFolder + file, isDirectory: false)
            fileContent = try String(contentsOfFile: recFileName.path!, encoding:NSUTF8StringEncoding)
        } catch {
            fileContent = defaultValue!
        }
        return fileContent;
    }
    
    func getDataForRepresentation<T: ResponseCollectionSerializable>(file:String)  -> [T] {
        var result: [T] = []
        if (SasaDataHelper.cache[file] != nil) {
            result = SasaDataHelper.cache[file] as! [T]
        } else {
            do {
                let contentAsString = self.getData(file)
                let content = contentAsString!.dataUsingEncoding(NSUTF8StringEncoding)
                let data = try NSJSONSerialization.JSONObjectWithData(content!, options: NSJSONReadingOptions.MutableContainers)
                result = T.collection(data)
                SasaDataHelper.cache[file] = result
            } catch {
            }
        }
        return result
    }
    
    func getSingleElementForRepresentation<T: ResponseObjectSerializable>(file:String) throws -> T? {
        let contentAsString = self.getData(file)
        let content = contentAsString!.dataUsingEncoding(NSUTF8StringEncoding)
        let data = try NSJSONSerialization.JSONObjectWithData(content!, options: NSJSONReadingOptions.MutableContainers)
        return T(representation: data)!
    
    }
    
    static func BusDayTypeTrip(busLine: BusLineItem, dayType: BusDayTypeItem) -> String {
        return "REC_FRT_LI_NR_" + String(busLine.getNumber()) + "_TAGESART_NR_" + String(dayType.getDayTypeNumber())
    }
}
