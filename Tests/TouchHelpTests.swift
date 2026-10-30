import Testing
import Foundation

@Suite("Touch Help Tests")
struct TouchHelpTests {
    @Test("Help examples use accepted coordinate options")
    func helpExamplesUseAcceptedCoordinateOptions() async throws {
        let axePath = try TestHelpers.getAxePath()
        let help = try await CommandRunner.run("\"\(axePath)\" touch --help")
        let examples = help.output.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.hasPrefix("axe touch ") }
        #expect(examples.count == 4)

        for example in examples {
            // A negative X fails validation before run(); = keeps -1 from parsing as an option.
            let negativeXExample = example.replacingOccurrences(of: " 100 ", with: "=-1 ")
            try #require(negativeXExample != example, "Example no longer matches the X substitution: \(example)")
            let command = negativeXExample
                .replacingOccurrences(of: "axe touch ", with: "\"\(axePath)\" touch ")
            let result = try await CommandRunner.run(command, allowFailure: true)
            #expect(result.exitCode == 64)
            #expect(result.output.contains("Coordinates must be non-negative values."))
        }
    }
}
