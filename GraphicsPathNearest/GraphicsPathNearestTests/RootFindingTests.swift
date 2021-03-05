//
//  RootFindingTests.swift
//  GraphicsPathNearestTests
//
//  Created by Holmes Futrell on 2/23/21.
//  Copyright © 2021 Ginger Labs, Inc. All rights reserved.
//  https://www.gingerlabs.com
//

@testable import GraphicsPathNearest
import XCTest

class RootFindingTests: XCTestCase {
    
    func testConstant() {
        let constant = BezierCurve1D(points: [0])
        XCTAssertEqual(constant.distinctRealRootsInUnitInterval(), [])
    }
    
    func testLinear() {
        let line1 = BezierCurve1D(points: [-1, 2])
        XCTAssertEqual(line1.distinctRealRootsInUnitInterval(), [CGFloat(1.0 / 3.0)])
        let line2 = BezierCurve1D(points: [0, 2])
        XCTAssertEqual(line2.distinctRealRootsInUnitInterval(), [0])
        let line3 = BezierCurve1D(points: [2, 0])
        XCTAssertEqual(line3.distinctRealRootsInUnitInterval(), [1])
        let line4 = BezierCurve1D(points: [1, 2])
        XCTAssertEqual(line4.distinctRealRootsInUnitInterval(), [])
        let line5 = BezierCurve1D(points: [-2, -1])
        XCTAssertEqual(line5.distinctRealRootsInUnitInterval(), [])
        let line6 = BezierCurve1D(points: [0, 0])
        XCTAssertEqual(line6.distinctRealRootsInUnitInterval(), [])
    }
    
    func testQuadratic() {
        let maxError = RootFindingConfiguration.defaultErrorThreshold
        let quad1 = BezierCurve1D(points: [1, -1, 1])
        AssertArraysEqual(quad1.distinctRealRootsInUnitInterval(), [CGFloat(0.5)])
        let roots2: [CGFloat] = [0.25, 0.75]
        let quad2 = BezierCurve1DWithRealRoots(roots2)
        AssertArraysEqual(quad2.distinctRealRootsInUnitInterval(), roots2, accuracy: maxError)
        let quad3 = BezierCurve1D(points: [-1, -1, 1])
        AssertArraysEqual(quad3.distinctRealRootsInUnitInterval(), [sqrt(2)/2], accuracy: maxError)
        let quad4 = BezierCurve1D(points: [0, 2, 0])
        AssertArraysEqual(quad4.distinctRealRootsInUnitInterval(), [0, 1])
        let quad5 = BezierCurve1D(points: [-1, 3, -1])
        let quad5Root1: CGFloat = 0.5 - sqrt(2) / 4
        let quad5Root2: CGFloat = 0.5 + sqrt(2) / 4
        AssertArraysEqual(quad5.distinctRealRootsInUnitInterval(), [quad5Root1, quad5Root2], accuracy: maxError)
        let quad6 = BezierCurve1D(points: [1, -0.999, 1])
        AssertArraysEqual(quad6.distinctRealRootsInUnitInterval(), [])
        let quad7 = BezierCurve1D(points: [2, 1, 2])
        AssertArraysEqual(quad7.distinctRealRootsInUnitInterval(), [])
        let quad8 = BezierCurve1D(points: [0, 0, 0])
        AssertArraysEqual(quad8.distinctRealRootsInUnitInterval(), [])
        // troublesome case found through fuzzing
        let roots10: [CGFloat] = [0.95160796486060883, 0.95173949374103949]
        let quad10 = BezierCurve1DWithRealRoots(roots10)
        AssertArraysEqual(quad10.distinctRealRootsInUnitInterval(), roots10, accuracy: maxError)
        // another troublesome case found through fuzzing
        let roots11: [CGFloat] = [0.89445832700841654, 0.97339909490455367]
        let quad11 = BezierCurve1DWithRealRoots(roots11)
        AssertArraysEqual(quad11.distinctRealRootsInUnitInterval(), roots11, accuracy: maxError)
    }
        
    func testUsingFuzzedInputs() {
        let configuration = RootFindingConfiguration(errorThreshold: RootFindingConfiguration.minimumErrorThreshold)
        // use a seeded generator so that any test failures are reproducible
        var numberGenerator = SeededRandomNumberGenerator(seed: 12345)
        let numberOfInputsToTest = 1000
        // generate and test a bunch of fuzzed polynomials
        for i in 0...numberOfInputsToTest {
            func errorMessage(_ message: String) -> String {
                return "iteration \(i): " + message
            }
            // create some randomized real and/or complex roots
            let intervalSize = 2
            func randomValue() -> CGFloat {
                if Bool.random(using: &numberGenerator) {
                    return CGFloat.random(in: -CGFloat(intervalSize)...CGFloat(intervalSize), using: &numberGenerator)
                } else {
                    return CGFloat(Int.random(in: -intervalSize...intervalSize, using: &numberGenerator))
                }
            }
            let realRoots = (0..<Int.random(in: 0...9, using: &numberGenerator)).map { _ in randomValue() }
            let complexRoots = (0..<Int.random(in: 0...4, using: &numberGenerator)).compactMap { _ -> (real: CGFloat, imaginary: CGFloat)? in
                let result = (real: randomValue(), imaginary: randomValue())
                guard result.imaginary != 0 else {
                    return nil // root is actually real when imaginary part is zero
                }
                return result
            }
            let expectedRoots = Set(realRoots.filter { $0 >= 0 && $0 <= 1 })
            // form polynomial with the random roots
            let polynomial = BezierCurve1DWithRealRoots(realRoots) * BezierCurve1DWithComplexRoots(complexRoots)
            // find the roots
            let computedRoots = polynomial.distinctRealRootsInUnitInterval(configuration: configuration)
            // validate the roots
            XCTAssertTrue(computedRoots.allSatisfy { $0 >= 0 && $0 <= 1 }, errorMessage("values outside of unit interval"))
            XCTAssertEqual(computedRoots, computedRoots.sorted(), errorMessage("not sorted"))
            XCTAssertEqual(Set(computedRoots).count, computedRoots.count, errorMessage("contains duplicate(s)"))
            for expectedRoot in expectedRoots {
                XCTAssert(computedRoots.contains { distance(expectedRoot, $0) <= configuration.errorThreshold}, errorMessage("does not contain root \(expectedRoot)"))
            }
            XCTAssertTrue(computedRoots.count <= expectedRoots.count, errorMessage("extra root(s)"))
            for computedRoot in computedRoots {
                XCTAssert(expectedRoots.contains { distance(computedRoot, $0) <= configuration.errorThreshold}, errorMessage("false root \(computedRoot)"))
            }
        }
    }
}
