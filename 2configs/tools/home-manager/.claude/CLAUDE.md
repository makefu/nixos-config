Available Tools

    fd, rg, dnsutils, lsof, gdb, binutils
    On Linux: strace

General Guidelines

    Follow XDG desktop standards when writing code
    Use $HOME/.claude/outputs/{project_name} as a scratch directory for prompts and temporary files.

Nix-specific

    When creating new projects, ensure to always create a `flake.nix`
    Use nix log /nix/store/xxxx | grep <key-word> to inspect failed nix builds
    Always track new untracked files in Nix flakes with `git add -AN`
    To get a rebuild of a nix package change the nix expression instead of --rebuild
    Prefer nix to fetch python dependencies
    prefer python dependencies directly from nixpkgs, avoid sideloaded packages
    When looking for build dependencies in a nix-shell/nix develop, check environment variables for store paths to find the correct dependency versions.
    Use nix-locate to find packages by path. i.e. nix-locate bin/ip
    Use nix run to execute applications that are not installed.
    Use nix eval instead of nix flake show to look up attributes in a flake.
    Generate/Update patch files for packages:
        git clone
        Optional: apply existing patch
        Apply edits
        Use git format-patch for a new patch

Code Quality & Testing

    practice TDD
    Write shell scripts that pass shellcheck.
    Write Python code for 3.13 that conforms to ruff format, ruff check and mypy
    Add debug output or unit tests when troubleshooting i.e. dbg!() in Rust
    When writing test use realistic inputs/outputs that test the actual code as opposed to mocked out versions
    Start fixing bugs by implementing a failing regression test first.
    When a linter is detecting dead code, remove the dead code.
    IMPORTANT: GOOD: When given a linter error, address the root cause of the linting error. BAD: silencing lint errors. Exhaustivly fix all linter errors.

Git

    When writing commit messages/comments focus on the WHY rather than the WHAT.
    Use kernel-mailing style commit messages
    Always test/lint/format your code before committing.

Running programs

    CRITICAL: ALWAYS use pueue for ANY command that might take longer than 10 seconds to avoid timeouts. This includes but is not limited to:
        nix build commands
        machine deployment commands
        Any test runs that might be slow
        Any build operations (make, ninja, cargo)

    To run and wait (note: quote the entire command to preserve argument quoting):

    pueue add -- 'command arg1 "arg with spaces"'
    pueue follow <task-id> | tail -n 10 # waits for the command to finish

Search

    Recommended: Use GitHub code search to find examples for libraries and APIs: gh search code "foo lang:nix".
    Prefer cloning source code over web searches for more accurate results. Various projects are available in ~/repos, "special" repos are ~/nixpkgs, and ~/nixos-config

