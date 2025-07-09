all: arm linux
    
arm:
	bash -c "source ../pyenv/bin/activate && python3 -m pymavlink.tools.mavgen --lang=C --wire-protocol=2.0 --output=/home/hyh/workspace/transky/install/arm/include/mavlink ./message_definitions/v1.0/custom.xml"
linux:
	bash -c "source ../pyenv/bin/activate && python3 -m pymavlink.tools.mavgen --lang=C --wire-protocol=2.0 --output=/home/hyh/workspace/transky/install/linux/include/mavlink ./message_definitions/v1.0/custom.xml"
