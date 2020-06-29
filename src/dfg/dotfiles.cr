module DotFilesConfig
  class Dfg < Cli::Supercommand
    class Dotfiles < Cli::Supercommand
      getter log = Log.for("dfg.dotfiles")

      class_property git_dir = "~/.config/dfg/repo.git"
      class_property git_worktree_dir = "~"

      class Options
        help
        string "--git-dir", default: Dotfiles.git_dir
        string "--git-worktree-dir", default: Dotfiles.git_worktree_dir
      end

      def run
        log.trace &.emit("<[opts]>", "git-dir": args.git_dir)
        log.trace &.emit("<[opts]>", "git-worktree-dir": args.git_worktree_dir)
        Dotfiles.git_dir = args.git_dir
        Dotfiles.git_worktree_dir = args.git_worktree_dir
        Dir.cd Path[args.git_worktree_dir].expand(home: true)
        log.trace &.emit("<[opts]>", "work-dir": Dir.current)
        super
      end

      class Fetch < Cli::Command
        include ProcessExec
        getter log = Log.for("dfg.dotfiles.fetch")

        class Options
          username = System::User.find_by(id: LibC.getuid.to_s).name
          help
          arg "git-url", default: "https://#{username}@github.com/#{username}/dotfiles"
          string "--git-branch", default: "master"
          bool "--no-bootstrap", default: false
        end

        def run
          log.trace &.emit("<[opts]>", "git-url": args.git_url)
          log.trace &.emit("<[opts]>", "git-branch": args.git_branch)
          log.notice { String.build { |msg|
            msg << "remote"
            msg << " => ".colorize :dark_gray
            msg << "#{args.git_url} [#{args.git_branch}]".colorize :white
          } }

          # debug -> private dir perms (.ssh, .gnupg)
          # log.debug { Tallboy.table {
          #   header "Private File Permissions", align: :center
          #   rows [
          #     [".gnupg", "ugo"],
          #     [".ssh", "ugo"],
          #   ]
          # } }

          # exec("git", "ls-remote", CollectedArgs["git-url"])

          # unless args.no_bootstrap and exists
          # unless args.no_bootstrap?
          #   bootstrap = Path[".config/dfg/bootstrap"].expand(home: true)
          #   log.notice { String.build { |msg|
          #     msg << "script"
          #     msg << " => ".colorize :dark_gray
          #     msg << "#{bootstrap}".colorize :white
          #   } }
          #   exec(bootstrap)
          # end
        end
      end
    end
  end
end
