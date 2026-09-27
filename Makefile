# Install scripts from one or more directories into a user bin directory.
#
#   make                                   # list what would be installed, and where
#   make install                           # scripts from every directory
#   make install DIRS=sequences            # scripts from one directory
#   make install DIRS="alignments emboss"  # scripts from several directories
#   make install PREFIX=/opt/bioutils      # installs into /opt/bioutils/bin
#   make install BINDIR=$HOME/tools        # installs into exactly this directory
#   make uninstall [DIRS=...]              # remove installed scripts
#   make -n install                        # dry run
#
# Only executable files at the top level of each directory are installed,
# so READMEs, test data, etc. can live alongside the scripts.

# Default to every top-level directory (hidden ones are skipped).
DIRS    ?= $(patsubst %/,%,$(wildcard */))
SRCDIRS := $(patsubst %/,%,$(DIRS))
MISSING := $(filter-out $(patsubst %/,%,$(wildcard $(addsuffix /,$(SRCDIRS)))),$(SRCDIRS))
ifneq ($(MISSING),)
  $(error No such directory: $(MISSING))
endif

SCRIPTS := $(if $(SRCDIRS),$(shell find $(SRCDIRS) -maxdepth 1 -type f -perm -u+x | sort))
DUPES   := $(shell printf '%s\n' $(notdir $(SCRIPTS)) | sort | uniq -d)

# $(call on_path,DIR) -> DIR if DIR is an entry in $PATH, else empty
on_path = $(filter $(1),$(subst :, ,$(PATH)))

# Prefer ~/.local/bin, then ~/bin, whichever is already on PATH.
ifndef PREFIX
  ifneq ($(call on_path,$(HOME)/.local/bin),)
    PREFIX := $(HOME)/.local
  else ifneq ($(call on_path,$(HOME)/bin),)
    PREFIX := $(HOME)
  else
    PREFIX := $(HOME)/.local
  endif
endif
BINDIR ?= $(PREFIX)/bin

.PHONY: list install uninstall check

list:
	@echo "Install to: $(DESTDIR)$(BINDIR)"
	@echo "From:       $(SRCDIRS)"
	@for f in $(SCRIPTS); do echo "  $$f"; done

check:
	@test -n "$(SCRIPTS)" || { echo "No executable scripts found in: $(SRCDIRS)" >&2; exit 1; }
	@test -z "$(DUPES)" || { echo "Same script name in more than one directory: $(DUPES)" >&2; exit 1; }

install: check
	install -d -m 0755 "$(DESTDIR)$(BINDIR)"
	install -m 0755 $(SCRIPTS) "$(DESTDIR)$(BINDIR)/"
	@case ":$$PATH:" in *":$(BINDIR):"*) ;; *) \
	  echo "NOTE: $(BINDIR) is not in your PATH. Add to your shell rc:"; \
	  echo "  export PATH=\"$(BINDIR):\$$PATH\"";; esac

uninstall: check
	rm -f $(addprefix "$(DESTDIR)$(BINDIR)"/,$(notdir $(SCRIPTS)))
