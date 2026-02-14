# Docker Engine Client Example

This example demonstrates how to use the `DockerEngineClient` to connect to a Docker daemon.

## Overview

The `DockerEngineClient` provides a simple way to connect to Docker Engine daemons via Unix sockets. This enables interoperability between the `container` tool and Docker.

**Important**: This is a minimal implementation suitable for basic connectivity checking and version retrieval. For production use or high-frequency requests, consider enhancements such as:
- Proper HTTP response parsing with chunked transfer encoding support
- NIO-based async response handling instead of polling
- Connection pooling and reuse
- Comprehensive error handling for edge cases

## Basic Usage

```swift
import ContainerAPIClient
import Logging

let logger = Logger(label: "docker-client-example")

// Create a client with the default socket path
let client = DockerEngineClient(logger: logger)

// Or use a custom socket path
// let client = DockerEngineClient(socketPath: "/custom/docker.sock", logger: logger)

do {
    // Connect to the Docker daemon
    let connected = try await client.connect()
    
    if connected {
        print("Successfully connected to Docker Engine")
        
        // Get Docker version
        let version = try await client.getVersion()
        print("Docker Engine version: \(version)")
    }
} catch DockerEngineError.socketNotFound(let path) {
    print("Docker socket not found at: \(path)")
    print("Make sure Docker is installed and running.")
} catch {
    print("Error connecting to Docker: \(error)")
}
```

## Error Handling

The client provides specific error types for better error handling:

```swift
do {
    try await client.connect()
} catch DockerEngineError.socketNotFound(let path) {
    print("Socket not found: \(path)")
} catch DockerEngineError.connectionFailed(let message) {
    print("Connection failed: \(message)")
} catch DockerEngineError.invalidResponse {
    print("Received invalid response from Docker")
} catch DockerEngineError.requestFailed(let message) {
    print("Request failed: \(message)")
} catch {
    print("Unexpected error: \(error)")
}
```

## Requirements

- macOS 15 or later
- Swift 6.2 or later
- Docker installed and running (for actual connectivity)

## Running on macOS

Since this is part of the `container` tool that requires macOS with Apple silicon, you'll need:

1. macOS 15+ (macOS 26 recommended)
2. Apple silicon Mac
3. Xcode 26

Build and run from the repository root:

```bash
swift build
```

## Use Cases

- Checking if Docker is available on the system
- Getting Docker version information
- Enabling tools to work with both `container` and Docker
- Building hybrid applications that support multiple container runtimes
