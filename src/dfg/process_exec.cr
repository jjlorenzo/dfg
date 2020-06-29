module DotFilesConfig
  module ProcessExec
    def exec(cmd : String, *args : String, errexit : Bool = true)
      ::Process.run(cmd, args) do |process|
        spawn do
          process.error.each_line do |line|
            log.error { line }
          end
        end
        process.output.each_line do |line|
          log.notice { line }
        end
      end
      exit! if errexit && !$?.success?
    end

    def foo
    end
  end
end
