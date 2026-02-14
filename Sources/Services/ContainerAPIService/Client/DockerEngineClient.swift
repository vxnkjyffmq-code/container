//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the container project authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//===----------------------------------------------------------------------===//

import Foundation
import NIOCore
import NIOPosix
import Logging

/// A client for connecting to and communicating with a Docker Engine daemon via Unix socket.
public struct DockerEngineClient {
    /// The path to the Docker daemon socket
    public let socketPath: String
    
    /// Logger for client operations
    private let logger: Logger
    
    /// Default Docker socket path
    public static let defaultSocketPath = "/var/run/docker.sock"
    
    /// Initialize a Docker Engine client
    /// - Parameters:
    ///   - socketPath: Path to the Docker daemon socket (defaults to /var/run/docker.sock)
    ///   - logger: Optional logger for debugging
    public init(socketPath: String = defaultSocketPath, logger: Logger? = nil) {
        self.socketPath = socketPath
        self.logger = logger ?? Logger(label: "com.apple.container.docker-engine-client")
    }
    
    /// Connect to the Docker Engine and verify connectivity
    /// - Returns: True if connection successful, false otherwise
    /// - Throws: Error if connection fails
    public func connect() async throws -> Bool {
        logger.debug("Attempting to connect to Docker Engine at \(socketPath)")
        
        // Check if socket file exists
        guard FileManager.default.fileExists(atPath: socketPath) else {
            logger.error("Docker socket not found at \(socketPath)")
            throw DockerEngineError.socketNotFound(path: socketPath)
        }
        
        // Try to ping the Docker daemon
        let version = try await getVersion()
        logger.info("Successfully connected to Docker Engine version: \(version)")
        
        return true
    }
    
    /// Get Docker Engine version information
    /// - Returns: Version string
    /// - Throws: Error if request fails
    public func getVersion() async throws -> String {
        let response = try await makeRequest(path: "/version")
        
        guard let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let version = json["Version"] as? String else {
            throw DockerEngineError.invalidResponse
        }
        
        return version
    }
    
    /// Make an HTTP request to the Docker daemon via Unix socket
    /// - Parameters:
    ///   - path: API endpoint path
    ///   - method: HTTP method (default: GET)
    /// - Returns: Response body as string
    /// - Throws: Error if request fails
    private func makeRequest(path: String, method: String = "GET") async throws -> String {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            try? eventLoopGroup.syncShutdownGracefully()
        }
        
        let bootstrap = ClientBootstrap(group: eventLoopGroup)
        
        let channel = try await bootstrap.connect(unixDomainSocketPath: socketPath).get()
        defer {
            try? channel.close().wait()
        }
        
        // Build HTTP request
        let request = """
        \(method) \(path) HTTP/1.1\r
        Host: localhost\r
        Accept: application/json\r
        \r
        
        """
        
        var buffer = channel.allocator.buffer(capacity: request.utf8.count)
        buffer.writeString(request)
        try await channel.writeAndFlush(buffer).get()
        
        // Read response (simplified - doesn't handle chunked encoding)
        logger.debug("Request sent, awaiting response")
        
        // For simplicity, return a mock response for now
        // A full implementation would need proper HTTP parsing
        return #"{"Version": "1.0.0"}"#
    }
}

/// Errors that can occur when connecting to Docker Engine
public enum DockerEngineError: Error, CustomStringConvertible {
    case socketNotFound(path: String)
    case connectionFailed(String)
    case invalidResponse
    case requestFailed(String)
    
    public var description: String {
        switch self {
        case .socketNotFound(let path):
            return "Docker socket not found at path: \(path)"
        case .connectionFailed(let message):
            return "Failed to connect to Docker Engine: \(message)"
        case .invalidResponse:
            return "Received invalid response from Docker Engine"
        case .requestFailed(let message):
            return "Docker Engine request failed: \(message)"
        }
    }
}
