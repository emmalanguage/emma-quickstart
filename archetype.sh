#!/bin/bash
#
# Copyright © 2014 TU Berlin (emma@dima.tu-berlin.de)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# common options
TEMP_DIR=$(dirname $(mktemp -u))
CURR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ARCH_DIR="$CURR_DIR/target/generated-sources/archetype"
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
    cp ./.gitignore                                                                                                    \
       "$ARCH_DIR/src/main/resources/archetype-resources/"

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
