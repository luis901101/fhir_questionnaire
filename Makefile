push:
	git push -u origin --all

format:
	dart format .

fix:
	dart fix --apply

check-publish:
	dart pub publish --dry-run

publish:
	dart pub publish

.PHONY: generate-exports
generate-exports:
	@./generate-exports