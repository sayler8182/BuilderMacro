import BuilderMacro
import Foundation

// MARK: Example

@Builder
struct Breathing {
    /// @BuilderDefaultValue(.init)
    let uuid: UUID
    /// @BuilderDefaultValue(.value(5))
    let duration: Double
    /// @BuilderDefaultValue(.value("defaultValue"))
    let thoughts: String?
}

@Builder
struct Player {
    let uuid: UUID
    let coins: Int
    let value: Int
}

@Builder
struct Level {
    let uuid: UUID
    let name: String
    let value: Int
    let type: String?
    let array: [Int]
    let date: Date
}

let kBuilder = Breathing.Builder()
kBuilder.duration = 60
print(String(describing: kBuilder.build()))

let kThrowingBuilder = Player.Builder()
do {
    kThrowingBuilder.coins = 100
    kThrowingBuilder.value = 10
    let player = try kThrowingBuilder.tryBuild()
    print(player)
} catch {
    print(error)
}

let kDefaultBuilder = Level.Builder()
print(String(describing: kDefaultBuilder.build()))

@Builder
public struct Capping: Identifiable, Decodable, Hashable, Sendable {
    public typealias CappingID = String
    public typealias CategoryID = String
    public typealias CategoryVersion = String
    public typealias ZoneID = String
    public typealias ZoneVersion = String

    public enum Status: String, Decodable, Hashable, Sendable {
        case pending = "PENDING"
        case active = "ACTIVE"
    }

    @Builder
    public struct Zone: Identifiable, Decodable, Hashable, Sendable {
        public let id: ZoneID
        public let version: ZoneVersion
        public let name: String
    }

    @Builder
    public struct Category: Identifiable, Decodable, Hashable, Sendable {
        public let id: CategoryID
        public let version: CategoryVersion
        public let name: String
    }

    @Builder
    public struct Level: Decodable, Hashable, Sendable {
        public let name: String
        public let duration: String
        public let limit: Double
        public let used: Double
        public let currency: String
        public let remaining: Double
        public let closest: Bool
        public let inUse: Bool
    }

    public let id: CappingID
    public let status: Status
    public let zone: Zone?
    public let category: Category?
    public let levels: [Level]?
    public let closestLimitUntil: Date?
    public let freeTicketUntil: Date?
}

let kCappingBuilder = Capping.Builder.build(
    id: "id",
    status: .active,
    category: Capping.Category.Builder.build(
        id: "id",
        version: "version",
        name: "Adult"
    ),
    levels: [
        Capping.Level.Builder.build(
            name: "WEEKLY",
            duration: "PT168H",
            limit: 100,
            used: 90,
            currency: "NOK",
            remaining: 10,
            closest: true,
            inUse: false)
    ])

@DebugBuilder
struct ProductsPresentationStateParameters: Hashable, Sendable {
    let products: [String]
    let productClass: String?
    let route: String?
    let region: String?
    let period: String?
    let categories: [String]?
    let extensions: [String]?

    let journeyDetails: String?
    let product: String?
    let paymentMethod: String?
    let discount: String? /// The actual discount applied for current product selection
    let discountCodes: [String]? /// The discount codes array used during price recalculation
    let capping: String?
    let rebuy: Bool
}

let kStateBuilder = ProductsPresentationStateParameters.Builder(products: [], rebuy: false)
