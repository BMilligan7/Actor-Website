import XCTest
@testable import MoveMore

final class MoveMoreTests: XCTestCase {
    func testDetectsSingleBoutFromConsecutiveWalkingWindows() {
        let base = Date()
        let w1 = MotionWindow(
            start: base,
            end: base.addingTimeInterval(30),
            steps: 35,
            distanceM: 25,
            avgCadenceSPM: 70,
            isWalkingMajority: true
        )
        let w2 = MotionWindow(
            start: base.addingTimeInterval(30),
            end: base.addingTimeInterval(60),
            steps: 35,
            distanceM: 25,
            avgCadenceSPM: 70,
            isWalkingMajority: true
        )

        let bouts = WalkBoutDetector.detectBouts(
            windows: [w1, w2],
            minDurationSec: 60,
            minSteps: 60,
            minCadenceSPM: 60,
            createdAt: base
        )

        XCTAssertEqual(bouts.count, 1)
        let bout = try! XCTUnwrap(bouts.first)
        XCTAssertEqual(bout.start, w1.start)
        XCTAssertEqual(bout.end, w2.end)
        XCTAssertEqual(bout.steps, 70)
        XCTAssertGreaterThanOrEqual(bout.avgCadenceSPM, 70 - 0.001)
        XCTAssertEqual(bout.label, .auto)
        XCTAssertEqual(bout.createdAt, base)
    }

    func testSplitsBoutsOnNonWalkingWindows() {
        let base = Date()
        let w1 = MotionWindow(start: base, end: base.addingTimeInterval(60), steps: 60, distanceM: 50, avgCadenceSPM: 60, isWalkingMajority: true)
        let breakWin = MotionWindow(start: base.addingTimeInterval(60), end: base.addingTimeInterval(90), steps: 0, distanceM: 0, avgCadenceSPM: 0, isWalkingMajority: false)
        let w2 = MotionWindow(start: base.addingTimeInterval(90), end: base.addingTimeInterval(150), steps: 70, distanceM: 55, avgCadenceSPM: 70, isWalkingMajority: true)

        let bouts = WalkBoutDetector.detectBouts(
            windows: [w1, breakWin, w2],
            minDurationSec: 60,
            minSteps: 60,
            minCadenceSPM: 60
        )

        XCTAssertEqual(bouts.count, 2)
        XCTAssertEqual(bouts[0].steps, 60)
        XCTAssertEqual(bouts[1].steps, 70)
    }

    func testRejectsSubthresholdDurationAndSteps() {
        let base = Date()
        let short = MotionWindow(start: base, end: base.addingTimeInterval(45), steps: 40, distanceM: 30, avgCadenceSPM: 53, isWalkingMajority: true)
        let bouts = WalkBoutDetector.detectBouts(
            windows: [short],
            minDurationSec: 60,
            minSteps: 60,
            minCadenceSPM: 60
        )
        XCTAssertTrue(bouts.isEmpty)
    }
}



