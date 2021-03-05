# Nearest point on a Bezier Curve
Sample Project For Ginger Lab's Technical Blog Post: [TODO: URL here]

<img src="/screenshot.png" height=400>

This project demonstrates how to find the closest point on a Bezier curve to a given point.

The technique used here is test the distance to the endpoints of the curve as well as the critical points of the distance equation.

Locating the critical points of the distance equation requires finding the roots of a polynomial (see `RootFinding.swift`). In the case of cubic Bezier Curves this polynomial is of degree five, which in general cannot be solved with a formula. Therefore the roots are found using the Bezier Clipping algorithm (see: "Curve intersection using Bézier clipping" by T.W. Sederberg and T. Nishita) which can usually converge on the roots with high accuracy in relatively few iterations.

The project contains a short Bezier Curve reference implementation (`BezierCurve.swift`) that emphasizes correctness and brevity over optimization. To understand the math I recommend "Computer Aided Geometric Design" by T.W. Sederberg or "A Primer on Bézier Curves" by Pomax.
