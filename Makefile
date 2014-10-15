clean:
	@ rm throw*.gem

build: clean
	@ gem build throw.gemspec

publish: build
	@ gem push throw-*.gem

.PHONY: clean build publish
