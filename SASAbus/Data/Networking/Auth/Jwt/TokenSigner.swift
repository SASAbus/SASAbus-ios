import Foundation

public protocol TokenSigner {
    var signatureAlgorithm: SignatureAlgorithm { get }
    func sign(_ input: Data) throws -> Data
}
