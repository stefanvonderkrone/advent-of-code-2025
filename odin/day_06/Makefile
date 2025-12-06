
.PHONY: main
main: build-main
	@echo "Running ..."
	@echo
	@./main

.PHONY: build-main
build-main:
	@echo "Compiling ..."
	odin build . --out:main

.PHONY: watch
watch:
	@ls | entr make

