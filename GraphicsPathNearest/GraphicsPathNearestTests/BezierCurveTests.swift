//
//  GraphicsPathNearestTests.swift
//  GraphicsPathNearestTests
//
//  Created by Holmes Futrell on 2/20/21.
//  Copyright © 2021 Ginger Labs, Inc. All rights reserved.
//  https://www.gingerlabs.com
//

import XCTest
@testable import GraphicsPathNearest

class BezierCurveTests: XCTestCase {
        
    func testBezierCurve1DConstant() {
        let constant = BezierCurve1D(points: [42])
        XCTAssertEqual(constant.degree, 0)
        XCTAssertEqual(constant.derivative, BezierCurve1D(points: [0]))
        XCTAssertEqual(constant.value(at: 0.1), 42)
        AssertCurvesEqual(constant.split(from: 0.1, to: 0.75), constant)
    }

    func testBezierCurve1DLine() {
        let line = BezierCurve1D(points: [3, -4])
        XCTAssertEqual(line.points, [3, -4])
        XCTAssertEqual(line.degree, 1)
        XCTAssertEqual(line.derivative, BezierCurve1D(points: [-7]))
        XCTAssertEqual(line.value(at: 0.25), 1.25)
        AssertCurvesEqual(line.split(from: 0.25, to: 0.625), BezierCurve1D(points: [1.25, -1.375]))
    }
    
    func testBezierCurve1DQuadratic() {
        let quadratic = BezierCurve1D(points: [1, 3, -1])
        XCTAssertEqual(quadratic.degree, 2)
        XCTAssertEqual(quadratic.derivative, BezierCurve1D(points: [4, -8]))
        XCTAssertEqual(quadratic.value(at: 0.25), 13.0 / 8.0)
        AssertCurvesEqual(quadratic.split(from: 0.5, to: 0.75),
                          BezierCurve1D(points: [1.5, 1.25, 0.625]))
    }
    
    func testBezierCurve1DMultiply() {
        // represents the polynomial f(t) = (t-1)(t-2) in Bernstein basis
        let quadratic = BezierCurve1D(points: [2.0, 0.5, 0.0])
        // represents the polynomial f(t) = (t-1)(t-2)(t-3) in Bernstein basis
        let cubic =  BezierCurve1D(points: [-60, CGFloat(-133.0 / 3.0), CGFloat(-98.0 / 3.0), -24.0])
        // represents the polynomial f(t) = (t-1)(t-2)(t-3)(t-4)(t-5) in Bernstein basis
        let expectedQuintic = BezierCurve1D(points: [-120, -65.2, -32.9, -14.6, -4.8, 0])
        AssertCurvesEqual(cubic * quadratic, expectedQuintic)
        AssertCurvesEqual(quadratic * cubic, expectedQuintic)
    }
    
    func testBezierCurve2D() {
        let cubic = BezierCurve2D.cubic(start: CGPoint(x: 1, y: 1),
                                        end: CGPoint(x: 4, y: 1),
                                        control1: CGPoint(x: 2, y: 4),
                                        control2: CGPoint(x: 3, y: -2))
        XCTAssertEqual(cubic.degree, 3)
        let expectedDerivative = BezierCurve2D.quadratic(start: CGPoint(x: 3, y: 9),
                                                         end: CGPoint(x: 3, y: 9),
                                                         control: CGPoint(x: 3, y: -18))
        AssertCurvesEqual(cubic.derivative, expectedDerivative)
        XCTAssertEqual(cubic.value(at: 0.5), CGPoint(x: 2.5, y: 1))
        XCTAssertEqual(cubic.xPolynomial, BezierCurve1D(points: [1, 2, 3, 4]))
        XCTAssertEqual(cubic.yPolynomial, BezierCurve1D(points: [1, 4, -2, 1]))
       
        let line = BezierCurve2D.line(start: CGPoint(x: 1, y: -1),
                                      end: CGPoint(x: 4, y: 1))
        XCTAssertEqual(cubic.dotProduct(line), BezierCurve1D(points: [0, -0.25, 8.5, 8.25, 17]))
    }
    
    func testSplitSpecialCases() {
        let quad = BezierCurve1D(points: [1, 2, -1])
        XCTAssertEqual(quad.split(from: 0, to: 1), quad)
        XCTAssertEqual(quad.split(from: 1, to: 0), quad.reversed())
        XCTAssertEqual(quad.split(from: 0, to: 0), BezierCurve1D(points: [1, 1, 1]))
        XCTAssertEqual(quad.split(from: 1, to: 1), BezierCurve1D(points: [-1, -1, -1]))
        XCTAssertTrue(quad.split(from: CGFloat.nan, to: CGFloat.nan).points.allSatisfy { $0.isNaN })
    }
    
    func testBinomial() {
        XCTAssertEqual(binomialCoefficient(0, choose: 0), 1)
        XCTAssertEqual(binomialCoefficient(0, choose: 1), 0)
        XCTAssertEqual(binomialCoefficient(0, choose: 9), 0)
        XCTAssertEqual(binomialCoefficient(1, choose: 0), 1)
        XCTAssertEqual(binomialCoefficient(1, choose: 1), 1)
        XCTAssertEqual(binomialCoefficient(1, choose: 2), 0)
        XCTAssertEqual(binomialCoefficient(2, choose: 0), 1)
        XCTAssertEqual(binomialCoefficient(2, choose: 1), 2)
        XCTAssertEqual(binomialCoefficient(2, choose: 2), 1)
        XCTAssertEqual(binomialCoefficient(2, choose: 3), 0)
        XCTAssertEqual(binomialCoefficient(3, choose: 2), 3)
        XCTAssertEqual(binomialCoefficient(5, choose: 3), 10)
        XCTAssertEqual(binomialCoefficient(9, choose: 4), 126)
    }    
}
