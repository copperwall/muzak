require "yaml"

module Muzak
  module Cmd
    CONFIG_FILE = File.join(CONFIG_DIR, "muzak.yml")

    def _config_available?
      File.file?(CONFIG_FILE)
    end

    def _config_loaded?
      !!@config
    end

    def _config_sync
      debug "syncing config hash with #{CONFIG_FILE}"
      File.open(CONFIG_FILE, "w") { |io| io.write @config.to_yaml }
    end

    def _config_init
      debug "creating a config file in #{CONFIG_FILE}"

      @config = {
        "music" => File.expand_path("~/music"),
        "player" => "mpv",
      }

      Dir.mkdir(CONFIG_DIR) unless Dir.exist?(CONFIG_DIR)
      _config_sync
    end

    def config_load
      verbose "loading config from #{CONFIG_FILE}"

      @config = YAML::load_file(CONFIG_FILE)
    end

    def config_set(*args)
      return unless _config_loaded?

      fail_arity(args, 2)
      key, value = args
      return if key.nil? || value.nil?

      debug "setting '#{key}' to '#{value}' in config"

      @config[key] = value
      _config_sync
    end

    def config_del(*args)
      return unless _config_loaded?

      fail_arity(args, 1)
      key = args.shift
      return if key.nil?

      debug "removing '#{key}' from config"

      @config.delete(key)
      _config_sync
    end

    def config_get(*args)
      return unless _config_loaded?

      fail_arity(args, 1)
      key = args.shift
      return if key.nil?

      info "#{key}: #{@config[key]}"
    end
  end
end
