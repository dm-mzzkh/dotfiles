SHELL := /bin/bash
SUDO := $(shell command -v sudo >/dev/null 2>&1 && echo sudo)

.PHONY: install checkenv packages lf submodules shell stow verify test

install: checkenv packages lf submodules shell stow verify
	@echo "make install: OK"

checkenv:
	@bash -c 'uname -s | grep -qi linux || { echo "ERROR: Linux only"; exit 1; }; \
	command -v apt-get >/dev/null 2>&1 || { echo "ERROR: apt required"; exit 1; }; \
	command -v git >/dev/null 2>&1 || { echo "ERROR: git missing"; exit 1; }; \
	command -v curl >/dev/null 2>&1 || { echo "ERROR: curl missing"; exit 1; }'

packages:
	@bash -c 'set -e; \
	$(SUDO) apt-get update; \
	DEBIAN_FRONTEND=noninteractive $(SUDO) apt-get install -y --no-install-recommends \
	git stow curl ca-certificates file neovim tmux fzf ripgrep bat fd-find zoxide \
	imagemagick mediainfo mpv chafa make unzip xz-utils golang-go procps; \
	mkdir -p "$$HOME/.local/bin"; \
	command -v fdfind >/dev/null 2>&1 && ln -sf "$$(command -v fdfind)" "$$HOME/.local/bin/fd"; exit 0'

lf:
	@bash -c 'set -e; export PATH="$$HOME/.local/bin:$$PATH"; mkdir -p "$$HOME/.local/bin"; \
	if command -v lf >/dev/null 2>&1; then echo "lf already present"; exit 0; fi; \
	tag=$$(curl -fsSL https://api.github.com/repos/gokcehan/lf/releases/latest | grep -oE "\"tag_name\": *\"[^\"]+\"" | head -n1 | grep -oE "r[0-9]+"); \
	echo "installing lf $$tag"; \
	curl -fsSL "https://github.com/gokcehan/lf/releases/download/$$tag/lf-linux-amd64.tar.gz" | tar -xz -C "$$HOME/.local/bin" \
	|| { echo "release download failed; building from source"; go install github.com/gokcehan/lf@latest; cp -f "$$HOME/go/bin/lf" "$$HOME/.local/bin/"; }; \
	lf --version'

submodules:
	@bash -c 'git submodule update --init --recursive'

shell:
	@SHELL_CHOICE='$(SHELL_CHOICE)' bash -c 'cd "$(CURDIR)"; \
	if [ -n "$$SHELL_CHOICE" ]; then choice="$$SHELL_CHOICE"; else \
	choice=bash; command -v kosh >/dev/null 2>&1 && choice=kosh; \
	printf "shell for lf scripts [bash/kosh] (default: %s): " "$$choice"; \
	read -r pick || pick=""; choice=$${pick:-$$choice}; fi; \
	echo "using shell: $$choice"; \
	sb="#!/usr/bin/env bash"; opts=""; \
	[ "$$choice" = kosh ] && { sb="#!/usr/bin/env -S kosh --mood=bash"; opts="--mood=bash"; } || true; \
	for f in .config/lf/*.sh .config/lf/tests/*.sh; do sed -i "1s|^#!.*|$$sb|" "$$f"; done; \
	sed -i "s|^set shell .*|set shell $$choice|" .config/lf/lfrc; \
	sed -i "s|^set shellopts .*|set shellopts $$opts|" .config/lf/lfrc; \
	head -n 2 .config/lf/lfrc'

stow:
	@bash -c 'set -e; cd "$(CURDIR)" && stow .; \
	ls -l "$$HOME/.bashrc" "$$HOME/.config/lf/lfrc"'

verify:
	@bash -c 'set -e; export PATH="$$HOME/.local/bin:$$PATH"; cd "$(CURDIR)"; \
	for b in nvim stow tmux fzf rg bat fd lf zoxide file; do \
	command -v $$b >/dev/null 2>&1 || { echo "MISSING binary: $$b"; exit 1; }; done; \
	command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1 || { echo "MISSING: imagemagick"; exit 1; }; \
	echo OK: binaries; \
	lf --version >/dev/null; \
	for f in .config/lf/*.sh .config/lf/tests/*.sh; do bash -n "$$f" || { echo "SYNTAX FAIL: $$f"; exit 1; }; done; \
	echo OK: script syntax; \
	printf "hello dotfiles\n" > /tmp/lf-preview-test.txt; \
	out="$$( .config/lf/scope.sh /tmp/lf-preview-test.txt 80 25 2>&1 )"; \
	[ -n "$$out" ] || { echo "scope.sh produced no output"; exit 1; }; \
	rm -f /tmp/lf-preview-test.txt; \
	echo OK: preview; \
	nvim --headless "+qa" >/dev/null 2>&1 || { echo "nvim --headless failed"; exit 1; }; \
	echo OK: nvim headless; \
	for u in pbcopy qlmanage osascript kitten trash open; do \
	command -v $$u >/dev/null 2>&1 || echo "note: $$u unavailable (macOS-only, scripts degrade gracefully)"; done'

test:
	@docker run --rm -it -v "$(CURDIR):/dotfiles" -w /dotfiles debian:13 bash -c "DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends curl git make ca-certificates && git config --global --add safe.directory /dotfiles && make SHELL_CHOICE=bash install"
