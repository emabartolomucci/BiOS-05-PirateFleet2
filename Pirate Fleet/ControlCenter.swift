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
    
    init (location: GridLocation){
        self.location = location
        self.guaranteesHit = false
        self.penaltyText = "You just hit a mine"
    }
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
        
        let smallShip = Ship(length: 2, location: GridLocation(x: 1, y: 5), isVertical: true, isWooden: false)
        let mediumShip1 = Ship(length: 3, location: GridLocation(x: 2, y: 7), isVertical: false)
        let mediumShip2 = Ship(length: 3, location: GridLocation(x: 6, y: 3), isVertical: true)
        let largeShip = Ship(length: 4, location: GridLocation(x: 0, y: 1), isVertical: true)
        let xLargeShip = Ship(length: 5, location: GridLocation(x: 3, y: 1), isVertical: false)
        let mine1 = Mine(location: GridLocation(x: 5, y: 3), penaltyText: "Arrr!", guaranteesHit: true)
        let mine2 = Mine(location: GridLocation(x: 3, y: 5), penaltyText: "Arrr!")
        let seamonster1 = SeaMonster(location: GridLocation(x: 6, y: 6))
        let seamonster2 = SeaMonster(location: GridLocation(x: 2, y: 2))
        
        human.addShipToGrid(smallShip)
        human.addShipToGrid(mediumShip1)
        human.addShipToGrid(mediumShip2)
        human.addShipToGrid(largeShip)
        human.addShipToGrid(xLargeShip)
        human.addMineToGrid(mine1)
        human.addMineToGrid(mine2)
        human.addSeamonsterToGrid(seamonster1)
        human.addSeamonsterToGrid(seamonster2)
    }
    
    func calculateFinalScore(_ gameStats: GameStats) -> Int {
        
        var finalScore: Int
        
        let sinkBonus = (5 - gameStats.enemyShipsRemaining) * gameStats.sinkBonus
        let shipBonus = (5 - gameStats.humanShipsSunk) * gameStats.shipBonus
        let guessPenalty = (gameStats.numberOfHitsOnEnemy + gameStats.numberOfMissesByHuman) * gameStats.guessPenalty
        
        finalScore = sinkBonus + shipBonus - guessPenalty
        
        return finalScore
    }
}
