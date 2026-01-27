# This Makefile assumes that wget, docker, and rsync are installed

.PHONY: test check clean setup

IMAGE=mcowan-neovim-config-tester
CONFIG_DEPS=$(shell \
	if test -e config.deps; then cat config.deps; else echo config; fi)

test: docker-build.stamp
	docker run -it $(IMAGE)

check: test

docker-build.stamp: nvim-linux-x86_64.tar.gz $(CONFIG_DEPS) \
                    Dockerfile
	docker build -t $(IMAGE) .
	touch $@

nvim-linux-x86_64.tar.gz:
	wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz || rm nvim-linux-x86_64.tar.gz

$(CONFIG_DEPS):
	rsync -aui --exclude=config-tester --exclude=lazy-lock.json ../ config/
	find config/ -type f > config.deps

clean:
	rm -f nvim-linux-x86_64.tar.gz
	rm -fr config

