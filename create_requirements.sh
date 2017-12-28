#!/bin/sh

#set -e

IMAGE=$1
if [ -z $IMAGE ]
then
    echo "Must provide an image to use as base"
    echo "Usage: $0 <image> [apt-file] [pip-file] [output-dir]"
    exit
fi

APT_FILE=$(realpath "${2:-requirements-apt-minimal.txt}")
PIP_FILE=$(realpath "${3:-requirements-pip-minimal.txt}")
SCRIPT_FILE=$(realpath "$0")
OUTPUT_DIR=$(realpath "${4:-./output}")
mkdir -p "$OUTPUT_DIR"

APT_VOLUME=$(dirname "$APT_FILE"):/apt_volume
PIP_VOLUME=$(dirname "$PIP_FILE"):/pip_volume
SHELL_VOLUME=$(dirname "$SCRIPT_FILE"):/shell_volume
OUTPUT_VOLUME="$OUTPUT_DIR":/output_volume

APT_ARG=/apt_volume/$(basename "$APT_FILE")
PIP_ARG=/pip_volume/$(basename "$PIP_FILE")

docker run -it -v "$APT_VOLUME" -v "$PIP_VOLUME" -v "$SHELL_VOLUME" -v "$OUTPUT_VOLUME" $IMAGE /bin/sh -c "/shell_volume/create_requirements_internal.sh \"$APT_ARG\" \"$PIP_ARG\" $(id -u)"

cd "$OUTPUT_DIR"

echo '# This file was auto-generated. Do not modify it directly' > requirements-apt.txt
echo '# This file was auto-generated. Do not modify it directly' > requirements-pip.txt

diff --unchanged-line-format= --old-line-format= --new-line-format='%L' initial_packages.txt final_packages.txt >> requirements-apt.txt
diff --unchanged-line-format= --old-line-format= --new-line-format='%L' initial_modules.txt final_modules.txt >> requirements-pip.txt

# Fix the original apt file to set versions
rm -f requirements-apt-minimal.txt
for package in $(cat "$APT_FILE" | cut -f 1 -d':' | cut -f 1 -d'=')
do
    fixed_version=$(grep -i "^$package[=:]" final_packages.txt)
    if [ ! $fixed_version ]
    then
        echo "Failed to find a versioned line with package $package"
        exit 1
    fi
    echo $fixed_version >> requirements-apt-minimal.txt
done

# Fix the original pip file to set versions
rm -f requirements-pip-minimal.txt
for package in $(cat "$PIP_FILE" | cut -f 1 -d'=')
do
    fixed_version=$(grep -i "^$package==" final_modules.txt)
    if [ ! $fixed_version ]
    then
        echo "Failed to find a versioned line with package $package"
        exit 1
    fi
    echo $fixed_version >> requirements-pip-minimal.txt
done

rm initial_modules.txt initial_packages.txt final_modules.txt final_packages.txt
