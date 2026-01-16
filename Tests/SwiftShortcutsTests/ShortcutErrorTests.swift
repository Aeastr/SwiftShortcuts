//
//  ShortcutErrorTests.swift
//  SwiftShortcuts
//

import Testing
import Foundation
@testable import SwiftShortcuts

@Suite("ShortcutError")
struct ShortcutErrorTests {

    // MARK: - Error Cases

    @Test("invalidURL provides descriptive messages")
    func invalidURLError() {
        let error = ShortcutError.invalidURL("not-a-valid-url")

        #expect(error.errorDescription == "Invalid URL")
        #expect(error.failureReason?.contains("not-a-valid-url") == true)
        #expect(error.recoverySuggestion != nil)
    }

    @Test("networkError wraps underlying error")
    func networkError() {
        let underlying = URLError(.notConnectedToInternet)
        let error = ShortcutError.networkError(underlying: underlying)

        #expect(error.errorDescription == "Network Error")
        #expect(error.failureReason?.contains("network error") == true)
        #expect(error.recoverySuggestion?.contains("internet connection") == true)
    }

    @Test("invalidResponse includes status code when available")
    func invalidResponseWithStatusCode() {
        let error = ShortcutError.invalidResponse(statusCode: 404)

        #expect(error.errorDescription == "Invalid Response")
        #expect(error.failureReason?.contains("404") == true)
    }

    @Test("invalidResponse handles nil status code")
    func invalidResponseWithoutStatusCode() {
        let error = ShortcutError.invalidResponse(statusCode: nil)

        #expect(error.errorDescription == "Invalid Response")
        #expect(error.failureReason?.contains("invalid response") == true)
    }

    @Test("decodingFailed wraps underlying error")
    func decodingFailedError() {
        let underlying = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test"))
        let error = ShortcutError.decodingFailed(underlying: underlying)

        #expect(error.errorDescription == "Decoding Failed")
        #expect(error.failureReason != nil)
    }

    @Test("parsingFailed includes reason")
    func parsingFailedError() {
        let error = ShortcutError.parsingFailed(reason: "Invalid property list format")

        #expect(error.errorDescription == "Parsing Failed")
        #expect(error.failureReason == "Invalid property list format")
    }

    @Test("resourceNotFound includes resource name")
    func resourceNotFoundError() {
        let error = ShortcutError.resourceNotFound(resource: "abc123")

        #expect(error.errorDescription == "Resource Not Found")
        #expect(error.failureReason?.contains("abc123") == true)
    }

    @Test("metadataFetchFailed includes URL")
    func metadataFetchFailedError() {
        let underlying = URLError(.timedOut)
        let error = ShortcutError.metadataFetchFailed(url: "https://example.com/shortcut", underlying: underlying)

        #expect(error.errorDescription == "Failed to Load Shortcut")
        #expect(error.failureReason?.contains("https://example.com/shortcut") == true)
    }

    @Test("imageFetchFailed includes URL")
    func imageFetchFailedError() {
        let error = ShortcutError.imageFetchFailed(url: "https://example.com/icon.png")

        #expect(error.errorDescription == "Failed to Load Image")
        #expect(error.failureReason?.contains("https://example.com/icon.png") == true)
    }

    @Test("actionsFetchFailed includes URL")
    func actionsFetchFailedError() {
        let underlying = URLError(.badServerResponse)
        let error = ShortcutError.actionsFetchFailed(url: "https://example.com/shortcut.plist", underlying: underlying)

        #expect(error.errorDescription == "Failed to Load Actions")
        #expect(error.failureReason?.contains("https://example.com/shortcut.plist") == true)
    }

    // MARK: - Equatable

    @Test("Same errors are equal")
    func sameErrorsEqual() {
        #expect(ShortcutError.invalidURL("test") == ShortcutError.invalidURL("test"))
        #expect(ShortcutError.invalidResponse(statusCode: 404) == ShortcutError.invalidResponse(statusCode: 404))
        #expect(ShortcutError.invalidResponse(statusCode: nil) == ShortcutError.invalidResponse(statusCode: nil))
        #expect(ShortcutError.parsingFailed(reason: "test") == ShortcutError.parsingFailed(reason: "test"))
        #expect(ShortcutError.resourceNotFound(resource: "abc") == ShortcutError.resourceNotFound(resource: "abc"))
        #expect(ShortcutError.imageFetchFailed(url: "url") == ShortcutError.imageFetchFailed(url: "url"))
    }

    @Test("Different errors are not equal")
    func differentErrorsNotEqual() {
        #expect(ShortcutError.invalidURL("a") != ShortcutError.invalidURL("b"))
        #expect(ShortcutError.invalidResponse(statusCode: 404) != ShortcutError.invalidResponse(statusCode: 500))
        #expect(ShortcutError.invalidResponse(statusCode: 404) != ShortcutError.invalidResponse(statusCode: nil))
        #expect(ShortcutError.parsingFailed(reason: "a") != ShortcutError.parsingFailed(reason: "b"))
    }

    @Test("Different error types are not equal")
    func differentTypesNotEqual() {
        let underlying = URLError(.badURL)
        #expect(ShortcutError.invalidURL("test") != ShortcutError.networkError(underlying: underlying))
        #expect(ShortcutError.invalidResponse(statusCode: 404) != ShortcutError.resourceNotFound(resource: "404"))
    }

    @Test("networkError equality ignores underlying error details")
    func networkErrorEquality() {
        let error1 = ShortcutError.networkError(underlying: URLError(.notConnectedToInternet))
        let error2 = ShortcutError.networkError(underlying: URLError(.timedOut))

        // networkError cases are equal regardless of underlying error
        #expect(error1 == error2)
    }

    @Test("decodingFailed equality ignores underlying error details")
    func decodingFailedEquality() {
        let error1 = ShortcutError.decodingFailed(underlying: URLError(.badURL))
        let error2 = ShortcutError.decodingFailed(underlying: URLError(.timedOut))

        // decodingFailed cases are equal regardless of underlying error
        #expect(error1 == error2)
    }

    @Test("metadataFetchFailed equality compares URL only")
    func metadataFetchFailedEquality() {
        let error1 = ShortcutError.metadataFetchFailed(url: "url1", underlying: URLError(.badURL))
        let error2 = ShortcutError.metadataFetchFailed(url: "url1", underlying: URLError(.timedOut))
        let error3 = ShortcutError.metadataFetchFailed(url: "url2", underlying: URLError(.badURL))

        #expect(error1 == error2) // Same URL, different underlying
        #expect(error1 != error3) // Different URL
    }

    // MARK: - Identifiable

    @Test("Each error has a unique ID")
    func uniqueIds() {
        let errors: [ShortcutError] = [
            .invalidURL("url1"),
            .invalidURL("url2"),
            .networkError(underlying: URLError(.badURL)),
            .invalidResponse(statusCode: 404),
            .invalidResponse(statusCode: nil),
            .decodingFailed(underlying: URLError(.badURL)),
            .parsingFailed(reason: "reason1"),
            .resourceNotFound(resource: "res1"),
            .metadataFetchFailed(url: "url1", underlying: URLError(.badURL)),
            .imageFetchFailed(url: "url1"),
            .actionsFetchFailed(url: "url1", underlying: URLError(.badURL))
        ]

        let ids = Set(errors.map(\.id))
        #expect(ids.count == errors.count)
    }

    @Test("Same error produces same ID")
    func consistentIds() {
        let error1 = ShortcutError.invalidURL("test")
        let error2 = ShortcutError.invalidURL("test")

        #expect(error1.id == error2.id)
    }
}

@Suite("ShortcutErrorContext")
struct ShortcutErrorContextTests {

    @Test("Initializes with source and URL")
    func initWithSourceAndURL() {
        let context = ShortcutErrorContext(source: .tile, url: "https://example.com")

        #expect(context.source == .tile)
        #expect(context.url == "https://example.com")
    }

    @Test("Initializes with source only")
    func initWithSourceOnly() {
        let context = ShortcutErrorContext(source: .service)

        #expect(context.source == .service)
        #expect(context.url == nil)
    }

    @Test("Source has correct raw values")
    func sourceRawValues() {
        #expect(ShortcutErrorContext.Source.tile.rawValue == "ShortcutTile")
        #expect(ShortcutErrorContext.Source.detail.rawValue == "ShortcutDetailView")
        #expect(ShortcutErrorContext.Source.actions.rawValue == "ShortcutActionsView")
        #expect(ShortcutErrorContext.Source.service.rawValue == "ShortcutService")
    }
}

@Suite("ShortcutErrorHandler")
struct ShortcutErrorHandlerTests {

    @Test("Handler closure is called with error and context")
    func handlerIsCalled() {
        // Use a class to capture values in a Sendable way
        final class Capture: @unchecked Sendable {
            var error: ShortcutError?
            var context: ShortcutErrorContext?
        }

        let capture = Capture()

        let handler = ShortcutErrorHandler { error, context in
            capture.error = error
            capture.context = context
        }

        let testError = ShortcutError.invalidURL("test-url")
        let testContext = ShortcutErrorContext(source: .tile, url: "test-url")

        handler(error: testError, context: testContext)

        #expect(capture.error == testError)
        #expect(capture.context?.source == .tile)
        #expect(capture.context?.url == "test-url")
    }
}
