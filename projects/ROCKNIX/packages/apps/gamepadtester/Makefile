# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX

CC ?= gcc
CFLAGS += -W -Wall -std=c11

BINARY = gamepad-tester
SOURCES = controller_test.c
LIBRARIES = -lSDL2 -lm -pthread

all:
	$(CC) $(CFLAGS) $(SOURCES) -o $(BINARY) $(LIBRARIES)

clean:
	rm -f $(BINARY)
