UNAME := $(shell uname -s | tr A-Z a-z)
BIN_DIR=./bin
VERSION=0.10.1
NAME=packer
ZIP_FILE=$(NAME)_$(VERSION)_$(UNAME)_amd64.zip

$(BIN_DIR):
	mkdir $@
	cd $@; wget -nc https://releases.hashicorp.com/$(NAME)/$(VERSION)/$(ZIP_FILE)
	cd $@; unzip $(ZIP_FILE)

clean:
	-rm -r $(BIN_DIR)
