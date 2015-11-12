//
// SurveyItem.swift
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

final class SurveyItem: ResponseObjectSerializable, ResponseCollectionSerializable {

    private var id: Int!
    private var enabled: Bool!
    private var firstQuestionGerman: String!
    private var firstQuestionEnglish: String!
    private var firstQuestionItalian: String!
    private var firstQuestionPlaceholderGerman: String!
    private var firstQuestionPlaceholderEnglish: String!
    private var firstQuestionPlaceholderItalian: String!
    private var secondQuestionGerman: String!
    private var secondQuestionEnglish: String!
    private var secondQuestionItalian: String!
    private var status:String!
    
    init?( representation: AnyObject) {
        self.status = representation.valueForKeyPath("status") as! String
        if (self.status == "success") {
        
            let dataArray = representation.valueForKey("data") as! [AnyObject]
            let data = dataArray[0] as AnyObject!
            
            self.id = Int(data.valueForKeyPath("id") as! String)
            self.enabled = (data.valueForKeyPath("enabled") as! String) == "y"
            
            self.firstQuestionGerman = data.valueForKeyPath("first_question_de") as! String
            self.firstQuestionGerman = data.valueForKeyPath("first_question_de") as! String
            self.firstQuestionEnglish = data.valueForKeyPath("first_question_en") as! String
            self.firstQuestionItalian = data.valueForKeyPath("first_question_it") as! String
            
            self.firstQuestionPlaceholderGerman = data.valueForKeyPath("first_question_placeholder_de") as! String
            self.firstQuestionPlaceholderEnglish = data.valueForKeyPath("first_question_placeholder_en") as! String
            self.firstQuestionPlaceholderItalian = data.valueForKeyPath("first_question_placeholder_it") as! String
            
            self.secondQuestionGerman = data.valueForKeyPath("second_question_de") as! String
            self.secondQuestionEnglish = data.valueForKeyPath("second_question_en") as! String
            self.secondQuestionItalian = data.valueForKeyPath("second_question_it") as! String
        }
    }
    
    static func collection(representation: AnyObject) -> [SurveyItem] {
        var items: [SurveyItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = SurveyItem(representation: itemRepresentation) {
                    items.append(item)
                }
            }
        }
        return items
    }
    
    func getStatus() -> String {
        return self.status
    }
    
    func getId() -> Int {
        return self.id
    }
    
    func isEnabled() -> Bool {
        return self.enabled
    }
    
    func getFirstQuestionGerman() -> String {
        return self.firstQuestionGerman
    }
    
    func getFirstQuestionEnglish() -> String {
        return self.firstQuestionEnglish
    }
    
    func getFirstQuestionItalian() -> String {
        return self.firstQuestionItalian
    }
    
    func getFirstQuestionPlaceholderGerman() -> String {
        return self.firstQuestionPlaceholderGerman
    }
    
    func getFirstQuestionPlaceholderEnglish() -> String {
        return self.firstQuestionPlaceholderEnglish
    }
    
    func getFirstQuestionPlaceholderItalian() -> String {
        return self.firstQuestionPlaceholderItalian
    }
    
    func getSecondQuestionGerman() -> String {
        return self.secondQuestionGerman
    }
    
    func getSecondQuestionEnglish() -> String {
        return self.secondQuestionEnglish
    }
    
    func getSecondQuestionItalian() -> String {
        return self.secondQuestionItalian
    }
    
    func getFirstQuestionLocalized() -> String {
        let language = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!
        if language as! String == "it" {
            return self.getFirstQuestionItalian()
        } else if language as! String == "en" {
            return self.getFirstQuestionEnglish()
        }else {
            return self.getFirstQuestionGerman()
        }
    }
    
    func getSecondQuestionLocalized() -> String {
        let language = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!
        if language as! String == "it" {
            return self.getSecondQuestionItalian()
        } else if  language as! String == "en" {
            return self.getSecondQuestionEnglish()
        } else {
            return self.getSecondQuestionGerman()
        }
    }
    
    func getFirstQuestionPlaceholderLocalized() -> String {
        let language = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!
        if language as! String == "it" {
            return self.getFirstQuestionPlaceholderItalian()
        } else if  language as! String == "en" {
            return self.getFirstQuestionPlaceholderEnglish()
        } else {
            return self.getFirstQuestionPlaceholderGerman()
        }
    }
}