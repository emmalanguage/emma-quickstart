#!/bin/bash

# common options
TEMP_DIR=$(dirname $(mktemp -u))
CURR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ARCH_DIR="$CURR_DIR/target/generated-sources/archetype"
ARCH_RSR="$ARCH_DIR/src/main/resources/archetype-resources"
ARCH_POM="$ARCH_DIR/pom.xml"
ARCH_MDT="$ARCH_DIR/src/main/resources/META-INF/maven/archetype-metadata.xml"

# create archetype from a specific branch
function create_archetype {
    ARCHID=$1
    TARGET=$2
    # 1) create the archetype
    echo "CLEANING MAVEN PROJECT."
    mvn clean
    echo "GENERATING ARCHETYPE FROM CURRENT BRANCH"
    mvn archetype:create-from-project                                                                                  \
        -Darchetype.properties=./archetype.properties                                                                  \
        -Darchetype.artifactId="$ARCHID"

    # 2) fix the archetype file structure
    echo "FIXING FILES IN GENERATED ARCHETYPE"
    # copy explicitly the .gitignore file
    cp ./.gitignore "$ARCH_RSR"
    # insert placeholder for root package in pom.xml files
    for pom in $(find "$ARCH_RSR" -name 'pom.xml'); do
        sed -i s/org.example/\${package}/g "$pom"
    done

    # 5) install the archetype
    echo "COPYING ARCHETYPE TO ROOT PACKAGE"
    rm -R "$TARGET/$ARCHID/src"
    cp -R "$ARCH_DIR/src" "$TARGET/$ARCHID/."
}

# validate input arguments
if [[ "$#" -ne 1 ]];
    then echo "usage: ./archetype.sh <path_to_emma_src>"
    exit -1
fi

CUR_BRANCH=$(git rev-parse --abbrev-ref HEAD)

TARGET="$1"
create_archetype "emma-quickstart" "$TARGET"
