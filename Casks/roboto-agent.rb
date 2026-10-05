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

  version "0.59.0"
  if OS.mac?
    sha256 arm: "2c3c9639135c9c7cc51ced84735c7d463050cdd78b4fa52d941f60777a544f89",
           intel: "01942e7ef4885bbd259f2a5960280ec49349eae5d03352b5661cadd3ee64576f"
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
