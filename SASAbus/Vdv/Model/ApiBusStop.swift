import Foundation

class ApiBusStop: Hashable {
    
    let id: Int
    var seconds: Int
    var time: String
    
    var hashValue: Int {
        return id
    }
    
    init(id: Int) {
        self.id = id
        
        seconds = 0
        time = ""
    }
    
    func getId() -> Int {
        return id
    }
    
    func getSeconds() -> Int {
        return seconds
    }
    
    func setSeconds(seconds: Int) {
        self.seconds = seconds
        time = ApiUtils.getTime(seconds: seconds)
    }
    
    func getTime() -> String {
        return time
    }
    
    /*@Override
    public boolean equals(Object o) {
        return this == o || !(o == null || getClass() != o.getClass()) && id == ((BusStop) o).id;
    }*/
}
 
func == (lhs: ApiBusStop, rhs: ApiBusStop) -> Bool {
    return lhs.id == rhs.id
}
