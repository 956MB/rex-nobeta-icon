PREFIX ?= /usr/local
BIN = rex-nobeta-icon

.PHONY: build install uninstall clean

build: $(BIN)

$(BIN): Sources/main.swift
	swiftc -O $< -o $@

install: $(BIN)
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 $(BIN) $(DESTDIR)$(PREFIX)/bin/$(BIN)

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(BIN)

clean:
	rm -f $(BIN)
