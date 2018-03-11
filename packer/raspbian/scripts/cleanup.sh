#!/bin/bash

# Clean up
apt-get autoclean
apt-get clean

# Removing apt caches
rm -rf /var/cache/apt/*
