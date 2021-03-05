//
//  BezierCurve.swift
//  GraphicsPathNearest
//
//  Created by Holmes Futrell on 2/19/21.
//  Copyright © 2021 Ginger Labs, Inc. All rights reserved.
//  https://www.gingerlabs.com
//

import CoreGraphics

struct BezierCurve<T: LinearMath>: Equatable {
    var points: [T]
    var degree: Int { return points.count - 1 }
    init(points: [T]) {
        precondition(points.isEmpty == false, "Bezier curves require at least one point")
        self.points = points
    }
    static func * (left: CGFloat, right: BezierCurve<T>) -> BezierCurve<T> {
        return BezierCurve(points: right.points.map { left * $0 })
    }
    static func == (left: BezierCurve<T>, right: BezierCurve<T>) -> Bool {
        return left.points == right.points
    }
    func reversed() -> BezierCurve<T> {
        return BezierCurve(points: points.reversed())
    }
    var derivative: BezierCurve<T> {
        guard degree > 0 else { return BezierCurve<T>.init(points: [T.zero]) }
        return CGFloat(degree) * hodograph
    }
    func value(at t: CGFloat) -> T {
        return self.split(at: t).left.points.last!
    }
    private var hodograph: BezierCurve<T> {
        precondition(degree > 0)
        let differences = (0..<degree).map { points[$0 + 1] - points[$0] }
        return BezierCurve(points: differences)
    }
    func split(at t: CGFloat) -> (left: BezierCurve<T>, right: BezierCurve<T>) {
        guard degree > 0 else {
            // splitting a point results in getting a point back
            return (left: self, right: self)
        }
        // apply de Casteljau Algorithm
        var leftPoints = [T](repeating: .zero, count: points.count)
        var rightPoints = [T](repeating: .zero, count: points.count)
        let n = degree
        var scratchPad: [T] = points
        leftPoints[0] = scratchPad[0]
        rightPoints[n] = scratchPad[n]
        for j in 1...n {
            for i in 0...n - j {
                scratchPad[i] = linearInterpolate(scratchPad[i], scratchPad[i + 1], t)
            }
            leftPoints[j] = scratchPad[0]
            rightPoints[n - j] = scratchPad[n - j]
        }
        return (left: BezierCurve(points: leftPoints),
                right: BezierCurve(points: rightPoints))
    }
    func split(from t1: CGFloat, to t2: CGFloat) -> BezierCurve<T> {
        guard (t1 > t2) == false else {
            // simplifying to t1 <= t2 would infinite loop on NaN because NaN comparisons are always false
            return split(from: t2, to: t1).reversed()
        }
        guard t1 != 0 else { return split(at: t2).left }
        let right = split(at: t1).right
        guard t2 != 1 else { return right }
        let t2MappedToRight = (t2 - t1) / (1 - t1)
        return right.split(at: t2MappedToRight).left
    }
}

typealias BezierCurve1D = BezierCurve<CGFloat>
typealias BezierCurve2D = BezierCurve<CGPoint>

extension BezierCurve1D {
    static func + (left: BezierCurve1D, right: BezierCurve1D) -> BezierCurve1D {
        precondition(left.degree == right.degree, "curves must have equal degree (unless we support upgrading degrees, which we don't here)")
        return BezierCurve<T>(points: zip(left.points, right.points).map(+))
    }
    static func * (left: BezierCurve1D, right: BezierCurve1D) -> BezierCurve1D {
        // the polynomials are multiplied in Bernstein form, which is a little different
        // from normal polynomial multiplication. For a discussion of how this works see
        // "Computer Aided Geometric Design" by T.W. Sederberg,
        // 9.3 Multiplication of Polynomials in Bernstein Form
        var points: [CGFloat] = []
        let m = left.degree
        let n = right.degree
        for k in 0...m + n {
            let start = max(k - n, 0)
            let end = min(m, k)
            let sum = (start...end).reduce(CGFloat.zero) { totalSoFar, i  in
                let j = k - i
                return totalSoFar + CGFloat(binomialCoefficient(m, choose: i) * binomialCoefficient(n, choose: j)) * left.points[i] * right.points[j]
            }
            let divisor = CGFloat(binomialCoefficient(m + n, choose: k))
            points.append(sum / divisor)
        }
        return BezierCurve1D(points: points)
    }
}

extension BezierCurve2D {
    static func line(start: CGPoint, end: CGPoint) -> BezierCurve<T> {
        return BezierCurve2D(points: [start, end])
    }
    static func quadratic(start: CGPoint, end: CGPoint, control: CGPoint) -> BezierCurve<T> {
        return BezierCurve2D(points: [start, control, end])
    }
    static func cubic(start: CGPoint, end: CGPoint, control1: CGPoint, control2: CGPoint) -> BezierCurve<T> {
        return BezierCurve2D(points: [start, control1, control2, end])
    }
    var xPolynomial: BezierCurve1D {
        return BezierCurve1D(points: points.map(\.x))
    }
    var yPolynomial: BezierCurve1D {
        return BezierCurve1D(points: points.map(\.y))
    }
    func dotProduct(_ other: BezierCurve2D) -> BezierCurve1D {
        return xPolynomial * other.xPolynomial + yPolynomial * other.yPolynomial
    }
    func nearestPointOnCurve(to point: CGPoint) -> (t: CGFloat, point: CGPoint) {
        let difference = BezierCurve2D(points: points.map { $0 - point })
        let equation = difference.dotProduct(derivative)
        let tValuesToTest: [CGFloat] = [0, 1] + equation.distinctRealRootsInUnitInterval()
        let predicate = { (first: CGFloat, second: CGFloat) -> Bool in
            distance(point, value(at: first)) < distance(point, value(at: second))
        }
        let closestT = tValuesToTest.min(by: predicate)!
        return (t: closestT, point: value(at: closestT))
    }
}
