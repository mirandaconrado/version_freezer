Version freezer for apt and pip
===============================
Version freezing is a common practice to ensure we can reproduce the same system later in time. This
repo has some basic tools to help users do that when using a deb-based system (e.g. Ubuntu) and pip
for Python packages.

Based on minimal requirements files (usually the ones people care about without all dependecies,
although having dependencies there is ok) for `apt-get` and `pip` and an image to use as base, it

1) downloads and installs all deb files,
2) downloads and installs all wheel files,
3) copies all deb and wheel files outside the container,
4) creates the full versioned requirements for apt and pip, including all dependencies,
5) creates a versioned copy of the minimal files.

The versioned copies of the minimal files can be used to add new packages by just adding a new line
with the new package, potentially without specifying a version. This script relies on apt and pip to
tell us if the versions provided are incompatible.

Example versions of the minimal scripts are provided as examples.
