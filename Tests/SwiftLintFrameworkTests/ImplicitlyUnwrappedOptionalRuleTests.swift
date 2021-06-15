@testable import SwiftLintFramework
import XCTest

private let fixturesDirectory = #file.bridge()
    .deletingLastPathComponent.bridge()
    .appendingPathComponent("Resources/ImplicitlyUnwrappedOptionalRuleFixtures")

class ImplicitlyUnwrappedOptionalRuleTests: XCTestCase {
    func testWithDefaultConfiguration() {
        verifyRule(ImplicitlyUnwrappedOptionalRule.description)
    }

    func testImplicitlyUnwrappedOptionalRuleDefaultConfiguration() {
        let rule = ImplicitlyUnwrappedOptionalRule()
        XCTAssertEqual(rule.configuration.mode, .allExceptIBOutlets)
        XCTAssertEqual(rule.configuration.severity.severity, .warning)
    }

    func testImplicitlyUnwrappedOptionalRuleWarnsOnOutletsInAllMode() {
        let baseDescription = ImplicitlyUnwrappedOptionalRule.description
        let triggeringExamples = [
            Example("@IBOutlet private var label: UILabel!"),
            Example("@IBOutlet var label: UILabel!"),
            Example("let int: Int!")
        ]

        let nonTriggeringExamples = [Example("if !boolean {}")]
        let description = baseDescription.with(nonTriggeringExamples: nonTriggeringExamples)
                                         .with(triggeringExamples: triggeringExamples)

        verifyRule(description, ruleConfiguration: ["mode": "all"],
                   commentDoesntViolate: true, stringDoesntViolate: true)
    }

    func testExcludedFileNameDoesntTrigger() {
        XCTAssert(try validate(fileName: "ImplicitlyUnwrappedTest.swift", excludedOverride: ["excluded": ".*Test.swift"]
        ).isEmpty)
    }

    func testNonexcludedFileNameDoesTrigger() {
        XCTAssertEqual(try validate(fileName: "ImplicitlyUnwrappedTest.swift", excludedOverride: ["excluded": ""]).count, 1)
    }

    private func validate(fileName: String, excludedOverride: [String: Any]? = nil) throws -> [StyleViolation] {
        let file = SwiftLintFile(path: fixturesDirectory.stringByAppendingPathComponent(fileName))!
        let rule: ImplicitlyUnwrappedOptionalRule
        if let excluded = excludedOverride {
            rule = try ImplicitlyUnwrappedOptionalRule(configuration: excluded)
        } else {
            rule = ImplicitlyUnwrappedOptionalRule()
        }

        return rule.validate(file: file)
    }
}
