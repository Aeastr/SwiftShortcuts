//
//  ShortcutError.swift
//  SwiftShortcuts
//

import Foundation

/// Errors that can occur when fetching or interacting with shortcuts.
public enum ShortcutError: LocalizedError, Sendable {
    /// The provided URL is invalid or malformed.
    case invalidURL(String)

    /// A network error occurred during the request.
    case networkError(underlying: any Error)

    /// The server returned an invalid response.
    case invalidResponse(statusCode: Int?)

    /// Failed to decode the response data.
    case decodingFailed(underlying: any Error)

    /// Failed to parse the response data.
    case parsingFailed(reason: String)

    /// The requested resource was not found.
    case resourceNotFound(resource: String)

    /// Failed to fetch shortcut metadata.
    case metadataFetchFailed(url: String, underlying: any Error)

    /// Failed to fetch the shortcut's image.
    case imageFetchFailed(url: String)

    /// Failed to fetch the shortcut's workflow actions.
    case actionsFetchFailed(url: String, underlying: any Error)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError:
            return "Network Error"
        case .invalidResponse:
            return "Invalid Response"
        case .decodingFailed:
            return "Decoding Failed"
        case .parsingFailed:
            return "Parsing Failed"
        case .resourceNotFound:
            return "Resource Not Found"
        case .metadataFetchFailed:
            return "Failed to Load Shortcut"
        case .imageFetchFailed:
            return "Failed to Load Image"
        case .actionsFetchFailed:
            return "Failed to Load Actions"
        }
    }

    public var failureReason: String? {
        switch self {
        case .invalidURL(let urlString):
            return "The URL '\(urlString)' is invalid or malformed."
        case .networkError(let underlying):
            return "A network error occurred: \(underlying.localizedDescription)"
        case .invalidResponse(let statusCode):
            if let code = statusCode {
                return "The server returned status code \(code)."
            }
            return "The server returned an invalid response."
        case .decodingFailed(let underlying):
            return "Failed to decode the response: \(underlying.localizedDescription)"
        case .parsingFailed(let reason):
            return reason
        case .resourceNotFound(let resource):
            return "The resource '\(resource)' could not be found."
        case .metadataFetchFailed(let url, let underlying):
            return "Failed to fetch metadata from '\(url)': \(underlying.localizedDescription)"
        case .imageFetchFailed(let url):
            return "Failed to load image from '\(url)'."
        case .actionsFetchFailed(let url, let underlying):
            return "Failed to fetch actions from '\(url)': \(underlying.localizedDescription)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Check that the URL is correctly formatted."
        case .networkError:
            return "Check your internet connection and try again."
        case .invalidResponse:
            return "The shortcut may no longer be available. Try again later."
        case .decodingFailed, .parsingFailed:
            return "The shortcut data format may have changed. Try updating the library."
        case .resourceNotFound:
            return "Verify the shortcut ID or URL is correct."
        case .metadataFetchFailed, .imageFetchFailed, .actionsFetchFailed:
            return "Check your internet connection and try again."
        }
    }
}

// MARK: - Equatable

extension ShortcutError: Equatable {
    public static func == (lhs: ShortcutError, rhs: ShortcutError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL(let a), .invalidURL(let b)):
            return a == b
        case (.networkError, .networkError):
            return true
        case (.invalidResponse(let a), .invalidResponse(let b)):
            return a == b
        case (.decodingFailed, .decodingFailed):
            return true
        case (.parsingFailed(let a), .parsingFailed(let b)):
            return a == b
        case (.resourceNotFound(let a), .resourceNotFound(let b)):
            return a == b
        case (.metadataFetchFailed(let urlA, _), .metadataFetchFailed(let urlB, _)):
            return urlA == urlB
        case (.imageFetchFailed(let a), .imageFetchFailed(let b)):
            return a == b
        case (.actionsFetchFailed(let urlA, _), .actionsFetchFailed(let urlB, _)):
            return urlA == urlB
        default:
            return false
        }
    }
}

// MARK: - Identifiable

extension ShortcutError: Identifiable {
    public var id: String {
        switch self {
        case .invalidURL(let url):
            return "invalidURL:\(url)"
        case .networkError:
            return "networkError"
        case .invalidResponse(let code):
            return "invalidResponse:\(code ?? 0)"
        case .decodingFailed:
            return "decodingFailed"
        case .parsingFailed(let reason):
            return "parsingFailed:\(reason)"
        case .resourceNotFound(let resource):
            return "resourceNotFound:\(resource)"
        case .metadataFetchFailed(let url, _):
            return "metadataFetchFailed:\(url)"
        case .imageFetchFailed(let url):
            return "imageFetchFailed:\(url)"
        case .actionsFetchFailed(let url, _):
            return "actionsFetchFailed:\(url)"
        }
    }
}
