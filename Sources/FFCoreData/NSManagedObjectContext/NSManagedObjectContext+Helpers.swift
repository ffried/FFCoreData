import CoreData

extension NSManagedObjectContext {
    public final func sync<T>(do work: () throws -> T) rethrows -> T {
        try {
            var result: Result<T, Error>!
            performAndWait {
                result = Result(catching: work)
            }
            return try result.get()
        }()
    }

    @inlinable
    public final func async(do work: @escaping () -> ()) {
        perform(work)
    }
}

#if canImport(_Concurrency)
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension NSManagedObjectContext {
    public final func run<T>(_ work: @escaping (NSManagedObjectContext) throws -> T) async rethrows -> T {
        try await {
            try await withUnsafeContinuation { (continuation: UnsafeContinuation<Result<T, Error>, Never>) in
                perform {
                    continuation.resume(returning: .init(catching: { try work(self) }))
                }
            }.get()
        }()
    }

    public final func run<T>(_ work: @escaping () throws -> T) async rethrows -> T {
        try await run { _ in try work() }
    }
}
#endif
