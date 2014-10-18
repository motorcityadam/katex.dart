.PHONY: setup build dist serve test benchmark clean

setup:
	npm install

build:
	pub build --mode=release

dist:
	dart2js --out=./dist/katex-dart.js --package-root=./packages --minify ./lib/katex.dart

serve:
	pub serve

test:
	grunt test

benchmark:
	pub serve benchmark

clean:
	rm -rf dist/*