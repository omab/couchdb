clean:
	@ rm couchdb*.gem

build: clean
	@ gem build couchdb.gemspec

publish: build
	@ gem push couchdb-*.gem

.PHONY: clean build publish
