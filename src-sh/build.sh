#!/usr/bin/env bash

cd $(dirname $0)/..
PROJECT_PATH=$(pwd)

search_sources() {
    local SEARCH_PATH=$1

    ((LEN_WITHOUT_PATH_PREFIX=${#SEARCH_PATH}+2))

    local RAW_FILE_NAMES=$(find "$SEARCH_PATH" -type f | grep ".for$" | cut -c "$LEN_WITHOUT_PATH_PREFIX-")
    for RAW_FILE_NAME in $RAW_FILE_NAMES;
    do
        ((NAME_LENGTH_WITHOUT_SUFFIX=${#RAW_FILE_NAME}-4))
        echo "$RAW_FILE_NAME" | cut -c -$NAME_LENGTH_WITHOUT_SUFFIX
    done
}

build_library() {
    local FILE_LIST=$(search_sources "$PROJECT_PATH/src-f90")

    mkdir -p "$PROJECT_PATH/.build/module-files"
    # rm -r "$PROJECT_PATH/.build/module-files/"
    
    mkdir -p "$PROJECT_PATH/.build/objects"
    rm -f "$PROJECT_PATH/.build/objects/"*.o

    cd "$PROJECT_PATH/.build/module-files/$SOURCE_SUBFOLDER"
    for FILE_ENTRY in $FILE_LIST;
    do
        echo "> $FILE_ENTRY"

        local OBJECT_NAME=$(echo $FILE_ENTRY | tr "-" "_" | tr "/" "-")

        gfortran --std=legacy -O2 -g2 -c \
            -o "$PROJECT_PATH/.build/objects/$OBJECT_NAME.o" \
            "$PROJECT_PATH/src-f90/$FILE_ENTRY.for"
    done

    rm -f "$PROJECT_PATH/.build/objects/json-f90.a"
    ar -rvs "$PROJECT_PATH/.build/json-f90.a" \
        "$PROJECT_PATH/.build/objects/"*.o
}

build_library_n_times() {
    local NUM_SOURCES=$(search_sources "$PROJECT_PATH/src-f90" | wc -l)
    ((NUM_SOURCES--))

    local BUILD_INDEX=0
    while [[ $BUILD_INDEX -lt $NUM_SOURCES ]];
    do
        build_library >>/dev/null 2>>/dev/null
        ((BUILD_INDEX++))
    done

    build_library
}

build_library_n_times "$@"

