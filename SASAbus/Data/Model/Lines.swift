import Foundation

class Lines {

    static var ORDER = [Int]()

    static func setup() {
        ORDER.append(1001)
        ORDER.append(1003)
        ORDER.append(1005)
        ORDER.append(1006)
        ORDER.append(1071)
        ORDER.append(1072)
        ORDER.append(1008)
        ORDER.append(1009)
        ORDER.append(1101)
        ORDER.append(1102)
        ORDER.append(1011)
        ORDER.append(1012)
        ORDER.append(1014)
        ORDER.append(110)
        ORDER.append(111)
        ORDER.append(112)
        ORDER.append(116)
        ORDER.append(117)
        ORDER.append(1153)
        ORDER.append(183)
        ORDER.append(201)
        ORDER.append(202)
        ORDER.append(1)
        ORDER.append(2)
        ORDER.append(3)
        ORDER.append(4)
        ORDER.append(6)
        ORDER.append(13)
        ORDER.append(211)
        ORDER.append(212)
        ORDER.append(213)
        ORDER.append(214)
        ORDER.append(215)
        ORDER.append(221)
        ORDER.append(222)
        ORDER.append(223)
        ORDER.append(224)
        ORDER.append(225)
        ORDER.append(248)
    }

    static func lidToName(id: Int) -> String {
        if id >= 1000 && id != 1071 && id != 1072 && id != 1101 && id != 1102 {
            return "\(id - 1000)"
        } else if id == 1071 {
            return "7A"
        } else if id == 1072 {
            return "7B"
        } else if id == 1101 {
            return "10A"
        } else if id == 1102 {
            return "10B"
        }

        return "\(id)"
    }

    static func line(id: Int) -> String {
        return NSLocalizedString("line", value: "Line", comment: "Line") + " " + lidToName(id: id)
    }

    static func line(name: String) -> String {
        return NSLocalizedString("line", value: "Line", comment: "Line") + " " + name
    }

    static func lines(name: String) -> String {
        return NSLocalizedString("linee", value: "Lines", comment: "Lines") + " " + name
    }

    static let allLines: [Int] = [
            -1,
            -2,
            1001,
            1003,
            1005,
            1006,
            1071,
            1072,
            1008,
            1009,
            1101,
            1102,
            1011,
            1012,
            1014,
            110,
            111,
            112,
            116,
            117,
            1153,
            183,
            201,
            202,
            1,
            2,
            3,
            4,
            6,
            146,
            211,
            212,
            213,
            214,
            215,
            221,
            222,
            223,
            224,
            225,
            248
    ]

    static let municipalities = [
            "", // Route network of Bolzano
            "", // Route network of Merano
            "BZ", // 1001
            "BZ", // 1003
            "BZ", // 1005
            "BZ", // 1006
            "BZ", // 1071
            "BZ", // 1072
            "BZ", // 1008
            "BZ", // 1009
            "BZ", // 1101
            "BZ", // 1102
            "BZ", // 1011
            "BZ", // 1012
            "BZ", // 1014
            "BZ", // 110
            "BZ", // 111
            "BZ", // 112
            "BZ", // 116
            "BZ", // 117
            "BZ", // 1153
            "BZ", // 183
            "BZ", // 201
            "BZ", // 202
            "ME", // 1
            "ME", // 2
            "ME", // 3
            "ME", // 4
            "ME", // 6
            "ME", // 146
            "ME", // 211
            "ME", // 212
            "ME", // 213
            "ME", // 214
            "ME", // 215
            "ME", // 221
            "ME", // 222
            "ME", // 223
            "ME", // 224
            "ME", // 225
            "ME"  // 248
    ]

    static let lineColors = [
            "FF9800", // All
            "FF9800", // None
            "FF9800", // BZ
            "FF9800", // ME
            "F44336", // 1001   1 BZ
            "E91E63", // 1003   3 BZ
            "795548", // 1005   5 BZ
            "009688", // 1006   6 BZ
            "FF9800", // 1071  7A BZ
            "FF9800", // 1072  7B BZ
            "8BC34A", // 1008   8 BZ
            "CDDC39", // 1009   9 BZ
            "F44336", // 1101 10A BZ
            "F44336", // 1102 10B BZ
            "FFD600", // 1011  11 BZ
            "9C27B0", // 1012  12 BZ
            "4CAF50", // 1014  14 BZ
            "2196F3", //  110 110 BZ
            "2962FF", //  111 111 BZ
            "9C27B0", //  112 112 BZ
            "3F51B5", //  116 116 BZ
            "3F51B5", //  117 117 BZ
            "9C27B0", // 1153 153 BZ
            "3F51B5", //  183 183 BZ
            "3F51B5", //  201 201 BZ
            "3F51B5", //  202 202 BZ
            "FF9800", //    1   1 ME
            "4CAF50", //    2   2 ME
            "2196F3", //    3   3 ME
            "FFD600", //    4   4 ME
            "9C27B0", //    6   6 ME
            "9C27B0", //  146 146 ME
            "F44336", //  211 211 ME
            "9C27B0", //  212 212 ME
            "009688", //  213 213 ME
            "3F51B5", //  214 214 ME
            "FFD600", //  215 215 ME
            "8BC34A", //  221 221 ME
            "3F51B5", //  222 222 ME
    ]

    static func getColorForId(id: Int) -> String {
        switch id {
        case 1001:
            return lineColors[4]
        case 1003:
            return lineColors[5]
        case 1005:
            return lineColors[6]
        case 1006:
            return lineColors[7]
        case 1071:
            return lineColors[8]
        case 1072:
            return lineColors[9]
        case 1008:
            return lineColors[10]
        case 1009:
            return lineColors[11]
        case 1101:
            return lineColors[12]
        case 1102:
            return lineColors[13]
        case 1011:
            return lineColors[14]
        case 1012:
            return lineColors[15]
        case 1014:
            return lineColors[16]
        case 110:
            return lineColors[17]
        case 111:
            return lineColors[18]
        case 112:
            return lineColors[19]
        case 116:
            return lineColors[20]
        case 117:
            return lineColors[21]
        case 1153:
            return lineColors[22]
        case 183:
            return lineColors[23]
        case 201:
            return lineColors[24]
        case 202:
            return lineColors[25]
        case 1:
            return lineColors[26]
        case 2:
            return lineColors[27]
        case 3:
            return lineColors[28]
        case 4:
            return lineColors[29]
        case 6:
            return lineColors[30]
        case 146:
            return lineColors[31]
        case 211:
            return lineColors[32]
        case 212:
            return lineColors[33]
        case 213:
            return lineColors[34]
        case 214:
            return lineColors[35]
        case 215:
            return lineColors[36]
        case 221:
            return lineColors[37]
        default:
            return "3F51B5"
        }
    }
}
