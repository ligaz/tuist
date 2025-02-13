import Foundation
import TSCBasic
import TuistCore
import TuistDependencies
import TuistGenerator
import TuistGraph
import TuistSigning

/// The GraphMapperFactorying describes the interface of a factory of graph mappers.
/// Methods in the interface map with workflows exposed to the user.
protocol GraphMapperFactorying {
    ///  Returns the graph mapper that should be used for automation tasks such as build and test.
    /// - Returns: A graph mapper.
    func automation(
        config: Config,
        testsCacheDirectory: AbsolutePath,
        testPlan: String?,
        includedTargets: Set<String>,
        excludedTargets: Set<String>
    ) -> [GraphMapping]

    /// Returns the default graph mapper that should be used from all the commands that require loading and processing the graph.
    /// - Returns: The default mapper.
    func `default`() -> [GraphMapping]
}

public final class GraphMapperFactory: GraphMapperFactorying {
    public init() {}

    public func automation(
        config _: Config,
        testsCacheDirectory _: AbsolutePath,
        testPlan: String?,
        includedTargets: Set<String>,
        excludedTargets: Set<String>
    ) -> [GraphMapping] {
        var mappers: [GraphMapping] = []
        mappers.append(
            FocusTargetsGraphMappers(
                testPlan: testPlan,
                includedTargets: includedTargets,
                excludedTargets: excludedTargets
            )
        )
        mappers.append(TreeShakePrunedTargetsGraphMapper())
        mappers.append(contentsOf: self.default())

        return mappers
    }

    public func `default`() -> [GraphMapping] {
        var mappers: [GraphMapping] = []
        mappers.append(UpdateWorkspaceProjectsGraphMapper())
        mappers.append(PruneOrphanExternalTargetsGraphMapper())
        mappers.append(ExternalProjectsPlatformNarrowerGraphMapper())
        return mappers
    }
}
