import Foundation

// swiftlint:disable:next type_name
public enum ImplicitlyUnwrappedOptionalModeConfiguration: String {
    case all = "all"
    case allExceptIBOutlets = "all_except_iboutlets"

    init(value: Any) throws {
        if let string = (value as? String)?.lowercased(),
            let value = ImplicitlyUnwrappedOptionalModeConfiguration(rawValue: string) {
            self = value
        } else {
            throw ConfigurationError.unknownConfiguration
        }
    }
}

public struct ImplicitlyUnwrappedOptionalConfiguration: RuleConfiguration, Equatable {
    private(set) var severity: SeverityConfiguration
    private(set) var mode: ImplicitlyUnwrappedOptionalModeConfiguration
    private(set) var excluded: Set<NSRegularExpression>

    init(mode: ImplicitlyUnwrappedOptionalModeConfiguration, severity: SeverityConfiguration, excluded: [String] = []) {
        self.mode = mode
        self.severity = severity
        self.excluded = Set(excluded.compactMap { try? NSRegularExpression(pattern: $0, options: .caseInsensitive) })
    }

    public var consoleDescription: String {
        return severity.consoleDescription +
            ", mode: \(mode)"
    }

    public mutating func apply(configuration: Any) throws {
        guard let configuration = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }

        if let modeString = configuration["mode"] {
            try mode = ImplicitlyUnwrappedOptionalModeConfiguration(value: modeString)
        }

        if let severityString = configuration["severity"] as? String {
            try severity.apply(configuration: severityString)
        }

        if let excluded = [String].array(of: configuration["excluded"]) {
            self.excluded = Set(excluded.compactMap { try? NSRegularExpression(pattern: $0, options: .caseInsensitive) })
        }
    }
}
