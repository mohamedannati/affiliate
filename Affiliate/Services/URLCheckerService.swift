//
//  URLCheckerService.swift
//  Affiliate
//
//  Validates affiliate / website links using URLSession.
//

import Foundation
import Network

final class URLCheckerService {

    enum CheckError: LocalizedError {
        case empty
        case malformed
        case notAllowed(String)

        var errorDescription: String? {
            switch self {
            case .empty:
                return "Enter a link first."
            case .malformed:
                return "That doesn't look like a valid URL."
            case .notAllowed(let host):
                return "“\(host)” is not an approved MyStake destination."
            }
        }
    }

    private static let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 30
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        return URLSession(configuration: config)
    }()

    private static func normalizedURL(from raw: String) throws -> URL {
        let trimmed = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "。"))

        guard !trimmed.isEmpty else { throw CheckError.empty }

        var candidate = trimmed
        if !candidate.lowercased().hasPrefix("http://"),
           !candidate.lowercased().hasPrefix("https://") {
            candidate = "https://" + candidate
        }

        guard let url = URL(string: candidate),
              let host = url.host?.lowercased() else {
            throw CheckError.malformed
        }

        guard AppConfig.allowedHosts.contains(where: { host == $0 || host.hasSuffix("." + $0) }) else {
            throw CheckError.notAllowed(host)
        }

        return url
    }

    /// Validates the link and reports a result on the main thread.
    static func check(url raw: String) async -> CheckResult {
        do {
            let url = try normalizedURL(from: raw)
            return await request(url)
        } catch {
            return CheckResult(kind: .invalid(reason: error.localizedDescription))
        }
    }

    private static func request(_ url: URL) async -> CheckResult {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.setValue("Affiliate/\(AppConfig.appVersion) (iOS link checker)",
                         forHTTPHeaderField: "User-Agent")

        do {
            // Some servers do not answer HEAD; retry with GET once.
            let (_, response) = try await session.data(for: request)
            if let http = response as? HTTPURLResponse {
                let code = http.statusCode
                if (200..<400).contains(code) {
                    return CheckResult(kind: .valid(code: code))
                } else {
                    return CheckResult(kind: .invalid(reason: "Server answered HTTP \(code)."))
                }
            }
            return CheckResult(kind: .valid(code: 0))
        } catch let error as URLError where error.code == .unsupportedURL {
            var getRequest = request
            getRequest.httpMethod = "GET"
            do {
                let (_, response) = try await session.data(for: getRequest)
                if let http = response as? HTTPURLResponse {
                    let code = http.statusCode
                    if (200..<400).contains(code) {
                        return CheckResult(kind: .valid(code: code))
                    }
                    return CheckResult(kind: .invalid(reason: "Server answered HTTP \(code)."))
                }
                return CheckResult(kind: .valid(code: 0))
            } catch {
                return CheckResult(kind: .unreachable(reason: friendlyMessage(error)))
            }
        } catch {
            return CheckResult(kind: .unreachable(reason: friendlyMessage(error)))
        }
    }

    private static func friendlyMessage(_ error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return "The request timed out. The server may be slow right now."
            case .notConnectedToInternet, .networkConnectionLost:
                return "No internet connection. Check your network and try again."
            case .cannotFindHost, .dnsLookupFailed:
                return "The domain could not be found."
            case .serverCertificateHasBadDate, .serverCertificateUntrusted, .serverCertificateNotYetValid:
                return "The server's security certificate could not be verified."
            case .cancelled:
                return "The check was cancelled."
            default:
                break
            }
        }
        return "Could not reach the destination. Please try again."
    }

    // MARK: - Connectivity

    static func isOnline() async -> Bool {
        await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "affiliate.network.check")
            monitor.pathUpdateHandler = { path in
                continuation.resume(returning: path.status == .satisfied)
                monitor.cancel()
            }
            monitor.start(queue: queue)
        }
    }
}
