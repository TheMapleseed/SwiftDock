import Foundation

// Simulate Docker Images
public struct DockerImage {
    let name: String
    let tag: String
    
    public init(name: String, tag: String = "latest") {
        self.name = name
        self.tag = tag
    }
}

// Simulate Docker Containers
public class Container {
    let id: String
    var running: Bool
    let image: DockerImage
    var network: String?
    
    init(id: String, image: DockerImage) {
        self.id = id
        self.running = false
        self.image = image
    }
    
    func start() {
        running = true
        print("Container \(id) from image \(image.name):\(image.tag) has started.")
    }
    
    func stop() {
        running = false
        print("Container \(id) has stopped.")
    }
}

// Simulate Docker Engine
public class DockerEngine {
    private var images: [DockerImage] = []
    private var containers: [String: Container] = [:]
    private var networks: [String] = []
    
    // Function to execute Docker CLI commands
    private func runDockerCommand(arguments: [String]) -> String? {
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/docker")  // Adjust path if needed
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)
            return output
        } catch {
            print("Error running Docker command: \(error)")
            return nil
        }
    }
    
    // Image management
    public func buildImage(name: String, tag: String = "latest") {
        let output = runDockerCommand(arguments: ["build", "-t", "\(name):\(tag)", "."])  // Build image from Dockerfile in current directory
        if let output = output {
            print(output)
        }
    }
    
    public func pullImage(name: String, tag: String = "latest") {
        let output = runDockerCommand(arguments: ["pull", "\(name):\(tag)"])
        if let output = output {
            print(output)
        }
    }
    
    // Container management
    public func createContainer(image: DockerImage) -> String {
        let containerID = UUID().uuidString
        let output = runDockerCommand(arguments: ["run", "-d", "--name", containerID, "\(image.name):\(image.tag)"])
        if let output = output {
            print("Created container \(containerID) with image \(image.name):\(image.tag)")
            return containerID
        } else {
            print("Error creating container.")
            return ""
        }
    }
    
    public func startContainer(id: String) {
        let output = runDockerCommand(arguments: ["start", id])
        if let output = output {
            print("Started container \(id): \(output)")
        } else {
            print("Error starting container \(id).")
        }
    }
    
    public func stopContainer(id: String) {
        let output = runDockerCommand(arguments: ["stop", id])
        if let output = output {
            print("Stopped container \(id): \(output)")
        } else {
            print("Error stopping container \(id).")
        }
    }
    
    // Networking simulation
    public func createNetwork(name: String) {
        let output = runDockerCommand(arguments: ["network", "create", name])
        if let output = output {
            print("Created network: \(name) - \(output)")
        }
    }
    
    public func connectContainerToNetwork(containerID: String, networkName: String) {
        let output = runDockerCommand(arguments: ["network", "connect", networkName, containerID])
        if let output = output {
            print("Connected container \(containerID) to network \(networkName): \(output)")
        } else {
            print("Error connecting container to network.")
        }
    }
    
    // List operations
    public func listImages() {
        let output = runDockerCommand(arguments: ["images", "--format", "{{.Repository}}:{{.Tag}}"])
        if let output = output {
            print("Docker Images:\n\(output)")
        }
    }
    
    public func listContainers() {
        let output = runDockerCommand(arguments: ["ps", "--format", "{{.ID}}:{{.Image}} Running:{{.Status}}"])
        if let output = output {
            print("Docker Containers:\n\(output)")
        }
    }
    
    public func listNetworks() {
        let output = runDockerCommand(arguments: ["network", "ls", "--format", "{{.Name}}"])
        if let output = output {
            print("Docker Networks:\n\(output)")
        }
    }
}

// Usage Example
let docker = DockerEngine()

// Image operations
docker.pullImage(name: "nginx")

// Container operations
let containerID = docker.createContainer(image: DockerImage(name: "nginx"))
docker.startContainer(id: containerID)

// Network operations
docker.createNetwork(name: "my-network")
docker.connectContainerToNetwork(containerID: containerID, networkName: "my-network")

// Listing
docker.listImages()
docker.listContainers()
docker.listNetworks()
