import Async
import Core
import Dispatch
import Foundation
import Service

/// Used to configure Leaf renderer.
public struct LeafConfig {
    let tags: [String: Tag]
    let fileFactory: Renderer.FileFactory

    public init(
        tags: [String: Tag],
        fileFactory: @escaping Renderer.FileFactory
    ) {
        self.tags = tags
        self.fileFactory = fileFactory
    }

    public static func `default`() -> LeafConfig {
        return LeafConfig(
            tags: defaultTags
        ) { queue in
            return File(queue: queue)
        }
    }
}

public final class LeafProvider: Provider {
    /// See Service.Provider.repositoryName
    public static let repositoryName = "leaf"

    public init() {}

    /// See Service.Provider.Register
    public func register(_ services: inout Services) throws {
        services.register(ViewRenderer.self) { container -> Leaf.Renderer in
            let config = try container.make(LeafConfig.self, for: Renderer.self)
            return Leaf.Renderer(
                tags: config.tags,
                fileFactory: config.fileFactory
            )
        }

        services.register { container in
            return LeafConfig.default()
        }
    }

    /// See Service.Provider.boot
    public func boot(_ container: Container) throws { }
}


// MARK: View

public struct View: Codable {
    /// The view's data.
    public let data: Data

    /// Create a new View
    public init(data: Data) {
        self.data = data
    }

    /// See Encodable.encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }

    /// See Decodable.decode
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(data: container.decode(Data.self))
    }
}


public protocol ViewRenderer {
    func make(_ path: String, context: Encodable, on worker: Worker) throws -> Future<View>
}