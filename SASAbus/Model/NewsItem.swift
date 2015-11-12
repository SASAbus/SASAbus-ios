//
// NewsItem.swift
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

import UIKit

final class NewsItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    private let id: Int
    private let titleDe: String
    private let titleIt: String
    private let messageDe: String
    private let messageIt: String
    private let area: Int
    private let lines: [String]
    private let lastModified: Int
    
    init?( representation: AnyObject) {
        self.id = Int(representation.valueForKeyPath("id") as! String)!
        self.titleDe = representation.valueForKeyPath("titel_de") as! String
        self.titleIt = representation.valueForKeyPath("titel_it") as! String
        self.messageDe = representation.valueForKeyPath("nachricht_de") as! String
        self.messageIt = representation.valueForKeyPath("nachricht_it") as! String
        self.area = representation.valueForKeyPath("gebiet") as! Int
        self.lines = representation.valueForKeyPath("linienliste") as! [String]
        self.lastModified = Int(representation.valueForKeyPath("lastmod") as! String)!
    }
    
    static func collection(representation: AnyObject) -> [NewsItem] {
        var newsItems: [NewsItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for newsRepresentation in representation {
                if let newsItem = NewsItem(representation: newsRepresentation) {
                    newsItems.append(newsItem)
                }
            }
        }
        
        return newsItems
    }
    
    func getId() -> Int {
        return self.id
    }
    
    func getTitle() -> String {
        var title = self.titleDe
        if NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String == "it" {
            title = self.titleIt
        }
        return title
    }
    
    func getMessage() -> String{
        var message = self.messageDe
        if NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String == "it" {
            message = self.messageIt
        }
        return message
    }
    
    func getArea() -> Int {
        return self.area
    }
    
    func getLines() -> [String] {
        return self.lines
    }
    
    func getLinesString() -> String {
        var linesString = ""
        if (self.lines.count > 0) {
            linesString = NSLocalizedString("Lines: ", comment: "") + self.lines.joinWithSeparator(", ")
        }
        return linesString
    }
    
    func getLastModified() -> Int {
        return self.lastModified
    }
}