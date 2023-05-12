import SwiftUI

final class ZegzugGameViewModel: ObservableObject {
    @Published var circles = [ZegzugCircle]()
    @Published var showingHowTo = false
    @Published var playerOne: ZegzugPlayer = ZegzugPlayer(num: .first)
    @Published var playerTwo: ZegzugPlayer = ZegzugPlayer(num: .second)

    @Published private(set) var turnState: TurnState = .place
    @Published var numOfPebbles: Int = 0
    @Published var selectedIndex: Int? = nil

    @Published var orangeNeighbours: [Int] = [
        0,
        25,
        26,
        3,
        4,
        29,
        6,
        7,
        8,
        21,
        22,
        35,
        12,
        1,
        14,
        27,
        28,
        17,
        18,
        19,
        32,
        33,
        10,
        23,
        24,
        13,
        2,
        15,
        16,
        5,
        30,
        31,
        20,
        9,
        34,
        11,
    ]

    let greenNeighbours: [[Int]] = [
        [24, 12, 0],
        [25, 13, 1],
        [29, 17, 5],
        [32, 20, 8],
        [34, 22, 10],
        [27, 15, 3],
        [33, 21, 9],
        [28, 16, 4],
        [26, 14, 2],
        [35, 23, 11],
        [31, 19, 7],
        [30, 18, 6],
    ]

    var placedPebbles: Int {
        currentPlayer.placedPebbles
    }

    private var currentPlayer: ZegzugPlayer!

    init() {
        let startOuterX = 0.0
        let startInnerX = 0.25
        let startMiddleX = (startInnerX + startOuterX) / 2

        let startY = 0.5

        let outer = CGPoint(x: startOuterX, y: startY)
        let middle = CGPoint(x: startMiddleX, y: startY)
        let inner = CGPoint(x: startInnerX, y: startY)

        for _ in 0 ..< 12 {
            circles.append(ZegzugCircle(center: outer, state: .none))
        }

        for _ in 0 ..< 12 {
            circles.append(ZegzugCircle(center: middle, state: .none))
        }

        for _ in 0 ..< 12 {
            circles.append(ZegzugCircle(center: inner, state: .none))
        }

        // TODO: rotate by the stored value in the gameState
        rotateBoardBy(sections: 0)

        numOfPebbles = 5

        currentPlayer = playerOne
    }

    func normalizeCoords(for geo: GeometryProxy) {
        let rotationDegree: CGFloat = 30
        DispatchQueue.main.async { [unowned self] in
            for (index, circle) in circles.enumerated() {
                let newCenter = normalizeCoords(circle.center, in: geo).rotate(by: rotationDegree * CGFloat(index),
                                                                               around: middle(of: geo))
                // This guard is critical since the view could call this function multiple times, resulting in the
                // the coordinates being placed further and further off the screen. This prevents that.
                guard CGRectContainsPoint(geo.frame(in: .local).expanded(by: 40), newCenter) else { continue }
                circles[index].center = newCenter
            }
        }
    }

    func circleDiameter(in geo: GeometryProxy) -> CGFloat {
        geo.size.width / 14
    }

    func tapped(_ circle: ZegzugCircle) {
        switch turnState {
        case .place:
            placePebble(on: circle)
        case .select:
            selectPebble(on: circle)
        case .move:
            movePebble(to: circle)
        default:
            return
        }
        turnState = updateState()
    }

    private func updateState() -> TurnState {
        if didPlayerWin() {
            //return .won
        }
        if currentPlayer.areAllPebblesPlaced {
//            if selectedIndex == nil {
//                return .select
//            } else {
//                return .move
//            }
        }
        return .place
    }

    private func didPlayerWin() -> Bool {
        return countLongestOrangeLine() >= 5 || countLongestGreenLine() >= 5
    }

    private func countLongestOrangeLine() -> Int {
        var longest = 0
        for subarray in currentPlayer.orangeNeighbours {
            longest = subarray.count > longest ? subarray.count : longest
        }
        return longest
    }

    private func countLongestGreenLine() -> Int {
        var longest = 0
        for subarray in currentPlayer.greenNeighbours {
            // here are the [[ ]] arrays
            // compactMap is needed, but only if theres no intersection
            // check if theres an intersection
            var numOfMultipleTrios = 0
            for miniarray in subarray {
                if miniarray.count > 1 {
                    numOfMultipleTrios += 1
                }
            }

            if numOfMultipleTrios > 1 && subarray.count > 2 {
                // there is an intersection -> exception is if its 2 and they are the only elements
                // start counting the elements from the beginning until we fint a multipleTrio
                // then start again but this time the already found multipleTrio counts as 1 and we dont stop at it
                // the next startin gposition becomes the next [] and we count again
                // do this until we reach the end
                var visitedTrios = [[Int]]()
                var countedArrays = [[Int]]()
                var startingPos = 0
                while countedArrays.count != subarray.count {
                    var lengthOfCurrPath = 0
                    startingPos = countedArrays.count

                    var currPos = startingPos + 1
                    guard subarray.indices.contains(currPos) else { break }
                    lengthOfCurrPath += subarray[startingPos].count

                    if !visitedTrios.contains(subarray[startingPos]) {
                        visitedTrios.append(subarray[startingPos])
                    }

                    while subarray.indices.contains(currPos) && (subarray[currPos].count == 1 || visitedTrios.contains(subarray[currPos])) {
                        lengthOfCurrPath += 1
                        currPos += 1
                    }

                    guard subarray.indices.contains(currPos)
                    else {
                        countedArrays.append(subarray[startingPos])
                        visitedTrios.removeAll()
                        longest = lengthOfCurrPath > longest ? lengthOfCurrPath : longest
                        continue
                    }

                    lengthOfCurrPath += subarray[currPos].count
                    visitedTrios.append(subarray[currPos])
                    longest = lengthOfCurrPath > longest ? lengthOfCurrPath : longest

                    if visitedTrios.count == subarray.count {
                        countedArrays.append(subarray[startingPos])
                        visitedTrios.removeAll()
                    }
                }

            } else {
                // no intersecion
                longest = Array(subarray.joined()).count > longest ? Array(subarray.joined()).count : longest
            }
        }

        print(longest)
        return longest
    }

    private func placePebble(on circle: ZegzugCircle) {
        guard circle.state == .none,
              let index = circles.firstIndex(where: { $0.id == circle.id })
        else { return }

        circles[index].state = currentPlayer.circleState
        currentPlayer.placePebble(max: numOfPebbles)

        updateNeighbours(at: index)
        calculateLongestLine(for: currentPlayer)

        //TODO: toggle them ony after send button is pressed
        //togglePlayers()
    }

    private func selectPebble(on circle: ZegzugCircle) {
        guard circle.state == currentPlayer.circleState,
              let index = circles.firstIndex(where: { $0.id == circle.id })
        else { return }

        selectedIndex = index
    }

    private func movePebble(to circle: ZegzugCircle) {
        guard let index = circles.firstIndex(where: { $0.id == circle.id }),
              let selectedIndex
        else { return }

        if circles[index].state == currentPlayer.circleState {
            selectPebble(on: circle)
            return
        }

        if isNeighbour(index, to: selectedIndex) && [.none, currentPlayer.circleState].contains(circles[index].state) {
            removePebble(from: circles[selectedIndex])
            placePebble(on: circle)
            self.selectedIndex = nil
        } else {
            let currState = circles[index].state
            circles[index].state = .wrong
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.circles[index].state = currState
            }
        }
    }

    private func removePebble(from circle: ZegzugCircle) {
        guard let index = circles.firstIndex(where: { $0.id == circle.id }) else { return }
        circles[index].state = .none
        updateNeighbours(at: index)
        calculateLongestLine(for: currentPlayer)
    }

    private func togglePlayers() {
        currentPlayer = currentPlayer.num == .first ? playerTwo : playerOne
    }

    private func calculateLongestLine(for player: ZegzugPlayer) {

    }

    private func updateNeighbours(at index: Int) {
        switch circles[index].state {
        case .none:
            removeFromNeighbours(index)
        default:
            addToNeighbours(index)
        }
    }

    private func removeFromNeighbours(_ index: Int) {
        removeFromOrangeNeighbours(index, for: currentPlayer)
        removeFromGreenNeighbours(index, for: currentPlayer)
    }

    private func addToNeighbours(_ index: Int) {
        addToOrangeNeighbours(index, for: currentPlayer)
        addToGreenNeighbours(index, for: currentPlayer)
    }

    private func addToOrangeNeighbours(_ index: Int, for player: ZegzugPlayer) {
        func previousIndexWrapped(_ index: Int, in list: [Int]) -> Int {
            var lowerIndex = index - 1
            if lowerIndex < 0 {
                lowerIndex = list.endIndex - 1
            }
            return lowerIndex
        }

        func nextIndexWrapped(_ index: Int, in list: [Int]) -> Int {
            var upperIndex = index + 1
            if upperIndex >= list.endIndex {
                upperIndex = 0
            }
            return upperIndex
        }

        let isNeighbourClosure = { (index: Int, of: Int, list: [Int]) -> Bool in
            let upperIndex = nextIndexWrapped(index, in: list)
            let lowerIndex = previousIndexWrapped(index, in: list)
            return of == upperIndex || of == lowerIndex
        }

        let isBeforeNeighbourClosure = { (index: Int, of: Int, list: [Int]) -> Bool in
            let lowerIndex = previousIndexWrapped(index, in: list)
            return of == lowerIndex
        }

        let indexes = getIndexes(of: player.orangeNeighbours, in: orangeNeighbours)
        let nIndex = orangeNeighbours.firstIndex(of: index)!

        let isNeighbour = indexes.contains { $0.contains { isNeighbourClosure(nIndex, $0, orangeNeighbours) } }
        if isNeighbour {
            // either the previous or next neighbour is already in the list
            // find it and insert current into the right place
            let isBefore = indexes.contains { $0.contains { isBeforeNeighbourClosure(nIndex, $0, orangeNeighbours) } }
            if isBefore {
                // ex: index = 11. Found neighbour is 10. Find it and insert it after.
                let outerIndex = indexes.firstIndex {
                    $0.contains { isBeforeNeighbourClosure(nIndex, $0, orangeNeighbours) }
                }!
                let innerIndex = indexes[outerIndex].firstIndex(of: previousIndexWrapped(nIndex, in: orangeNeighbours))!
                player.orangeNeighbours[outerIndex].insert(index, at: innerIndex + 1)
            } else {
                // ex index = 11, found 12. Insert it before the found one.
                let outerIndex = indexes.firstIndex {
                    $0.contains { $0 == nextIndexWrapped(nIndex, in: orangeNeighbours) }
                }!
                let innerIndex = indexes[outerIndex].firstIndex(of: nextIndexWrapped(nIndex, in: orangeNeighbours))!
                player.orangeNeighbours[outerIndex].insert(index, at: innerIndex)
            }
        } else {
            // not a neighbour to any pressed circles, just insert to correct place
            let insertIndex = indexes.firstIndex(where: { $0.contains { $0 > nIndex } }) ?? indexes.endIndex
            player.orangeNeighbours.insert([index], at: insertIndex)
        }

        func areNeighbours(_ item1: Int, and item2: Int, in list: [Int]) -> Bool {
            guard let index = list.firstIndex(of: item1) else { return false }
            let nextIndex = index + 1 >= list.endIndex ? 0 : index + 1
            return list[nextIndex] == item2
        }

        // check if adjecent arrays coud be merged together (their outer most items are neighbours)
        var toBeMergedIndexes = [[Int]]()
        for (arrayIndex, array) in player.orangeNeighbours.enumerated() {
            guard player.orangeNeighbours.indices.contains(arrayIndex + 1) else { break }
            let nextArray = player.orangeNeighbours[arrayIndex + 1]
            if areNeighbours(array.last!, and: nextArray.first!, in: orangeNeighbours) {
                toBeMergedIndexes.append([arrayIndex, arrayIndex + 1])
            }
        }
        // if we have indexes in multiple pairs ex: [0, 1], [1, 2], we merge these to be [0, 1, 2]
        toBeMergedIndexes = mergeCommonItemSubarrays(in: toBeMergedIndexes)

        player.orangeNeighbours = mergeSubarrays(player.orangeNeighbours, from: toBeMergedIndexes)
    }

    private func removeFromOrangeNeighbours(_ element: Int, for player: ZegzugPlayer) {
        guard let outerIndex = player.orangeNeighbours.firstIndex(where: { $0.contains(element) }) else { return }

        let index = player.orangeNeighbours[outerIndex].firstIndex(of: element)!
        var subArr = player.orangeNeighbours[outerIndex]

        if player.orangeNeighbours[outerIndex].first! == element || player.orangeNeighbours[outerIndex].last! == element {
            subArr.remove(at: index)
            if subArr.count > 0 {
                player.orangeNeighbours = Array(player.orangeNeighbours[..<outerIndex]
                                                + [Array(subArr)]
                                                + player.orangeNeighbours[(outerIndex + 1)...])
            } else {
                player.orangeNeighbours = Array(player.orangeNeighbours[..<outerIndex] + player.orangeNeighbours[(outerIndex + 1)...])
            }
        } else {
            subArr.remove(at: index)
            player.orangeNeighbours = Array(player.orangeNeighbours[..<outerIndex]
                                            + [Array(subArr[..<index]), Array(subArr[index...])]
                                            + player.orangeNeighbours[(outerIndex + 1)...])
        }
    }

    private func addToGreenNeighbours(_ index: Int, for player: ZegzugPlayer) {
        func previousIndexWrapped(_ index: Int, in list: [[Int]]) -> Int {
            var lowerIndex = index - 1
            if lowerIndex < 0 {
                lowerIndex = list.endIndex - 1
            }
            return lowerIndex
        }

        func nextIndexWrapped(_ index: Int, in list: [[Int]]) -> Int {
            var upperIndex = index + 1
            if upperIndex >= list.endIndex {
                upperIndex = 0
            }
            return upperIndex
        }

        let isNeighbourClosure = { (index: Int, of: Int, list: [[Int]]) -> Bool in
            let upperIndex = nextIndexWrapped(index, in: list)
            let lowerIndex = previousIndexWrapped(index, in: list)
            return of == upperIndex || of == lowerIndex
        }

        let isBeforeNeighbourClosure = { (index: Int, of: Int, list: [[Int]]) -> Bool in
            let lowerIndex = previousIndexWrapped(index, in: list)
            return of == lowerIndex
        }

        let isAfterNeighbourClosure = { (index: Int, of: Int, list: [[Int]]) -> Bool in
            let upperIndex = nextIndexWrapped(index, in: list)
            return of == upperIndex
        }

        var indexes = getIndexes(of: player.greenNeighbours, in: greenNeighbours)
        let outerIndexOfPressed = greenNeighbours.firstIndex(where: { $0.contains(index) })!
        let innerIndexOfPressed = greenNeighbours[outerIndexOfPressed].firstIndex(of: index)!

        // check if this outerIndex is in indexes already
        let isAlreadyInIndexes = indexes.contains { $0.contains(outerIndexOfPressed) }

        // check if neighbouring index is in list already
        let isNeighbourInList = indexes.contains { $0.contains { isNeighbourClosure(outerIndexOfPressed, $0, greenNeighbours) } }

        if isAlreadyInIndexes {
            var matchingIndexIndex = indexes.firstIndex(where: { $0.contains(outerIndexOfPressed) })!
            var innerMatchingIndex = indexes[matchingIndexIndex].firstIndex(of: outerIndexOfPressed)!

            // element from this outerIndex has already been pressed
            // check if they are neighbours
            if player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].count == 1 && innerIndexOfPressed != 0 {
                // from subarray [24, 12, 0] the pressed could be 24 and the newly pressed is 0. They are not neighbours.
                let onlyElement = player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].first!
                let indexOfContaining = greenNeighbours[outerIndexOfPressed].firstIndex(of: onlyElement)!

                if !nextToEachother(innerIndexOfPressed, and: indexOfContaining) {
                    // not neighbours, insert into new subarray
                    let insertIndex = index > onlyElement ?
                    matchingIndexIndex : matchingIndexIndex + 1
                    player.greenNeighbours.insert([[index]], at: insertIndex)
                } else {
                    // neighbours
                    // should check if both neighbours were added previously
                    let bothAdded = indexes.filter({ $0.contains(outerIndexOfPressed)}).count == 2

                    if !bothAdded {
                        let insertInnerIndex = index > onlyElement ? 0 : 1
                        player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].insert(index, at: insertInnerIndex)
                    } else {
                        //both added -> merge them
                        if player.greenNeighbours[matchingIndexIndex].count == 1 {
                            let removed = player.greenNeighbours[matchingIndexIndex].remove(at: innerMatchingIndex)
                            player.greenNeighbours.remove(at: matchingIndexIndex)
                            indexes = getIndexes(of: player.greenNeighbours, in: greenNeighbours)
                            matchingIndexIndex = indexes.firstIndex(where: { $0.contains(outerIndexOfPressed) })!
                            innerMatchingIndex = indexes[matchingIndexIndex].firstIndex(of: outerIndexOfPressed)!
                            player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].insert(contentsOf: removed + [index], at: 0)
                        } else {
                            player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].append(index)
                            let nextIndex = player.greenNeighbours.firstIndex { $0.contains{ $0.contains(greenNeighbours[outerIndexOfPressed][innerIndexOfPressed + 1]) } }!
                            if player.greenNeighbours[nextIndex].count == 1 {
                                player.greenNeighbours.remove(at: nextIndex)
                            } else {
                                player.greenNeighbours[nextIndex].remove(at: 0)
                            }
                            player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].append(greenNeighbours[outerIndexOfPressed][innerIndexOfPressed + 1])
                        }
                    }
                }
            } else if isNeighbourInList && innerIndexOfPressed == 0 {
                let isBefore = indexes.contains { $0.contains { isBeforeNeighbourClosure(outerIndexOfPressed, $0, greenNeighbours) } }
                let isAfter = indexes.contains { $0.contains { isAfterNeighbourClosure(outerIndexOfPressed, $0, greenNeighbours) } }
                if isBefore {
                    let neigbourIndex = previousIndexWrapped(outerIndexOfPressed, in: greenNeighbours)
                    let zeroIndexElement = greenNeighbours[neigbourIndex].first!
                    // check if neighbouring subarray(s) has the 0 index element in it
                    let possibleNeighbourIndex1 = previousIndexWrapped(matchingIndexIndex, in: indexes)
                    let possibleNeighbourIndex2 = previousIndexWrapped(possibleNeighbourIndex1, in: indexes)

                    if player.greenNeighbours[possibleNeighbourIndex1].contains(where: { $0.contains(zeroIndexElement) }) || player.greenNeighbours[possibleNeighbourIndex2].contains(where: { $0.contains(zeroIndexElement) }) {

                        var removed = [[Int]]()
                        if indexes[possibleNeighbourIndex2].contains(neigbourIndex) {
                            // its in the second array from the currently pressed
                            removed = player.greenNeighbours.remove(at: possibleNeighbourIndex2)
                        } else {
                            // its in the first
                            removed = player.greenNeighbours.remove(at: possibleNeighbourIndex1)
                        }
                        indexes = getIndexes(of: player.greenNeighbours, in: greenNeighbours)
                        matchingIndexIndex = indexes.firstIndex(where: { $0.contains(outerIndexOfPressed) })!
                        player.greenNeighbours[matchingIndexIndex].insert(contentsOf: removed, at: 0)
                        indexes = getIndexes(of: player.greenNeighbours, in: greenNeighbours)
                        matchingIndexIndex = indexes.firstIndex(where: { $0.contains(outerIndexOfPressed) })!
                        innerMatchingIndex = indexes[matchingIndexIndex].firstIndex(of: outerIndexOfPressed)!
                    }

                    if !isAfter {
                        player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].insert(index, at: 0)
                    }
                }
                if isAfter {
                    let neigbourIndex = nextIndexWrapped(outerIndexOfPressed, in: greenNeighbours)
                    let zeroIndexElement = greenNeighbours[neigbourIndex].first!

                    // check if neighbouring subarray(s) has the 0 index element in it
                    let possibleNeighbourIndex1 = nextIndexWrapped(matchingIndexIndex, in: indexes)

                    if player.greenNeighbours[possibleNeighbourIndex1].contains(where: { $0.contains(zeroIndexElement) }) {
                        // check if existing index is next to the new index
                        let existing = player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].first!
                        let indexOfContaining = greenNeighbours[outerIndexOfPressed].firstIndex(of: existing)!
                        if nextToEachother(innerIndexOfPressed, and: indexOfContaining) {
                            var removed = [[Int]]()
                            removed = player.greenNeighbours.remove(at: possibleNeighbourIndex1)

                            indexes = getIndexes(of: player.greenNeighbours, in: greenNeighbours)
                            matchingIndexIndex = indexes.firstIndex(where: { $0.contains(outerIndexOfPressed) })!
                            player.greenNeighbours[matchingIndexIndex].append(contentsOf: removed)
                            indexes = getIndexes(of: player.greenNeighbours, in: greenNeighbours)
                            matchingIndexIndex = indexes.firstIndex(where: { $0.contains(outerIndexOfPressed) })!
                            innerMatchingIndex = indexes[matchingIndexIndex].firstIndex(of: outerIndexOfPressed)!
                        } else {
                            player.greenNeighbours[possibleNeighbourIndex1].insert([index], at: 0)
                        }
                        if !player.greenNeighbours.contains(where: { $0.contains { $0.contains(index) } }) {
                            player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].insert(index, at: 0)
                        }
                    }
                }
            } else if innerIndexOfPressed == 0 {
                if player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].count == 1 {
                    // should check if they are neighbours
                    let onlyElement = player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].first!
                    let indexOfContaining = greenNeighbours[outerIndexOfPressed].firstIndex(of: onlyElement)!
                    if nextToEachother(innerIndexOfPressed, and: indexOfContaining) {
                        player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].insert(index, at: 0)
                    } else {
                        player.greenNeighbours.insert([[index]], at: matchingIndexIndex)
                    }
                } else {
                    player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].insert(index, at: 0)
                }
            } else {
                player.greenNeighbours[matchingIndexIndex][innerMatchingIndex].append(index)
            }
        } else if isNeighbourInList && innerIndexOfPressed == 0 {
            // find out if neighbour is smaller or bigger than index. or both
            let isBefore = indexes.contains { $0.contains { isBeforeNeighbourClosure(outerIndexOfPressed, $0, greenNeighbours) } }
            let isAfter = indexes.contains { $0.contains { isAfterNeighbourClosure(outerIndexOfPressed, $0, greenNeighbours) } }

            if isBefore {
                let neigbourIndex = previousIndexWrapped(outerIndexOfPressed, in: greenNeighbours)
                let zeroIndexElement = greenNeighbours[neigbourIndex].first!

                if let zeroElementOuterIndex = player.greenNeighbours.firstIndex(where: { $0.contains(where: { $0.contains(zeroIndexElement)})}) {
                    var offset = indexes.filter({ $0.contains(neigbourIndex) }).count
                    var indexOfPressedIndex = zeroElementOuterIndex + offset

                    // check if neighbouring subarray(s) has the 0 index element in it
                    let possibleNeighbourIndex1 = previousIndexWrapped(indexOfPressedIndex, in: indexes)
                    let possibleNeighbourIndex2 = previousIndexWrapped(possibleNeighbourIndex1, in: indexes)

                    if player.greenNeighbours[possibleNeighbourIndex1].contains(where: { $0.contains(zeroIndexElement) }) || player.greenNeighbours[possibleNeighbourIndex2].contains(where: { $0.contains(zeroIndexElement) }) {
                        var removed = [[Int]]()
                        if indexes[possibleNeighbourIndex2].contains(neigbourIndex) {
                            // its in the second array from the currently pressed
                            removed = player.greenNeighbours.remove(at: possibleNeighbourIndex2)
                            indexes = getIndexes(of: player.greenNeighbours, in: greenNeighbours)
                            offset = indexes.filter({ $0.contains(neigbourIndex) }).count
                            indexOfPressedIndex = zeroElementOuterIndex + offset
                            player.greenNeighbours.insert(removed, at: indexOfPressedIndex)
                            player.greenNeighbours[indexOfPressedIndex].append([index])
                        }
                    }
                    if !player.greenNeighbours.contains(where: { $0.contains { $0.contains(index) } }) {
                        player.greenNeighbours[zeroElementOuterIndex].append([index])
                    }
                } else {
                    let indexOfNeighbour = player.greenNeighbours.firstIndex { $0.contains { Set($0).intersection(Set(greenNeighbours[neigbourIndex])).count > 0 } }!
                    player.greenNeighbours.insert([[index]], at: indexOfNeighbour + 1)
                }
            }
            if isAfter {
                let neigbourIndex = nextIndexWrapped(outerIndexOfPressed, in: greenNeighbours)
                let zeroIndexElement = greenNeighbours[neigbourIndex].first!

                let hasBeenWrittenIn = player.greenNeighbours.contains { $0.contains { $0.contains(index) } }
                let zeroElementOuterIndex = player.greenNeighbours.firstIndex(where: { $0.contains(where: { $0.contains(zeroIndexElement)})})
                var removed: [[Int]]? = nil

                if hasBeenWrittenIn && zeroElementOuterIndex != nil {
                    // needs to be deleted
                    let outerIndexOfElement = player.greenNeighbours.firstIndex { $0.contains([index]) }!
                    removed = player.greenNeighbours.remove(at: outerIndexOfElement)
                } else if !hasBeenWrittenIn && zeroElementOuterIndex == nil {
                    // add it without merge
                    let indexOfNeighbour = player.greenNeighbours.firstIndex { $0.contains { Set($0).intersection(Set(greenNeighbours[neigbourIndex])).count > 0 } }!
                    player.greenNeighbours.insert([[index]], at: indexOfNeighbour)
                }
                if zeroElementOuterIndex != nil {
                    // add with merge
                    if let outerIndexOfZero = player.greenNeighbours.firstIndex(where: { $0.contains { $0.contains(zeroIndexElement) } }) {
                        if let removed {
                            player.greenNeighbours[outerIndexOfZero].insert(contentsOf: removed, at: 0)
                        } else {
                            player.greenNeighbours[outerIndexOfZero].insert([index], at: 0)
                        }
                    } else {
                        // no element in array
                        if let removed {
                            player.greenNeighbours.insert(removed, at: 0)
                        } else {
                            player.greenNeighbours.insert([[index]], at: 0)
                        }
                    }
                }
            }
        } else {
            // find the index of first bigger index in indexes, indert it before that
            let insertIndex = indexes.firstIndex(where: { $0.contains { $0 > outerIndexOfPressed } }) ?? indexes.endIndex
            player.greenNeighbours.insert([[index]], at: insertIndex)
        }
    }

    private func removeFromGreenNeighbours(_ index: Int, for player: ZegzugPlayer) {
        // first, find out if index is in pos 0, 1 or 2 in the neighbours list
        let outerIndexOfPressed = greenNeighbours.firstIndex(where: { $0.contains(index)})!
        let innerIndexOfPressed = greenNeighbours[outerIndexOfPressed].firstIndex(of: index)!

        guard
            let outerIndexInNeighbours = player.greenNeighbours.firstIndex(where: { $0.contains { $0.contains(index) } }),
            let innerIndexInNeighbours = player.greenNeighbours[outerIndexInNeighbours].firstIndex(where: { $0.contains(index) }),
            let concreteIndexInNeighbours = player.greenNeighbours[outerIndexInNeighbours][innerIndexInNeighbours].firstIndex(of: index)
        else { return }

        if innerIndexOfPressed == 2 {
            // this is the easiest, just remove the pressed element from the list
            // first, check if its the only element in the list
            if player.greenNeighbours[outerIndexInNeighbours].count == 1 &&
                player.greenNeighbours[outerIndexInNeighbours][innerIndexInNeighbours].count == 1 {
                player.greenNeighbours.remove(at: outerIndexInNeighbours)
            } else if player.greenNeighbours[outerIndexInNeighbours][innerIndexInNeighbours].count == 1 {
                player.greenNeighbours[outerIndexInNeighbours].remove(at: innerIndexOfPressed)
            } else {
                player.greenNeighbours[outerIndexInNeighbours][innerIndexInNeighbours].remove(at: concreteIndexInNeighbours)
            }
        } else if innerIndexOfPressed == 1 {
            player.greenNeighbours[outerIndexInNeighbours][innerIndexInNeighbours].remove(at: concreteIndexInNeighbours)
            if player.greenNeighbours[outerIndexInNeighbours][innerIndexInNeighbours].count > 1 {
                let removedLastElement = player.greenNeighbours[outerIndexInNeighbours][innerIndexInNeighbours].remove(at: concreteIndexInNeighbours)
                player.greenNeighbours.insert([[removedLastElement]], at: outerIndexInNeighbours + 1)
            }
        } else if innerIndexOfPressed == 0 {
            // check if innerIndex is at the edge of the array
            if innerIndexInNeighbours == 0 ||
                innerIndexInNeighbours == player.greenNeighbours[outerIndexInNeighbours].endIndex - 1 {
                //at the edge, just delete it and insert other element in a new array
                if player.greenNeighbours[outerIndexInNeighbours].count == 1 &&
                    player.greenNeighbours[outerIndexInNeighbours][innerIndexInNeighbours].count == 1 {
                    player.greenNeighbours.remove(at: outerIndexInNeighbours)
                } else if player.greenNeighbours[outerIndexInNeighbours][innerIndexInNeighbours].count == 1 {
                    player.greenNeighbours[outerIndexInNeighbours].remove(at: innerIndexInNeighbours)
                } else {
                    player.greenNeighbours[outerIndexInNeighbours][innerIndexInNeighbours].remove(at: concreteIndexInNeighbours)
                    let removed = player.greenNeighbours[outerIndexInNeighbours].remove(at: innerIndexInNeighbours)

                    if innerIndexInNeighbours == 0 {
                        player.greenNeighbours.insert([removed], at: outerIndexInNeighbours)
                    } else {
                        player.greenNeighbours.insert([removed], at: outerIndexInNeighbours + 1)
                    }
                }
            } else {
                // in the middle
                // subarray needs separation
                var removed = player.greenNeighbours[outerIndexInNeighbours].removeAndReturnSubrange(innerIndexInNeighbours ..< player.greenNeighbours[outerIndexInNeighbours].endIndex)
                removed[0].remove(at: 0)
                let removedWithoutNeighbours = removed.remove(at: 0)
                if removedWithoutNeighbours.count > 0 {
                    player.greenNeighbours.insert([removedWithoutNeighbours], at: outerIndexInNeighbours + 1)
                    player.greenNeighbours.insert(removed, at: outerIndexInNeighbours + 2)
                } else {
                    player.greenNeighbours.insert(removed, at: outerIndexInNeighbours + 1)
                }
            }
        }
    }

    private func getIndexes(of list: [[Int]], in parent: [Int]) -> [[Int]] {
        var indexes = [[Int]]()
        for outer in list {
            indexes.append([])
            for inner in outer {
                indexes[indexes.endIndex - 1].append(parent.firstIndex(of: inner)!)
            }
        }
        return indexes
    }

    private func getIndexes(of list: [[[Int]]], in parent: [[Int]]) -> [[Int]] {
        var indexes = [[Int]]()
        for outer in list {
            indexes.append([])
            for inner in outer {
                guard inner.count > 0 else { continue }
                let parentOuterI = parent.firstIndex(where: { $0.contains(inner.first!)})!
                indexes[indexes.endIndex - 1].append(parentOuterI)
            }
        }
        return indexes
    }

    private func mergeSubarrays(_ arr: [[Int]], from idx: [[Int]]) -> [[Int]] {
        guard idx.flatMap({ $0 }).count > 0 else { return arr }

        var result = [[Int]]()
        var mergedArr = [Int]()
        var currentIdx = 0
        for subIdx in idx {
            for i in currentIdx..<subIdx[0] {
                result.append(arr[i])
            }
            for i in subIdx {
                mergedArr.append(contentsOf: arr[i])
            }
            currentIdx = subIdx.last! + 1
        }
        for i in currentIdx..<arr.count {
            result.append(arr[i])
        }
        if mergedArr.count > 0 {
            result.insert(mergedArr, at: idx[0][0])
        }
        return result
    }

    private func mergeCommonItemSubarrays(in neighbourList: [[Int]]) -> [[Int]] {
        var merged = [[Int]]()
        var current = [Int]()

        for subarray in neighbourList {
            if current.isEmpty {
                current = subarray
            } else {
                if current.last == subarray.first {
                    current.append(contentsOf: subarray.dropFirst())
                } else if current.first == subarray.last {
                    current.insert(contentsOf: subarray.dropLast(), at: 0)
                } else {
                    merged.append(current)
                    current = subarray
                }
            }
        }

        merged.append(current)
        return merged
    }

    private func nextToEachother(_ first: Int, and second: Int) -> Bool {
        abs(first - second) == 1
    }

    private func isNeighbour(_ index: Int, to other: Int) -> Bool {
        guard let indexInOrange = orangeNeighbours.firstIndex(of: index),
              let otherIndexinOrange = orangeNeighbours.firstIndex(of: other)
        else { return false }
        if nextToEachother(indexInOrange, and: otherIndexinOrange) {
            return true
        }

        guard let outerIndexinGreen = greenNeighbours.firstIndex(where: { $0.contains(index)}),
              let otherOuterIndexinGreen = greenNeighbours.firstIndex(where: { $0.contains(other)}),
              let innerIndex = greenNeighbours[outerIndexinGreen].firstIndex(of: index),
              let otherInnerIndex = greenNeighbours[otherOuterIndexinGreen].firstIndex(of: other)
        else { return false }
        if outerIndexinGreen == otherOuterIndexinGreen {
            return nextToEachother(innerIndex, and: otherInnerIndex)
        }
        if nextToEachother(outerIndexinGreen, and: otherOuterIndexinGreen) || abs(outerIndexinGreen - otherOuterIndexinGreen) == 11 {
            return innerIndex == 0 && otherInnerIndex == 0
        }
        return false
    }

    private func middle(of geo: GeometryProxy) -> CGPoint {
        CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
    }

    private func normalizeCoords(_ center: CGPoint, in geo: GeometryProxy) -> CGPoint {
        CGPoint(x: center.x * geo.size.width + circleDiameter(in: geo) / 2, y: center.y * geo.size.height)
    }

    private func rotateBoardBy(sections: Int) {
        orangeNeighbours = orangeNeighbours.map { nIndex in
            offsetIndex(nIndex, by: sections)
        }
    }

    private func offsetIndex(_ index: Int, by offset: Int) -> Int {
        let newIndex = (index + offset)
        if index < 12 {
            return newIndex % 12
        }
        if index < 24 {
            return newIndex >= 24 ? newIndex % 24 + 12 : newIndex % 24
        }
        return newIndex >= 36 ? newIndex % 36 + 24 : newIndex % 36
    }
}
