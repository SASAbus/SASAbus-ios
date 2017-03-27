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
import SwiftyJSON

final class SurveyItem: JSONable, JSONCollection {

    var id: Int!
    var enabled: Bool!
    var firstQuestionGerman: String!
    var firstQuestionEnglish: String!
    var firstQuestionItalian: String!
    var firstQuestionPlaceholderGerman: String!
    var firstQuestionPlaceholderEnglish: String!
    var firstQuestionPlaceholderItalian: String!
    var secondQuestionGerman: String!
    var secondQuestionEnglish: String!
    var secondQuestionItalian: String!
    var status: String!

    required init(parameter: JSON) {
        self.status = parameter["status"].stringValue

        if (self.status == "success") {
            let dataArray = parameter["data"].arrayValue
            let data = dataArray[0]

            self.id = data["id"].intValue
            self.enabled = data["enabled"].stringValue == "y"

            self.firstQuestionGerman = data["first_question_de"].stringValue
            self.firstQuestionGerman = data["first_question_de"].stringValue
            self.firstQuestionEnglish = data["first_question_en"].stringValue
            self.firstQuestionItalian = data["first_question_it"].stringValue

            self.firstQuestionPlaceholderGerman = data["first_question_placeholder_de"].stringValue
            self.firstQuestionPlaceholderEnglish = data["first_question_placeholder_en"].stringValue
            self.firstQuestionPlaceholderItalian = data["first_question_placeholder_it"].stringValue

            self.secondQuestionGerman = data["second_question_de"].stringValue
            self.secondQuestionEnglish = data["second_question_en"].stringValue
            self.secondQuestionItalian = data["second_question_it"].stringValue
        }
    }

    static func collection(parameter: JSON) -> [SurveyItem] {
        var items: [SurveyItem] = []

        for itemRepresentation in parameter.arrayValue {
            items.append(SurveyItem(parameter: itemRepresentation))
        }

        return items
    }


    func getFirstQuestionLocalized() -> String {
        let language = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!
        if language as! String == "it" {
            return self.firstQuestionItalian
        } else if language as! String == "en" {
            return self.firstQuestionEnglish
        } else {
            return self.firstQuestionGerman
        }
    }

    func getSecondQuestionLocalized() -> String {
        let language = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!
        if language as! String == "it" {
            return self.secondQuestionItalian
        } else if language as! String == "en" {
            return self.secondQuestionEnglish
        } else {
            return self.secondQuestionGerman
        }
    }

    func getFirstQuestionPlaceholderLocalized() -> String {
        let language = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!
        if language as! String == "it" {
            return self.firstQuestionPlaceholderItalian
        } else if language as! String == "en" {
            return self.firstQuestionPlaceholderEnglish
        } else {
            return self.firstQuestionPlaceholderGerman
        }
    }
}
