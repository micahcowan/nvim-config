# This Makefile assumes that wget, docker, and rsync are installed
# GNU cp may also be required (for -al)

.PHONY: test check clean setup retest recheck

IMG_FULL=mcowan-neovim-config-tester
IMG_BARE=mcowan-neovim-config-bare-install

CONFIG_DEPS=Makefile $(shell \
	if test -e config.deps; then cat config.deps; else echo config; fi)

test check: test-run.stamp

test-run.stamp retest recheck: docker-build.stamp Makefile
	docker run -it $(IMG_BARE)
	docker run -it $(IMG_FULL)
	touch test-run.stamp

docker-build.stamp: nvim-linux-x86_64.tar.gz config \
                    Dockerfile bashrc Makefile
	docker build $(DOCKER_BUILD) --build-arg msg=full -t $(IMG_FULL) .
	docker build $(DOCKER_BUILD) \
		--build-arg msg=bare \
		--build-arg packages= \
		--build-arg local_file=blank \
		-t $(IMG_BARE) .
	touch $@

nvim-linux-x86_64.tar.gz:
	wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz || rm nvim-linux-x86_64.tar.gz

config: $(CONFIG_DEPS)
	rm -fr config/ config.deps
	mkdir config
	for file in ../*; do \
		case "$${file##*/}" in \
			config-tester|lazy-lock.json) \
				;; \
			*) \
				printf '%s\n' "$$file" >> config.deps; \
				cp -al "$$file" ./config/; \
				;; \
		esac; \
	done
	rm -f config/lua/config/local.lua
				

clean:
	rm -f nvim-linux-x86_64.tar.gz config.deps *.stamp
	rm -fr config

