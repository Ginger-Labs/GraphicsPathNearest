//
//  LinearMath.swift
//  GraphicsPathNearest
//
//  Created by Holmes Futrell on 2/26/21.
//  Copyright © 2021 Ginger Labs, Inc. All rights reserved.
//  https://www.gingerlabs.com
//

import CoreGraphics

func binomialCoefficient(_ n: Int, choose k: Int) -> Int {
    precondition(n >= 0 && k >= 0)
    var result = 1
    for i in 0..<k {
      result *= (n - i)
      result /= (i + 1)
    }
    return result
}

protocol LinearMath: Equatable {
    static func * (left: CGFloat, right: Self) -> Self
    static func + (left: Self, right: Self) -> Self
    static func - (left: Self, right: Self) -> Self
    static var zero: Self { get }
    static func distance(_ first: Self, _ second: Self) -> CGFloat
}

func linearInterpolate<T: LinearMath>(_ first: T, _ second: T, _ t: CGFloat) -> T {
    return (1 - t) * first + t * second
}

func distance<T: LinearMath>(_ first: T, _ second: T) -> CGFloat {
    return T.distance(first, second)
}

extension CGPoint: LinearMath {
    static func * (left: CGFloat, right: CGPoint) -> CGPoint {
        return CGPoint(x: left * right.x, y: left * right.y)
    }
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    static func distance(_ first: CGPoint, _ second: CGPoint) -> CGFloat {
        let difference = first - second
        return sqrt(difference.x * difference.x + difference.y * difference.y)
    }
}

extension CGFloat: LinearMath {
    static func distance(_ first: CGFloat, _ second: CGFloat) -> CGFloat {
        return abs(first - second)
    }
}
