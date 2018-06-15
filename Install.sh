#!/usr/bin/env bash

BITBAR_DIR=$HOME/.bitbar/
PLUGINS_DIR=$BITBAR_DIR/plugins/
BIN_DIR=$BITBAR_DIR/bin/
APPDATA_DIR=$BITBAR_DIR/appdata/

[ -d $PLUGINS_DIR ] || mkdir -p $PLUGINS_DIR
[ -d $BIN_DIR ] || mkdir -p $BIN_DIR
[ -d $APPDATA_DIR ] || mkdir -p $APPDATA_DIR

cp -r $(pwd)/plugins/* $PLUGINS_DIR
cp -r $(pwd)/bin/* $BIN_DIR
cp -r $(pwd)/appdata/* $APPDATA_DIR
