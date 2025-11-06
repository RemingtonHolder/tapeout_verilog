#!/usr/bin/bash

SDC="$PWD/src/constraints.sdc"
echo "Using SDC: $SDC"
export PNR_SDC_FILE="$SDC"
export SIGNOFF_SDC_FILE="$SDC"
# (Optional) also:
export EXTRA_SDC_FILES="$SDC"

if [ -z "$VIRTUAL_ENV" ]; then echo "VENV is not loaded. Did you remember to run: source ./env-tt09.sh"; exit 1; fi
if [ -z "$FLOW_ARG"    ]; then echo "FLOW_ARG is not specified. Did you remember to run: source ./env-tt09.sh"; exit 1; fi

echo "Regenerating user config..."
./tt/tt_tool.py --create-user-config $FLOW_ARG && (
    echo "Running local hardening..."
    ./tt/tt_tool.py --harden $FLOW_ARG
)


