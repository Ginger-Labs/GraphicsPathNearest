//
//  TestHelpers.swift
//  GraphicsPathNearestTests
//
//  Created by Holmes Futrell on 2/26/21.
//  Copyright © 2021 Ginger Labs, Inc. All rights reserved.
//  https://www.gingerlabs.com
//

@testable import GraphicsPathNearest
import XCTest

func AssertCurvesEqual<T: LinearMath>(_ curve1: BezierCurve<T>,
                                      _ curve2: BezierCurve<T>,
                                      accuracy: CGFloat = 0.0,
                                      _ message: @autoclosure () -> String = "",
                                      file: StaticString = #filePath,
                                      line: UInt = #line) {
    let firstPoints = curve1.points
    let secondPoints = curve2.points
    AssertArraysEqual(firstPoints, secondPoints, accuracy: accuracy, message(), file: file, line: line)
    XCTAssertEqual(firstPoints.count, secondPoints.count,
                   message() + "curves have differing number of points",
                   file: file, line: line)
    guard zip(firstPoints, secondPoints).allSatisfy({ distance($0, $1) <= accuracy }) else {
        XCTFail(message() + """
            difference between points exceeded max error: \(accuracy)
            first points: \(firstPoints)
            second points: \(secondPoints)
            """
        )
        return
    }
}

func AssertArraysEqual<T: LinearMath>(_ array1: [T],
                                      _ array2: [T],
                                      accuracy: CGFloat = 0.0,
                                      _ message: @autoclosure () -> String = "",
                                      file: StaticString = #filePath,
                                      line: UInt = #line) {
    XCTAssertEqual(array1.count, array2.count,
                   message() + "count not equal",
                   file: file, line: line)
    guard zip(array1, array2).allSatisfy({ distance($0, $1) <= accuracy }) else {
        XCTFail(message() + """
            difference between entries exceeded max error: \(accuracy)
            first: \(array1)
            second: \(array2)
            """
        )
        return
    }
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    init(seed: Int) {
        srand48(seed)
    }
    func next() -> UInt64 {
        return UInt64(drand48() * Double(UInt64.max))
    }
}

func BezierCurve1DWithRealRoots(_ roots: [CGFloat]) -> BezierCurve1D {
    return roots.reduce(BezierCurve1D(points: [1]), { polynomial, root -> BezierCurve1D in
        return BezierCurve1D(points: [-root, 1 - root]) * polynomial
    })
}

func BezierCurve1DWithComplexRoots(_ roots: [(real: CGFloat, imaginary: CGFloat)]) -> BezierCurve1D {
    // complex roots always come in pairs so return a quadratic
    // with roots at real + imaginary * i and real - imaginary * i
    return roots.reduce(BezierCurve1D(points: [1]), { polynomial, root -> BezierCurve1D in
        let (real, imaginary) = root
        let lengthSquared = real * real + imaginary * imaginary
        let p0 = lengthSquared
        let p1 = lengthSquared - real
        let p2 = 1 - 2 * real + lengthSquared
        return BezierCurve1D(points: [p0, p1, p2]) * polynomial
    })
}
