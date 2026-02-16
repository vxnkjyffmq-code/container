class Container < Formula
  desc "Create and run Linux containers as lightweight virtual machines on your Mac"
  homepage "https://github.com/apple/container"
  # Note: This formula is currently designed for HEAD installations only.
  # Update the url, tag, and revision when creating a stable release.
  url "https://github.com/apple/container.git",
      tag:      "v0.0.0",
      revision: "0000000000000000000000000000000000000000"
  license "Apache-2.0"
  head "https://github.com/apple/container.git", branch: "main"

  depends_on :macos => :sequoia
  depends_on arch: :arm64
  depends_on xcode: ["16.0", :build]

  def install
    # Build the project using Swift Package Manager
    system "swift", "build", "-c", "release", "--disable-sandbox"

    # Get the build directory
    build_bin_dir = ".build/release"

    # Install main CLI binary
    bin.install "#{build_bin_dir}/container"
    bin.install "#{build_bin_dir}/container-apiserver"

    # Install helper scripts
    bin.install "scripts/uninstall-container.sh"

    # Create libexec directories for plugins
    (libexec/"container/plugins/container-runtime-linux/bin").mkpath
    (libexec/"container/plugins/container-network-vmnet/bin").mkpath
    (libexec/"container/plugins/container-core-images/bin").mkpath

    # Install plugin binaries
    (libexec/"container/plugins/container-runtime-linux/bin").install "#{build_bin_dir}/container-runtime-linux"
    (libexec/"container/plugins/container-network-vmnet/bin").install "#{build_bin_dir}/container-network-vmnet"
    (libexec/"container/plugins/container-core-images/bin").install "#{build_bin_dir}/container-core-images"

    # Install plugin configurations
    (libexec/"container/plugins/container-runtime-linux").install "config/container-runtime-linux-config.json" => "config.json"
    (libexec/"container/plugins/container-network-vmnet").install "config/container-network-vmnet-config.json" => "config.json"
    (libexec/"container/plugins/container-core-images").install "config/container-core-images-config.json" => "config.json"
  end

  def caveats
    <<~EOS
      Before using container, you need to start the system service:
        container system start

      To stop the service:
        container system stop

      To uninstall container completely:
        uninstall-container.sh -d

      Note: container is officially supported on macOS 26, which includes optimizations
      for virtualization and networking. While this formula can build on macOS 15 (Sequoia),
      full functionality and support are only guaranteed on macOS 26.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/container --version")
  end
end
