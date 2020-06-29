require "cli"
require "colorize"
require "log"
require "system/user"
require "tallboy"
require "yaml"

require "./dfg/process_exec"
require "./dfg/dotfiles"

lib LibC
  fun getuid : UidT
end

module DotFilesConfig
  Version = {{ `shards version`.stringify.chomp }}

  class Dfg < Cli::Supercommand
    getter log = Log.for("dfg")

    version Version

    class Options
      help
      version
      string "--log-level", default: "info", any_of: %w(trace debug info notice warn error fatal)
    end

    class Help
      header "DotFilesConfig Manager (#{Version})"
      footer "Copyright (c) 2020 Jose Jorge Lorenzo Vila (jjlorenzo)"
    end

    def run
      DotFilesConfig.setup_logger args.log_level
      log.trace &.emit("<[opts]>", "log-level": args.log_level)
      super
    end
  end

  def self.setup_logger(level : String)
    Log.setup do |builder|
      colors = {
        Log::Severity::Trace  => :dark_gray,
        Log::Severity::Debug  => :dark_gray,
        Log::Severity::Info   => :green,
        Log::Severity::Notice => :blue,
        Log::Severity::Warn   => :yellow,
        Log::Severity::Error  => :red,
        Log::Severity::Fatal  => :red,
      }
      backend = Log::IOBackend.new
      backend.formatter = Log::Formatter.new do |entry, io|
        color = colors.fetch(entry.severity) { :default }
        prefix = String.build do |str|
          str << "[#{entry.timestamp.to_s("%Y-%m-%d.%H:%M:%S")}]".colorize color
          str << " "
          str << "(#{entry.source})".colorize :magenta
        end
        message = String.build do |str|
          entry.message.each_line do |line|
            str << prefix
            str << " "
            str << line.colorize color
            str << "\n"
          end
        end
        io << message.rchop
        unless entry.data.empty?
          if entry.message.includes? "\n"
            io << "\n"
            io << prefix
            io << " "
            io << entry.data.colorize color
          else
            io << " "
            io << entry.data.colorize color
          end
        end
      end
      builder.bind "*", Log::Severity.parse?(level) || Log::Severity::Info, backend
    end
  end

  def self.username
    System::User.find_by(id: LibC.getuid.to_s).name
  end
end
