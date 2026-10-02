cask "roboto-agent" do
  # Force commit
  module Utils
    @@os = OS.mac? ? "macos" : OS.kernel_name.downcase
    @@arch = Hardware::CPU.arch.to_s.sub("arm64", "aarch64")
    def self.os
      @@os
    end
    def self.arch
      @@arch
    end
    def self.binary
      "roboto-agent-#{@@os}-#{@@arch}"
    end
  end

  version "0.58.0"
  if OS.mac?
    sha256 arm: "f6a25fa67c2a81db8319b640323a178e6498f4e113bb16bbaa9647bdd0983092",
           intel: "5b543c6d63cbad4bd62f1005a80a29c464dfa132ec440d0a88d282dfc4ba68b6"
  else
    # Casks not supported on Linux: https://github.com/Linuxbrew/brew/issues/742
    # sha256 arm: "...",
    #        intel: "..."
  end
  url "https://github.com/roboto-ai/roboto-python-sdk/releases/download/v#{version}/roboto-agent-#{Utils.os}-#{Utils.arch}"

  name "Roboto Agent"
  desc "Device agent for automatically uploading data to Roboto"
  homepage "https://roboto.ai"

  depends_on arch: [:arm64, :x86_64]

  binary Utils.binary, target: "roboto-agent"

  # Upgrades and reinstalls unlink the previous version before this runs, so a `roboto-agent` here is a separate
  # copy that Homebrew won't replace, most likely a downloaded release binary.
  preflight_steps do
    if_path_exists "bin/roboto-agent", base: :homebrew_prefix do
      warn "{{HOMEBREW_PREFIX}}/bin/roboto-agent already exists and isn't from this cask, so Homebrew won't " \
           "replace it. You can remove or move it, then try again."
    end
  end

  # The release binary is only ad-hoc signed, so Gatekeeper blocks it while it carries the quarantine
  # attribute Homebrew puts on cask downloads.
  postflight_steps do
    on_macos do
      run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{staged_path}}"]
    end
  end
end
