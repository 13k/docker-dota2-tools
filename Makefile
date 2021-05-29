DOCKER ?= docker
IMAGE ?= dota2tools
VOLUME_STEAM ?= dota2tools-steam
VOLUME_STEAMCMD ?= dota2tools-steamcmd

.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

clean: ## Remove image (env var: IMAGE)
	$(DOCKER) image rm "$(IMAGE)"

distclean: clean ## Remove image and volumes (env vars: IMAGE, VOLUME_STEAM, VOLUME_STEAMCMD)
	$(DOCKER) volume rm "$(VOLUME_STEAM)"
	$(DOCKER) volume rm "$(VOLUME_STEAMCMD)"

image: ## Build image (env var: IMAGE)
	$(DOCKER) build -t "$(IMAGE)" .

volumes: ## Create volumes (env vars: VOLUME_STEAM, VOLUME_STEAMCMD)
	$(DOCKER) volume create "$(VOLUME_STEAM)"
	$(DOCKER) volume create "$(VOLUME_STEAMCMD)"
