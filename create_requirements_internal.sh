#!/bin/sh

set -e

OUTPUT_DIR=/output_volume

dpkg-query -f '${binary:Package}=${source:Version}\n' -W > "$OUTPUT_DIR"/initial_packages.txt
apt-get update
apt-get clean
xargs apt-get install -y --no-install-recommends --download-only < "$1"
mkdir -p "$OUTPUT_DIR"/debs
cp /var/cache/apt/archives/*.deb "$OUTPUT_DIR"/debs
xargs apt-get install -y --no-install-recommends < "$1"
dpkg-query -f '${binary:Package}=${source:Version}\n' -W > "$OUTPUT_DIR"/final_packages.txt

pip install --upgrade pip
pip freeze > "$OUTPUT_DIR"/initial_modules.txt

pip install wheel
pip wheel --no-cache-dir --wheel-dir="$OUTPUT_DIR"/wheels -r "$2"
pip install "$OUTPUT_DIR"/wheels/*.whl
pip freeze > "$OUTPUT_DIR"/final_modules.txt

chown -R $3 "$OUTPUT_DIR"
