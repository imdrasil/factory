CRYSTAL_BIN ?= `which crystal`
.PHONY: test

test:
	$(CRYSTAL_BIN) run spec/*_spec.cr spec/factory/**/*_spec.cr -- --parallel 4
seq:
	$(CRYSTAL_BIN) run spec/*_spec.cr spec/factory/*_spec.cr spec/factory/jennifer/*_spec.cr