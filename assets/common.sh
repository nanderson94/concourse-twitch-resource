export TMPDIR=${TMPDIR:-/tmp}

configure_credentials() {
    # Bail if configured to skip credentials
    skip_creds=$(jq -r '.source.skip_credentials // false' <<< "$1")
    if [[ "$skip_creds" == "true" ]]; then
        echo "Skipping credential setup"
        return
    fi

    # Determine our "home" for twitch-cli
    # This shouldn't need to change, but may help with troubleshooting idk
    twitch_home=$(jq -r '.source.home // empty' <<< "$1")
    if [ -z $twitch_home ]; then
        twitch_home=~/.config/twitch-cli
    fi
    mkdir -p $twitch_home

    # Extract clientid / clientsecret from params
    twitch_clientid=$(jq -r '.source.client_id // empty' <<< "$1")
    twitch_clientsecret=$(jq -r '.source.client_secret // empty' <<< "$1")

    if [ -z $twitch_clientid ] || [ -z $twitch_clientsecret ]; then
        echo "You need to specify 'source.client_id' and 'source.client_secret'."
        exit 1
    fi

    # Write basic credentials, with intentionally blank/expired token
    # TODO: Find out if this is a viable cache candidate
    cat > $twitch_home/.twitch-cli.env <<EOF
TOKENEXPIRATION=2020-01-01T00:00:00.0Z
CLIENTID=${twitch_clientid}
CLIENTSECRET=${twitch_clientsecret}
ACCESSTOKEN=
REFRESHTOKEN=
TOKENSCOPES=[]
EOF
    # Twitch outputs a token by default. Attempt to hide that information while
    # letting errors or unexpected output through.
    twitch token 2>&1 | sed 's/Token: .*/Token: [REDACTED]/'
}
