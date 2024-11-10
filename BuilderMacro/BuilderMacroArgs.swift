import Foundation

public enum BuilderMacroArgs {
    public struct Config {
        public struct Options: OptionSet, Hashable {
            public static let build = Options(rawValue: 1 << 1)
            public static let staticBuild = Options(rawValue: 1 << 2)
            public static let tryBuild = Options(rawValue: 1 << 3)
            public static let staticTryBuild = Options(rawValue: 1 << 4)

            public let rawValue: Int

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
        }

        public let options: Options

        public init(options: Options = []) {
            self.options = options
        }
    }
}
