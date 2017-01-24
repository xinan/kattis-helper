#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
SUBMIT="${DIR}/kattis-cli/submit.py"

TASK="$1"
shift

while [[ $# -gt 0 ]]; do
    OPT="$1"
    case $OPT in
        -P|--problem)
            PROBLEM="$2"
            shift
            ;;
        -F|--file)
            FILE="$2"
            shift
            ;;
        -M|--mainclass)
            MAINCLASS="$2"
            shift
            ;;
        -L|--language)
            LANGUAGE="$2"
            shift
            ;;
        -F|--force)
            FORCE="true"
            ;;
        *)
            REST="$1"
            ;;
    esac
    shift
done

case $TASK in
    init)
        if [ -z ${PROBLEM+x} ]; then
            if [ -z ${REST+x} ]; then
                echo "Problem ID  must be specified."
                exit 1
            fi
            PROBLEM=$REST
        fi
        {
            /bin/mkdir $PROBLEM
            cd $PROBLEM
            SAMPLE_URL="https://open.kattis.com/problems/${PROBLEM}/file/statement/samples.zip"
            wget $SAMPLE_URL || curl -O $SAMPLE_URL
            /usr/bin/unzip -o samples.zip
            /bin/rm samples.zip
        } &> /dev/null
        echo "Problem initialized in \"./${PROBLEM}\". Good luck!"
        ;;
    submit)
        if [ -z ${FILE+x} ]; then
            if [ -z ${REST+x} ]; then
                echo "File name must be specified."
                exit 2
            fi
            FILE=$REST
        fi

        CMD="/usr/bin/env python ${SUBMIT} ${FILE}"
        if [ ! -z ${PROBLEM+x} ]; then
            CMD="$CMD -p $PROBLEM"
        fi
        if [ ! -z ${MAINCLASS+x} ]; then
            CMD="$CMD -m $MAINCLASS"
        fi
        if [ ! -z ${LANGUAGE+x} ]; then
            CMD="$CMD -l $LANGUAGE"
        fi
        if [ ! -z ${FORCE+x} ]; then
            CMD="$CMD -f"
        fi
        eval $CMD
        ;;
    *)
        echo -e "Usage:\n\t$0 init <problem>\n\t$0 submit <file>"
        ;;
esac
