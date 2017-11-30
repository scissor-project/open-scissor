# Source: http://stackoverflow.com/questions/9870297/makefile-to-compile-opencv-code-in-c-on-ubuntu-linux
# usage: make filename

LIBS = -lzmq

MACHINE := $(shell uname -m)
ifeq ($(MACHINE), armv6l)
USERCFLAGS = -O2 -pipe -mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard
endif

% : %.cpp
	g++ $(USERCFLAGS) $< -o $@ $(LIBS)
