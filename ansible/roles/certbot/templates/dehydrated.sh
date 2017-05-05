#!/usr/bin/env bash
# Based on https://github.com/AnalogJ/lexicon/blob/master/examples/dehydrated.default.sh

set -e
set -u
set -o pipefail

export PROVIDER=digitalocean
export LEXICON_DIGITALOCEAN_TOKEN="{{ digitalocean_token }}"

function deploy_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    echo "deploy_challenge called: ${DOMAIN}, ${TOKEN_FILENAME}, ${TOKEN_VALUE}"

    case "$DOMAIN" in
    {% for domain in certbot_domains %}
    {% if domain.delegated is defined %}
"{{ domain.domain }}")
            lexicon --delegated "{{ domain.delegated }}" $PROVIDER create ${DOMAIN} TXT --name="_acme-challenge.${DOMAIN}." --content="${TOKEN_VALUE}" --ttl 60
            ;;
    {% endif %}
    {% endfor %}

        *)
            lexicon $PROVIDER create ${DOMAIN} TXT --name="_acme-challenge.${DOMAIN}." --content="${TOKEN_VALUE}" --ttl 60
            ;;
    esac

    sleep 30
}

function clean_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    echo "clean_challenge called: ${DOMAIN}, ${TOKEN_FILENAME}, ${TOKEN_VALUE}"

    case "$DOMAIN" in
    {% for domain in certbot_domains %}
    {% if domain.delegated is defined %}
"{{ domain.domain }}")
            lexicon --delegated "{{ domain.delegated }}" $PROVIDER delete ${DOMAIN} TXT --name="_acme-challenge.${DOMAIN}." --content="${TOKEN_VALUE}" --ttl 60
            ;;
    {% endif %}
    {% endfor %}

        *)
            lexicon $PROVIDER delete ${DOMAIN} TXT --name="_acme-challenge.${DOMAIN}." --content="${TOKEN_VALUE}" --ttl 60
            ;;
    esac


}

function deploy_cert {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"

    echo "deploy_cert called: ${DOMAIN}, ${KEYFILE}, ${CERTFILE}, ${FULLCHAINFILE}, ${CHAINFILE}"
}

function unchanged_cert {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"

    echo "unchanged_cert called: ${DOMAIN}, ${KEYFILE}, ${CERTFILE}, ${FULLCHAINFILE}, ${CHAINFILE}"
}

exit_hook() {
  # This hook is called at the end of a dehydrated command and can be used
  # to do some final (cleanup or other) tasks.

  :
}

HANDLER=$1; shift; $HANDLER "$@"
