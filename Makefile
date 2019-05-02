UNAME := $(shell uname -s | tr A-Z a-z)
BIN_DIR = bin
DL_DIR = downloads
ARCH = amd64

PCKR_VER = 1.4.0
PCKR_ZIP_FILE := packer_$(PCKR_VER)_$(UNAME)_$(ARCH).zip
PCKR_ZIP_DL := $(DL_DIR)/$(PCKR_ZIP_FILE)
PCKR_BIN := $(BIN_DIR)/packer

# $< may not be defined because of |
$(PCKR_BIN): | $(PCKR_ZIP_DL)
	unzip -d $(BIN_DIR) $(PCKR_ZIP_DL)

$(PCKR_ZIP_DL): | $(DL_DIR)
	wget -nc https://releases.hashicorp.com/packer/$(PCKR_VER)/$(PCKR_ZIP_FILE) -O $@

$(BIN_DIR) $(DL_DIR):
	mkdir -p $@

clean:
	-rm -r $(BIN_DIR)
