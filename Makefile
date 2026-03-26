# Color definitions
COLOR_RED    = \033[0;31m
COLOR_GREEN  = \033[0;32m
COLOR_YELLOW = \033[0;33m
COLOR_RESET  = \033[0m
.PHONY: validate

ACTIVATE_PATH :=/home/hyh/workspace/transky/pyenv/bin/activate
OUTPUT_PATH := $(PWD)/validate_xml
validate: 
	mkdir -p $(OUTPUT_PATH)
	echo "rebuild mavlink for arm"
	bash -c "source $(ACTIVATE_PATH)  && python3 -m pymavlink.tools.mavgen --lang=C --wire-protocol=2.0 --output=$(OUTPUT_PATH) ./message_definitions/v1.0/custom.xml"
linux:
	mkdir -p $(OUTPUT_PATH)/linux
	echo "rebuild mavlink for x64"
	bash -c "source $(ACTIVATE_PATH) && python3 -m pymavlink.tools.mavgen --lang=C --wire-protocol=2.0 --output=$(OUTPUT_PATH)/linux ./message_definitions/v1.0/custom.xml"
