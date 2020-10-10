import Foundation


extension Substring.Element {
    func toInt() -> Int? {
        return Int(String(self))
    }
}

///Apply directions in which the bot should go on the y axis, respectively  N ->  North, S -> South.
/// - Parameters:
///   - yPoint: Current y coordinate.
///   - yPointToGo: y coordinate to be reached.
///   - outputDirectionString: Current directions.
func setYAxisInstruction(from yPoint: Int, to yPointToGo: Int, _ outputDirectionString: inout String) {
    if yPoint < yPointToGo {
        outputDirectionString.append("N")
    }
    if yPoint > yPointToGo {
        outputDirectionString.append("S")
    }
}

/// Apply directions in which the bot should go on the x axis, respectively  E ->  East, W -> West.
/// - Parameters:
///   - xPoint: Current x coordinate.
///   - xPointToGo: x coordinate to be reached.
///   - outputDirectionString: Current directions.
func setXAxisInstruction(from xPoint: Int, to xPointToGo: Int, _ outputDirectionString: inout String) {
    if xPointToGo > xPoint {
        outputDirectionString.append("E")
    }
    if xPointToGo < xPoint {
        outputDirectionString.append("W")
    }
}


/// Check if reached x,y coordinates are the same as the drop location coordinates.
/// - Parameters:
///   - x: Current x coordinate.
///   - y: Current y coordinate.
///   - dropLocation: Drop location for the pizza.
/// - Returns: true if x and y are equal to the drop location coordinates for the pizza.
func shouldDropPizzaAt(x: Int, y: Int, for dropLocation: (x: Int, y: Int)) -> Bool {
    return x == dropLocation.x && y == dropLocation.y
}

/// Generate directions from given x,y points.
///
///  This function is used to generate directions from given points, by going from one point to another.
///
///  The algorithm is also taking in consideration of changing sudden direction like going from East to West and backwards, the same applies for South/North.
///
/// - Note:
///     We don't need to know the size of the matrix in order for directions to be generated, the algorithm will automatically expand the matrix.
/// - Parameters:
///   - points: Points to generate directions from.
///   - xPosition: Last reached x axis position.
///   - yPosition: Last reached y axis position.
///   - directionsString: Current directions.
///   - completion: The block to execute after the directions generation is finished. This block takes one parameter String, representing the generated directions.
func generateDirectionsForPizzaDelivery(from points: [(x: Int, y: Int)], xPosition: Int = 0, yPosition: Int = 0, directionsString: String = "", completion: @escaping((String) -> Void)) {
    
    var currentDirectionsString = directionsString
    var currentPoints = points
    let dropLocation = currentPoints.removeLast()
    
    /**
     Check if drop x position is less than previous reached x position, if yes we need to go in West direction, otherwise we can continue in East direction.
     */
    let strideDirectionX = dropLocation.x < xPosition ? -1 : 1
    
    for reachedXPoint in stride(from: xPosition, through: dropLocation.x, by: strideDirectionX) {
        setXAxisInstruction(from: reachedXPoint, to: dropLocation.x, &currentDirectionsString)
        
        /**
         Check if drop y position is less than previous reached y position, if yes we need to go in South direction, otherwise we can continue in North direction.
         */
        let strideDirectionY = dropLocation.y < yPosition ? -1 : 1
        
        for reachedYPoint in stride(from: yPosition, through: dropLocation.y, by: strideDirectionY) {
            let willDropPizza = shouldDropPizzaAt(x: reachedXPoint, y: reachedYPoint, for: dropLocation)
            if willDropPizza {
                currentDirectionsString.append("D")
                
                /**
                 If no points are left in the array we tell the bot that we generated the directions and he is ready to deliver the pizza's.
                 */
                guard !currentPoints.isEmpty else {
                    completion(currentDirectionsString)
                    break
                }
                generateDirectionsForPizzaDelivery(
                    from: currentPoints,
                    xPosition: reachedXPoint,
                    yPosition: reachedYPoint,
                    directionsString: currentDirectionsString,
                    completion: completion
                )
                break
            }
            if reachedXPoint == dropLocation.x {
                setYAxisInstruction(from: reachedYPoint, to: dropLocation.y, &currentDirectionsString)
            }
        }
    }
}

///Generates directions from given input points.
///
/// - Note:
///   We don't need to know the size of the matrix in order for directions to be generated, the algorithm will automatically expand the matrix.
///
/// - Parameters:
///   - input: Should be in format `5x5 (1, 3) (4, 4)`
///   - output: The expected directions to be generated from the input. Output should always be uppercased, if you provide it lowercased the directions will not be correct.
///   - generateMatrix: Specify true if matrix should be created, or false if you don't want to create matrix. Default value is true.
func pizzabot(input: String, output: String, generateMatrix: Bool = true) {
    let split = input.split(separator: " ", maxSplits: generateMatrix ? 1 : 0)
    if generateMatrix {
        assert(!split.isEmpty, "Input can't be empty")
        assert(split.count == 2, "Invalid input. Example input: 5x5 (1, 3) (4, 4)")
        assert(!output.isEmpty, "Output can't be empty")
        
        guard let digits = split.first?.components(separatedBy: CharacterSet.decimalDigits.inverted) else {
            fatalError("Invalid input, please specify correct matrix size, for example 5x5")
        }
        
        assert(!digits.isEmpty, "Matrix size can't be empty. Please specify correct matrix size, for example 5x5")
        let matrixSize = digits.compactMap { Int($0) }
        assert(matrixSize.count == 2, "Matrix size not correct. Please specify correct matrix size, for example 5x5")
        
        print("--- Generating matrix 5x5 ---\n")
        let rows = Array(0..<matrixSize[0])
        let matrix = Array(repeating: rows, count: matrixSize[1])
        print("--- Matrix generated ---\n")
        print(matrix)
    }
    
    guard let points = split.last?.compactMap({ $0.toInt() }) else {
        fatalError("Invalid points, please specify correct input points. Valid format: (x: 0, y: 0), (x: 1, y: 3)")
    }
    assert(points.count % 2 == 0, "Can't generate path from provided points")
    
    print("\n--- Generating points ---\n")
    var coordinates: [(x: Int, y: Int)] = []
    for index in stride(from: 0, to: points.count, by: 2) {
        coordinates.append((x: points[index], y: points[index + 1]))
    }
    print(coordinates)
    print("\n--- Generating delivery path, please wait ---\n")
    /**
     We can improve the algorithm even further by reversing the point array, so we can use `removeLast` in
     `generateDirectionsForPizzaDelivery` which is O(1), instead of O(n) to its counter part `removeFirst`.
     */
    generateDirectionsForPizzaDelivery(from: coordinates.reversed()) { generatedPath in
        assert(generatedPath == output, "Oops, generated path is not correct.")
        print("Delivery path generated: \(generatedPath)")
    }
}

pizzabot(
    input: "5x5 (0, 0) (1, 3) (4, 4) (4, 2) (4, 2) (0, 1) (3, 2) (2, 3) (4, 1)",
    output: "DENNNDEEENDSSDDWWWWSDEEENDWNDEESSD",
    generateMatrix: true
)
