// swiftlint:disable all
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(BuilderMacroMacros)
import BuilderMacroMacros

import SwiftSyntax
import SwiftParser

let testMacros: [String: Macro.Type] = [
    "Builder" : BuilderMacro.self,
    "DebugBuilder" : DebugBuilderMacro.self
]

final class BuilderMacroTests: XCTestCase {
    func testBuilderMacro() {
        assertMacroExpansion(
            """
            @DebugBuilder
            public struct User {
                public let uuid: UUID
                public let name: String
                public let age: Int?
                public let height: Int
                public let array: [Int]
                public let dict: [String: [String: Int]]
            }
            """,
            expandedSource: """

            public struct User {
                public let uuid: UUID
                public let name: String
                public let age: Int?
                public let height: Int
                public let array: [Int]
                public let dict: [String: [String: Int]]

                #if DEBUG
                public final class Builder {
                    private enum Error: Swift.Error {
                        case missingValue(property: String)
                    }
                    public var uuid: UUID?
                    public var name: String?
                    public var age: Int?
                    public var height: Int?
                    public var array: [Int]?
                    public var dict: [String: [String: Int]]?
                    public required init() {
                    }
                    public convenience init(_ item: User?) {
                        self.init()
                        fill(with: item)
                    }
                    public convenience init(
                        uuid: UUID,
                        name: String,
                        age: Int? = nil,
                        height: Int,
                        array: [Int],
                        dict: [String: [String: Int]]
                    ) {
                        self.init()
                        self.uuid = uuid
                        self.name = name
                        self.age = age
                        self.height = height
                        self.array = array
                        self.dict = dict
                    }
                    public static func build(
                        uuid: UUID = UUID(),
                        name: String = "_name_",
                        age: Int? = nil,
                        height: Int = 0,
                        array: [Int] = [],
                        dict: [String: [String: Int]] = [:]
                    ) -> User {
                        let item = Self.init()
                        item.uuid = uuid
                        item.name = name
                        item.age = age
                        item.height = height
                        item.array = array
                        item.dict = dict
                        return item.build()
                    }
                    public static func tryBuild(
                        uuid: UUID = UUID(),
                        name: String = "_name_",
                        age: Int? = nil,
                        height: Int = 0,
                        array: [Int] = [],
                        dict: [String: [String: Int]] = [:]
                    ) throws -> User {
                        let item = Self.init()
                        item.uuid = uuid
                        item.name = name
                        item.age = age
                        item.height = height
                        item.array = array
                        item.dict = dict
                        return try item.tryBuild()
                    }
                    public func fill(with item: User?) {
                        uuid = item?.uuid
                        name = item?.name
                        age = item?.age
                        height = item?.height
                        array = item?.array
                        dict = item?.dict
                    }
                    public func build() -> User {
                        guard let name, let height, let array, let dict else {
                            fatalError()
                        }
                        return User(
                        uuid: uuid ?? UUID(),
                        name: name,
                        age: age,
                        height: height,
                        array: array,
                        dict: dict
                        )
                    }
                    public func tryBuild() throws -> User {
                        guard let name else {
                            throw Error.missingValue(property: "name")
                        }
                        guard let height else {
                            throw Error.missingValue(property: "height")
                        }
                        guard let array else {
                            throw Error.missingValue(property: "array")
                        }
                        guard let dict else {
                            throw Error.missingValue(property: "dict")
                        }
                        return User(
                        uuid: uuid ?? UUID(),
                        name: name,
                        age: age,
                        height: height,
                        array: array,
                        dict: dict
                        )
                    }
                    public func set(uuid: UUID) -> Self {
                        self.uuid = uuid
                        return self
                    }
                    public func set(name: String) -> Self {
                        self.name = name
                        return self
                    }
                    public func set(age: Int?) -> Self {
                        self.age = age
                        return self
                    }
                    public func set(height: Int) -> Self {
                        self.height = height
                        return self
                    }
                    public func set(array: [Int]) -> Self {
                        self.array = array
                        return self
                    }
                    public func set(dict: [String: [String: Int]]) -> Self {
                        self.dict = dict
                        return self
                    }
                }
                #endif
            }
            """,
            macros: testMacros
        )
    }

    func testBuilderMacroComputedProperty() {
        assertMacroExpansion(
            """
            @DebugBuilder
            public struct User {
                public let name: String
                public var hasName: Bool {
                    false
                }
            }
            """,
            expandedSource: """

            public struct User {
                public let name: String
                public var hasName: Bool {
                    false
                }

                #if DEBUG
                public final class Builder {
                    private enum Error: Swift.Error {
                        case missingValue(property: String)
                    }
                    public var name: String?
                    public required init() {
                    }
                    public convenience init(_ item: User?) {
                        self.init()
                        fill(with: item)
                    }
                    public convenience init(
                        name: String
                    ) {
                        self.init()
                        self.name = name
                    }
                    public static func build(
                        name: String = "_name_"
                    ) -> User {
                        let item = Self.init()
                        item.name = name
                        return item.build()
                    }
                    public static func tryBuild(
                        name: String = "_name_"
                    ) throws -> User {
                        let item = Self.init()
                        item.name = name
                        return try item.tryBuild()
                    }
                    public func fill(with item: User?) {
                        name = item?.name
                    }
                    public func build() -> User {
                        guard let name else {
                            fatalError()
                        }
                        return User(
                        name: name
                        )
                    }
                    public func tryBuild() throws -> User {
                        guard let name else {
                            throw Error.missingValue(property: "name")
                        }
                        return User(
                        name: name
                        )
                    }
                    public func set(name: String) -> Self {
                        self.name = name
                        return self
                    }
                }
                #endif
            }
            """,
            macros: testMacros
        )
    }

    func testBuilderMacroComment() {
        assertMacroExpansion(
                """
                @DebugBuilder
                public struct User {
                    /// some comment here
                    public let name: String? /// And another here
                }
                """,
                expandedSource: """

                public struct User {
                    /// some comment here
                    public let name: String? /// And another here

                    #if DEBUG
                    public final class Builder {
                        private enum Error: Swift.Error {
                            case missingValue(property: String)
                        }
                        public var name: String?
                        public required init() {
                        }
                        public convenience init(_ item: User?) {
                            self.init()
                            fill(with: item)
                        }
                        public convenience init(
                            name: String? = nil
                        ) {
                            self.init()
                            self.name = name
                        }
                        public static func build(
                            name: String? = nil
                        ) -> User {
                            let item = Self.init()
                            item.name = name
                            return item.build()
                        }
                        public static func tryBuild(
                            name: String? = nil
                        ) throws -> User {
                            let item = Self.init()
                            item.name = name
                            return try item.tryBuild()
                        }
                        public func fill(with item: User?) {
                            name = item?.name
                        }
                        public func build() -> User {
                
                            return User(
                            name: name
                            )
                        }
                        public func tryBuild() throws -> User {

                            return User(
                            name: name
                            )
                        }
                        public func set(name: String?) -> Self {
                            self.name = name
                            return self
                        }
                    }
                    #endif
                }
                """,
                macros: testMacros
        )
    }

    func testBuilderMacroWithDefaultValues() {
        assertMacroExpansion(
            """
            @DebugBuilder
            struct User {
                typealias UserID = String
                /// @BuilderDefaultValue(.init)
                let id: UserID
                /// @BuilderDefaultValue(.value("defaultName"))
                let name: String
                /// @BuilderDefaultValue(.builder)
                let value: Value
            }

            @DebugBuilder
            struct Value {
                let name: String
            }
            """,
            expandedSource: """

            struct User {
                typealias UserID = String
                /// @BuilderDefaultValue(.init)
                let id: UserID
                /// @BuilderDefaultValue(.value("defaultName"))
                let name: String
                /// @BuilderDefaultValue(.builder)
                let value: Value

                #if DEBUG
                final class Builder {
                    private enum Error: Swift.Error {
                        case missingValue(property: String)
                    }
                    var id: UserID?
                    var name: String?
                    var value: Value?
                    required init() {
                    }
                    convenience init(_ item: User?) {
                        self.init()
                        fill(with: item)
                    }
                    convenience init(
                        id: UserID,
                        name: String,
                        value: Value
                    ) {
                        self.init()
                        self.id = id
                        self.name = name
                        self.value = value
                    }
                    static func build(
                        id: UserID = .init(),
                        name: String = "defaultName",
                        value: Value = Value.Builder.build()
                    ) -> User {
                        let item = Self.init()
                        item.id = id
                        item.name = name
                        item.value = value
                        return item.build()
                    }
                    static func tryBuild(
                        id: UserID = .init(),
                        name: String = "defaultName",
                        value: Value = Value.Builder.build()
                    ) throws -> User {
                        let item = Self.init()
                        item.id = id
                        item.name = name
                        item.value = value
                        return try item.tryBuild()
                    }
                    func fill(with item: User?) {
                        id = item?.id
                        name = item?.name
                        value = item?.value
                    }
                    func build() -> User {
                        guard let id, let name, let value else {
                            fatalError()
                        }
                        return User(
                        id: id,
                        name: name,
                        value: value
                        )
                    }
                    func tryBuild() throws -> User {
                        guard let id else {
                            throw Error.missingValue(property: "id")
                        }
                        guard let name else {
                            throw Error.missingValue(property: "name")
                        }
                        guard let value else {
                            throw Error.missingValue(property: "value")
                        }
                        return User(
                        id: id,
                        name: name,
                        value: value
                        )
                    }
                    func set(id: UserID) -> Self {
                        self.id = id
                        return self
                    }
                    func set(name: String) -> Self {
                        self.name = name
                        return self
                    }
                    func set(value: Value) -> Self {
                        self.value = value
                        return self
                    }
                }
                #endif
            }
            struct Value {
                let name: String

                #if DEBUG
                final class Builder {
                    private enum Error: Swift.Error {
                        case missingValue(property: String)
                    }
                    var name: String?
                    required init() {
                    }
                    convenience init(_ item: Value?) {
                        self.init()
                        fill(with: item)
                    }
                    convenience init(
                        name: String
                    ) {
                        self.init()
                        self.name = name
                    }
                    static func build(
                        name: String = "_name_"
                    ) -> Value {
                        let item = Self.init()
                        item.name = name
                        return item.build()
                    }
                    static func tryBuild(
                        name: String = "_name_"
                    ) throws -> Value {
                        let item = Self.init()
                        item.name = name
                        return try item.tryBuild()
                    }
                    func fill(with item: Value?) {
                        name = item?.name
                    }
                    func build() -> Value {
                        guard let name else {
                            fatalError()
                        }
                        return Value(
                        name: name
                        )
                    }
                    func tryBuild() throws -> Value {
                        guard let name else {
                            throw Error.missingValue(property: "name")
                        }
                        return Value(
                        name: name
                        )
                    }
                    func set(name: String) -> Self {
                        self.name = name
                        return self
                    }
                }
                #endif
            }
            """,
            macros: testMacros
        )
    }

    func testBuilderMacroWithOptions() {
        assertMacroExpansion(
                """
                @DebugBuilder
                struct UserDefault {
                    let id: String
                }
                @DebugBuilder(config: .init(
                    options: [.build, .staticBuild]
                ))
                struct UserBuild {
                    let id: String
                }
                @DebugBuilder(config: .init(
                    options: [.tryBuild, .staticTryBuild]
                ))
                struct UserTryBuild {
                    let id: String
                }
                """,
                expandedSource: """
                struct UserDefault {
                    let id: String

                    #if DEBUG
                    final class Builder {
                        private enum Error: Swift.Error {
                            case missingValue(property: String)
                        }
                        var id: String?
                        required init() {
                        }
                        convenience init(_ item: UserDefault?) {
                            self.init()
                            fill(with: item)
                        }
                        convenience init(
                            id: String
                        ) {
                            self.init()
                            self.id = id
                        }
                        static func build(
                            id: String = "_id_"
                        ) -> UserDefault {
                            let item = Self.init()
                            item.id = id
                            return item.build()
                        }
                        static func tryBuild(
                            id: String = "_id_"
                        ) throws -> UserDefault {
                            let item = Self.init()
                            item.id = id
                            return try item.tryBuild()
                        }
                        func fill(with item: UserDefault?) {
                            id = item?.id
                        }
                        func build() -> UserDefault {
                            guard let id else {
                                fatalError()
                            }
                            return UserDefault(
                            id: id
                            )
                        }
                        func tryBuild() throws -> UserDefault {
                            guard let id else {
                                throw Error.missingValue(property: "id")
                            }
                            return UserDefault(
                            id: id
                            )
                        }
                        func set(id: String) -> Self {
                            self.id = id
                            return self
                        }
                    }
                    #endif
                }
                struct UserBuild {
                    let id: String

                    #if DEBUG
                    final class Builder {
                        var id: String?
                        required init() {
                        }
                        convenience init(_ item: UserBuild?) {
                            self.init()
                            fill(with: item)
                        }
                        convenience init(
                            id: String
                        ) {
                            self.init()
                            self.id = id
                        }
                        static func build(
                            id: String = "_id_"
                        ) -> UserBuild {
                            let item = Self.init()
                            item.id = id
                            return item.build()
                        }
                        func fill(with item: UserBuild?) {
                            id = item?.id
                        }
                        func build() -> UserBuild {
                            guard let id else {
                                fatalError()
                            }
                            return UserBuild(
                            id: id
                            )
                        }
                        func set(id: String) -> Self {
                            self.id = id
                            return self
                        }
                    }
                    #endif
                }
                struct UserTryBuild {
                    let id: String

                    #if DEBUG
                    final class Builder {
                        private enum Error: Swift.Error {
                            case missingValue(property: String)
                        }
                        var id: String?
                        required init() {
                        }
                        convenience init(_ item: UserTryBuild?) {
                            self.init()
                            fill(with: item)
                        }
                        convenience init(
                            id: String
                        ) {
                            self.init()
                            self.id = id
                        }
                        static func tryBuild(
                            id: String = "_id_"
                        ) throws -> UserTryBuild {
                            let item = Self.init()
                            item.id = id
                            return try item.tryBuild()
                        }
                        func fill(with item: UserTryBuild?) {
                            id = item?.id
                        }
                        func tryBuild() throws -> UserTryBuild {
                            guard let id else {
                                throw Error.missingValue(property: "id")
                            }
                            return UserTryBuild(
                            id: id
                            )
                        }
                        func set(id: String) -> Self {
                            self.id = id
                            return self
                        }
                    }
                    #endif
                }
                """,
                macros: testMacros
        )
    }

    func testBuilderMacroWithIsDebugOnly() {
        assertMacroExpansion(
                """
                @Builder
                struct UserDefault {
                    let id: String
                }
                """,
                expandedSource: """
                struct UserDefault {
                    let id: String

                    final class Builder {
                        private enum Error: Swift.Error {
                            case missingValue(property: String)
                        }
                        var id: String?
                        required init() {
                        }
                        convenience init(_ item: UserDefault?) {
                            self.init()
                            fill(with: item)
                        }
                        convenience init(
                            id: String
                        ) {
                            self.init()
                            self.id = id
                        }
                        static func build(
                            id: String = "_id_"
                        ) -> UserDefault {
                            let item = Self.init()
                            item.id = id
                            return item.build()
                        }
                        static func tryBuild(
                            id: String = "_id_"
                        ) throws -> UserDefault {
                            let item = Self.init()
                            item.id = id
                            return try item.tryBuild()
                        }
                        func fill(with item: UserDefault?) {
                            id = item?.id
                        }
                        func build() -> UserDefault {
                            guard let id else {
                                fatalError()
                            }
                            return UserDefault(
                            id: id
                            )
                        }
                        func tryBuild() throws -> UserDefault {
                            guard let id else {
                                throw Error.missingValue(property: "id")
                            }
                            return UserDefault(
                            id: id
                            )
                        }
                        func set(id: String) -> Self {
                            self.id = id
                            return self
                        }
                    }
                }
                """,
                macros: testMacros
        )
    }

    func testBuilderMacroGeneric() {
        assertMacroExpansion(
                """
                @Builder
                struct UserDefault {
                    let id: Set<String>
                }
                """,
                expandedSource: """
                struct UserDefault {
                    let id: Set<String>

                    final class Builder {
                        private enum Error: Swift.Error {
                            case missingValue(property: String)
                        }
                        var id: Set<String>?
                        required init() {
                        }
                        convenience init(_ item: UserDefault?) {
                            self.init()
                            fill(with: item)
                        }
                        convenience init(
                            id: Set<String>
                        ) {
                            self.init()
                            self.id = id
                        }
                        static func build(
                            id: Set<String> = []
                        ) -> UserDefault {
                            let item = Self.init()
                            item.id = id
                            return item.build()
                        }
                        static func tryBuild(
                            id: Set<String> = []
                        ) throws -> UserDefault {
                            let item = Self.init()
                            item.id = id
                            return try item.tryBuild()
                        }
                        func fill(with item: UserDefault?) {
                            id = item?.id
                        }
                        func build() -> UserDefault {
                            guard let id else {
                                fatalError()
                            }
                            return UserDefault(
                            id: id
                            )
                        }
                        func tryBuild() throws -> UserDefault {
                            guard let id else {
                                throw Error.missingValue(property: "id")
                            }
                            return UserDefault(
                            id: id
                            )
                        }
                        func set(id: Set<String>) -> Self {
                            self.id = id
                            return self
                        }
                    }
                }
                """,
                macros: testMacros
        )
    }
}
#endif
// swiftlint:enable all
