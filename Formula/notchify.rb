class Notchify < Formula
  desc "Pixel mascot for Claude Code that lives in your MacBook notch"
  homepage "https://github.com/kikudjira/notchify"
  url "https://github.com/kikudjira/notchify/releases/download/v1.0.5/Notchify-v1.0.5.zip"
  sha256 "4f9cf1b41cc09db66f8027d62d0bdd69395ca8beb86be85abf4815f6372b999d"
  version "1.0.5"

  depends_on :macos => :monterey

  def install
    prefix.install "Notchify.app"
    bin.install_symlink "#{prefix}/Notchify.app/Contents/MacOS/notchify-cli" => "notchify"
  end

  def post_install
    home = Pathname.new(Dir.home)

    # ---- App path ----
    config_dir = home/".config/notchify"
    config_dir.mkpath
    (config_dir/"app_path").write "#{prefix}/Notchify.app\n"

    # ---- Default sounds ----
    sounds_file = config_dir/"sounds.json"
    unless sounds_file.exist?
      sounds_file.write <<~JSON
        {
          "start":   { "system": "Hero" },
          "done":    { "system": "Glass" },
          "waiting": { "system": "Ping" },
          "error":   { "system": "Basso" },
          "working": null,
          "idle":    null
        }
      JSON
    end

    # ---- Claude Code hooks ----
    claude_settings = home/".claude/settings.json"
    if claude_settings.exist?
      system "/usr/bin/python3", "-c", <<~PYTHON, claude_settings.to_s
        import json, sys
        path = sys.argv[1]
        with open(path) as f:
            s = json.load(f)
        hooks = s.setdefault("hooks", {})
        def add(event, cmd):
            entries = hooks.setdefault(event, [])
            if not any(cmd in str(e) for e in entries):
                entries.append({"hooks": [{"type": "command", "command": cmd}]})
        cli = "#{bin}/notchify"
        add("UserPromptSubmit", cli + " set working")
        add("Stop",             cli + " set done")
        add("Notification",     cli + " set waiting")
        with open(path, "w") as f:
            json.dump(s, f, indent=2)
      PYTHON
    end

    # ---- Shell wrapper for startup animation ----
    [home/".zshrc", home/".bashrc"].each do |rc|
      next unless rc.exist?
      next if rc.read.include?("notchify set start")
      rc.open("a") do |f|
        f.write <<~SHELL

          # Added by Notchify
          function claude() {
            #{bin}/notchify set start
            command claude "$@"
            #{bin}/notchify set bye
          }
        SHELL
      end
    end
  end

  def caveats
    <<~EOS
      Notchify is not notarized. Before launching, remove quarantine:
        xattr -dr com.apple.quarantine #{prefix}/Notchify.app

      Then launch the app:
        notchify launch

      Configure hooks, sounds and login item:
        notchify config

      To add Notchify to login items automatically, open System Settings →
      General → Login Items and add:
        #{prefix}/Notchify.app
    EOS
  end

  test do
    assert_predicate prefix/"Notchify.app", :exist?
    assert_predicate bin/"notchify", :exist?
  end
end
