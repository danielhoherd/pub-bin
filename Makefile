.DEFAULT_GOAL := help

.PHONY: help
help: ## Print Makefile help.
	@grep -Eh '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[1;36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: install-hooks
install-hooks: ## Install git hooks.
	pre-commit install -f --install-hooks

.PHONY: update-requirements
update-requirements: ## Update all requirements.txt files
	uv pip compile --quiet --upgrade requirements.in -o requirements.txt
	-pre-commit run requirements-txt-fixer --all-files --show-diff-on-failure
