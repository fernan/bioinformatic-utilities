# bioinformatic-utilities
A random assortment of scripts, one-liners, for doing bioinformatics chores and dirty work

## Installing

Scripts are grouped into directories (`sequences/`, `alignments/`, `emboss/`, ...).
Only executable files at the top level of each directory are installed.


```sh
make                                   # list what would be installed, and where
make install                           # install scripts from all directories
make install DIRS=sequences            # ... from one directory
make install DIRS="alignments emboss"  # ... from several
make uninstall                         # remove them again (also accepts DIRS=)
```

By default scripts go to `~/.local/bin`, or to `~/bin` if that is on your `PATH`
and `~/.local/bin` is not. To install somewhere else:

```sh
make install PREFIX=/opt/bioutils      # -> /opt/bioutils/bin
make install BINDIR=$HOME/tools        # -> exactly $HOME/tools
```

Add `-n` (e.g. `make -n install`) for a dry run.


## Requirements

Check each script for specific requirements. Installing requires GNU `make`.
If `make --version` fails, install it first:

```sh
sudo apt install make        # Debian, Ubuntu, WSL
sudo dnf install make        # Fedora, RHEL, Rocky
sudo pacman -S make          # Arch
xcode-select --install       # macOS (Command Line Tools)
conda install -c conda-forge make   # no root access
```

On FreeBSD/OpenBSD, install `gmake` from packages and run `gmake` instead of `make`.

