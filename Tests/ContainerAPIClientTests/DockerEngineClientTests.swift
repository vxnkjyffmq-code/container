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
import Testing

@testable import ContainerAPIClient

struct DockerEngineClientTests {
    
    @Test("Initialize DockerEngineClient with default socket path")
    func testDefaultInitialization() {
        let client = DockerEngineClient()
        #expect(client.socketPath == "/var/run/docker.sock")
    }
    
    @Test("Initialize DockerEngineClient with custom socket path")
    func testCustomSocketPath() {
        let customPath = "/custom/docker.sock"
        let client = DockerEngineClient(socketPath: customPath)
        #expect(client.socketPath == customPath)
    }
    
    @Test("Connect fails when socket doesn't exist")
    func testConnectWithNonexistentSocket() async {
        let client = DockerEngineClient(socketPath: "/nonexistent/docker.sock")
        
        await #expect(throws: DockerEngineError.self) {
            try await client.connect()
        }
    }
    
    @Test("DockerEngineError descriptions")
    func testErrorDescriptions() {
        let socketNotFoundError = DockerEngineError.socketNotFound(path: "/test/path")
        #expect(socketNotFoundError.description.contains("/test/path"))
        
        let connectionFailedError = DockerEngineError.connectionFailed("test reason")
        #expect(connectionFailedError.description.contains("test reason"))
        
        let invalidResponseError = DockerEngineError.invalidResponse
        #expect(!invalidResponseError.description.isEmpty)
        
        let requestFailedError = DockerEngineError.requestFailed("test error")
        #expect(requestFailedError.description.contains("test error"))
    }
}
