//
//  ControlCenter.swift
//  Pirate Fleet
//
//  Edited by Emanuele Bartolomucci on 2016/10/15.
//

struct GridLocation {
    let x: Int
    let y: Int
}

struct Ship {
    let length: Int
    let location: GridLocation
    let isVertical: Bool
    let isWooden: Bool
    
    var cells: [GridLocation] {
        get {
            let start = self.location
            let end: GridLocation = ShipEndLocation(self)
            var occupiedCells = [GridLocation]()
            
            for x in start.x...end.x {
                for y in start.y...end.y {
                    occupiedCells.append(GridLocation.init(x: x, y: y))
                }
            }
            return occupiedCells
        }
    }
    
    var hitTracker: HitTracker
    
    var sunk: Bool {
        for hit in self.hitTracker.cellsHit {
            if hit.1 == false {
                return false
            }
        }
        return true
    }
    
    init(length: Int, location: GridLocation, isVertical: Bool) {
        self.length = length
        self.location = location
        self.isVertical = isVertical
        self.isWooden = true
        self.hitTracker = HitTracker()
    }
    init (length: Int, location: GridLocation, isVertical: Bool, isWooden: Bool) {
        self.length = length
        self.location = location
        self.isVertical = isVertical
        self.isWooden = isWooden
        self.hitTracker = HitTracker()
        
    }
}

protocol PenaltyCell {
    var location: GridLocation {get}
    var guaranteesHit: Bool {get}
    var penaltyText: String {get}
}

struct Mine: PenaltyCell {
    let location: GridLocation
    let guaranteesHit: Bool
    let penaltyText: String

    init (location: GridLocation, penaltyText: String) {
        self.location = location
        self.guaranteesHit = false
        self.penaltyText = penaltyText
    }
    init (location: GridLocation, penaltyText: String, guaranteesHit: Bool) {
        self.location = location
        self.guaranteesHit = guaranteesHit
        self.penaltyText = penaltyText
    }
}

struct SeaMonster: PenaltyCell {
    let location: GridLocation
    let guaranteesHit: Bool
    let penaltyText: String
    
    init (location: GridLocation){
        self.location = location
        self.guaranteesHit = true
        self.penaltyText = "You just hit a sea monster"
    }
}

class ControlCenter {
    
    func placeItemsOnGrid(_ human: Human) {
        human.addShipToGrid(Ship(length: 2, location: GridLocation(x: 1, y: 5), isVertical: true, isWooden: false))  // Small
        human.addShipToGrid(Ship(length: 3, location: GridLocation(x: 2, y: 7), isVertical: false)) // Medium 1
        human.addShipToGrid(Ship(length: 3, location: GridLocation(x: 6, y: 3), isVertical: true))  // Medium 2
        human.addShipToGrid(Ship(length: 4, location: GridLocation(x: 0, y: 1), isVertical: true))  // Large
        human.addShipToGrid(Ship(length: 5, location: GridLocation(x: 3, y: 1), isVertical: false))  // Extra large
        human.addMineToGrid(Mine(location: GridLocation(x: 5, y: 3), penaltyText: "Arrr!", guaranteesHit: true))  // Mine 1
        human.addMineToGrid(Mine(location: GridLocation(x: 3, y: 5), penaltyText: "Arrr!"))  // Mine 2
        human.addSeamonsterToGrid(SeaMonster(location: GridLocation(x: 6, y: 6)))  // Seamonster 1
        human.addSeamonsterToGrid(SeaMonster(location: GridLocation(x: 2, y: 2)))  // Seamonster 2
    }
    
    func calculateFinalScore(_ gameStats: GameStats) -> Int {
        
        var finalScore: Int
        let scoreConstant: Int = 5
        
        let sinkBonus = (scoreConstant - gameStats.enemyShipsRemaining) * gameStats.sinkBonus
        let shipBonus = (scoreConstant - gameStats.humanShipsSunk) * gameStats.shipBonus
        let guessPenalty = (gameStats.numberOfHitsOnEnemy + gameStats.numberOfMissesByHuman) * gameStats.guessPenalty
        
        finalScore = sinkBonus + shipBonus - guessPenalty
        
        return finalScore
    }
}
