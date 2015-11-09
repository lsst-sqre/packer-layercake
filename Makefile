BIN_DIR=./bin

$(BIN_DIR):
	mkdir $@
	cd $@; wget -nc https://releases.hashicorp.com/packer/0.8.6/packer_0.8.6_linux_amd64.zip
	cd $@; unzip packer_0.8.6_linux_amd64.zip
