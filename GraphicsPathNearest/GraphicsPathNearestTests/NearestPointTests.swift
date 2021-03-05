//
//  NearestPointTests.swift
//  GraphicsPathNearestTests
//
//  Created by Holmes Futrell on 2/26/21.
//  Copyright © 2021 Ginger Labs, Inc. All rights reserved.
//  https://www.gingerlabs.com
//

@testable import GraphicsPathNearest
import XCTest

class NearestPointTests: XCTestCase {

    func testNearestPointLine() {
        let line = BezierCurve2D.line(start: CGPoint(x: 3, y: 1),
                                      end: CGPoint(x: 7, y: 9))
        
        let result1 = line.nearestPointOnCurve(to: CGPoint(x: 2, y: 1))
        XCTAssertEqual(result1.t, 0)
        XCTAssertEqual(result1.point, CGPoint(x: 3, y: 1))
        
        let result2 = line.nearestPointOnCurve(to: CGPoint(x: 2, y: 4))
        XCTAssertEqual(result2.t, 0.25)
        XCTAssertEqual(result2.point, CGPoint(x: 4, y: 3))
        
        let result3 = line.nearestPointOnCurve(to: CGPoint(x: 7, y: 10))
        XCTAssertEqual(result3.t, 1)
        XCTAssertEqual(result3.point, CGPoint(x: 7, y: 9))
    }
    
    func testNearestPointQuadratic() {
        let quadratic = BezierCurve2D.quadratic(start: CGPoint(x: -1, y: 1),
                                                end: CGPoint(x: 1, y: 1),
                                                control: CGPoint(x: 0, y: -1))

        let result1 = quadratic.nearestPointOnCurve(to: CGPoint(x: 0, y: 0.25))
        XCTAssertEqual(result1.point, CGPoint(x: 0, y: 0))
        XCTAssertEqual(result1.t, 0.5)
        
        let result2 = quadratic.nearestPointOnCurve(to: CGPoint(x: -3, y: 0))
        XCTAssertEqual(result2.point, CGPoint(x: -1, y: 1))
        XCTAssertEqual(result2.t, 0)

        let result3 = quadratic.nearestPointOnCurve(to: CGPoint(x: 2, y: 4))
        XCTAssertEqual(result3.point, CGPoint(x: 1, y: 1))
        XCTAssertEqual(result3.t, 1)

    }
    
    func testNearestPointCubic() {
        let cubic = BezierCurve2D.cubic(start: CGPoint(x: 1.0, y: 1.0),
                                        end: CGPoint(x: 5.0, y: 1.0),
                                        control1: CGPoint(x: 2.0, y: 2.0),
                                        control2: CGPoint(x: 4.0, y: 2.0))
        
        let result1 = cubic.nearestPointOnCurve(to: CGPoint(x: 0, y: 2))
        XCTAssertEqual(result1.t, 0)
        XCTAssertEqual(result1.point, CGPoint(x: 1, y: 1))
        
        let result2 = cubic.nearestPointOnCurve(to: CGPoint(x: 6, y: 2))
        XCTAssertEqual(result2.t, 1)
        XCTAssertEqual(result2.point, CGPoint(x: 5, y: 1))
        
        let result3 = cubic.nearestPointOnCurve(to: CGPoint(x: 3, y: 2))
        XCTAssertEqual(result3.t, 0.5)
        XCTAssertEqual(result3.point, CGPoint(x: 3, y: 1.75))
    }
}
