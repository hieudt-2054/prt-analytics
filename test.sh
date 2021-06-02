set -e
GREEN='\033[0;32m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
BLACK='\033[0;30m'
RED='\033[33;31m'

############# Changes Log
phpSupportType="html,"
rubySupportType="json,"
#############

dataCloc=""
ciBranch=""
ciEvent=""
ciProvider=""

if [ $CI_BRANCH ]; then
    ciBranch=${CI_BRANCH}
    ciProvider="SunCI"
fi

if [ $CI_WEBHOOK_EVENT ]; then
    ciEvent=${CI_WEBHOOK_EVENT}
fi

if [ $CIRCLECI ]; then
    ciBranch=${CIRCLE_BRANCH}
    ciEvent=${CIRCLE_PULL_REQUEST}
    ciProvider="CircleCI"
fi

clocRunning() {
    echo -e "${YELLOW}> PRT Cloc running... ${GREEN}"
    echo "PATH CLOC : ${PATH_CLOC}"
    if [[ "$PATH_CLOC" == "all" ]]; then
        dataCloc=$(cloc $(git ls-files) --exclude-ext=phar,json --json)
    else
        dataCloc=$(cloc $PATH_CLOC --exclude-ext=phar,json --json)
    fi
    echo -e ${WHITE}
}


function executor() {
    # Args: 
    # $1 is Language
    # $2 is Format Type
    clocRunning
    value=0
    echo "PATH COVERAGE : ${PATH_COVERAGE}"

    case $1 in
        "php")
            case $2 in
                "html")
                    value=$(echo "$(cat $PATH_COVERAGE/index.html)" | grep -Pzo '>Total</td>(.*\n.*){3}' | grep -Pzo '[0-9]{1,3}\.[0-9]{1,2}\% covered' | grep -Pzo '[0-9]{1,3}\.[0-9]{1,2}')
                    ;;
                *)
                    echo -e "${RED}Type invalid, PHP supported format: ${phpSupportType}"
                    exit
            esac
            ;;
        "ruby")
            case $2 in
                "json")
                    value="$(cat $PATH_COVERAGE/.last_run.json | grep -oP '"covered_percent":\K[0-9, .]+')"
                    ;;
                *)
                    echo -e "${RED}Type invalid, Ruby supported format: ${rubySupportType}"
                    exit
            esac
            ;;
    esac

    echo -e "${YELLOW}> PRT Coverage ($0 - $1) running... ${GREEN}"
    echo -e "Branch: ${ciBranch}"
    echo -e "Token: ${TOKEN}"
    echo -e "Endpoint: ${ENDPOINT}"
    echo -e "Value: ${value}"
    echo -e "Cloc: ${dataCloc}"
    echo -e "CI Event: ${ciEvent}"
    echo -e "CI Provider: ${ciProvider}"
    curl -d "ci_provider=${ciProvider}&ci_event=${ciEvent}&code=${TOKEN}&value=$(echo ${value/./%2E})&branch=$(echo $ciBranch)&cloc=${dataCloc}" -X POST ${ENDPOINT} --trace-ascii /dev/stdout
}


case $1 in
    "cloc")
        clocRunning
        ;;
    "php-html")
        executor 'php' 'html'
        ;;
    "ruby-json")
        executor 'ruby' 'json'
        ;;
    *)
        echo -e "${RED}Not found command"
        echo -e "${GREEN}Please follow guideline"
        echo -e ${WHITE}
        echo -e "Usage:"
        echo "prt <language: php|ruby>-<format: html|xml|json>"
        echo "Example: prt php-html "
        exit
esac



