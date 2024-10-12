#!/bin/bash

echo "Welcome to HaulBack - Automatic Backhaul installer"

# Menu Options
echo "1- Install new backhaul"
echo "2- Manage Backhauls"
read -p "Please select an option: " option

if [ "$option" -eq 1 ]; then
    # Update and upgrade
    apt-get update -y && apt-get upgrade -y

    # Create directory for Backhaul
    dir_index=1
    while [ -d "Backhaul$dir_index" ]; do
        ((dir_index++))
    done
    mkdir "Backhaul$dir_index"
    cd "Backhaul$dir_index" || exit

    # Detect architecture
    arch=$(dpkg --print-architecture)
    if [[ "$arch" == "amd64" ]]; then
        download_url="https://github.com/Musixal/Backhaul/releases/download/v0.4.5/backhaul_linux_amd64.tar.gz"
    elif [[ "$arch" == "arm64" ]]; then
        download_url="https://github.com/Musixal/Backhaul/releases/download/v0.4.5/backhaul_linux_arm64.tar.gz"
    else
        echo "Unsupported architecture: $arch"
        exit 1
    fi

    # Download and extract
    wget "$download_url"
    tar -xzf *.tar.gz
    rm *.tar.gz

    # Server location choice
    echo "Choose your server location:"
    echo "1- IRAN"
    echo "2- KHAREJ"
    read -p "Please select an option: " server_location

    if [ "$server_location" -eq 1 ]; then
        # IRAN configuration
        echo "Choose your configuration:"
        echo "1- TCP"
        echo "2- TCP Multiplexing"
        echo "3- WebSocket"
        echo "4- WebSocket Multiplexing"
        echo "5- Secure WebSocket"
        echo "6- Secure WebSocket Multiplexing"
        read -p "Please select an option: " config_option

        # Get variables for TCP configs
        read -p "Please insert your tunnel port: " PORT_TUNNEL
        read -p "Please choose a password: " TOKEN
        read -p "Please insert a web port: " WEB_PORT
        read -p "Please insert your configs port(s) e.g. 2087,51125,1005: " PORT_CONFIG

        case "$config_option" in
            1)
                config="[server]
bind_addr = \"0.0.0.0:$PORT_TUNNEL\"
transport = \"tcp\"
token = \"$TOKEN\"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\"
ports = [
$PORT_CONFIG
]"
                ;;
            2)
                config="[server]
bind_addr = \"0.0.0.0:$PORT_TUNNEL\"
transport = \"tcpmux\"
token = \"$TOKEN\"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
mux_con = 8
mux_version = 1
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\"
ports = [
$PORT_CONFIG
]"
                ;;
            3)
                config="[server]
bind_addr = \"0.0.0.0:$PORT_TUNNEL\"
transport = \"ws\"
token = \"$TOKEN\"
channel_size = 2048
keepalive_period = 75
heartbeat = 40
nodelay = true
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\"
ports = [
$PORT_CONFIG
]"
                ;;
            4)
                config="[server]
bind_addr = \"0.0.0.0:$PORT_TUNNEL\"
transport = \"wsmux\"
token = \"$TOKEN\"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
mux_con = 8
mux_version = 1
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\"
ports = [
$PORT_CONFIG
]"
                ;;
            5)
                read -p "Please insert your domain: " DOMAIN
                read -p "Please insert your email address: " EMAIL_ADDRESS
                config="[server]
bind_addr = \"$DOMAIN:$PORT_TUNNEL\"
transport = \"wss\"
token = \"$TOKEN\"
channel_size = 2048
keepalive_period = 75
nodelay = true
tls_cert = \"/root/server.crt\"
tls_key = \"/root/server.key\"
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\"
ports = [
$PORT_CONFIG
]"
                ;;
            6)
                read -p "Please insert your domain: " DOMAIN
                read -p "Please insert your email address: " EMAIL_ADDRESS
                config="[server]
bind_addr = \"$DOMAIN:$PORT_TUNNEL\"
transport = \"wssmux\"
token = \"$TOKEN\"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
mux_con = 8
mux_version = 1
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
tls_cert = \"/root/server.crt\"
tls_key = \"/root/server.key\"
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\"
ports = [
$PORT_CONFIG
]"
                ;;
        esac

        echo "$config" > config.toml

        # SSL Certificate using ACME
        if [[ "$config_option" -eq 5 || "$config_option" -eq 6 ]]; then
            apt install curl socat -y
            curl https://get.acme.sh | sh
            ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
            ~/.acme.sh/acme.sh --register-account -m "$EMAIL_ADDRESS"
            ~/.acme.sh/acme.sh --issue -d "$DOMAIN" --standalone --key-file /root/server.key --fullchain-file /root/server.crt
        fi

    elif [ "$server_location" -eq 2 ]; then
        # KHAREJ configuration
        read -p "Please insert your IRAN server IP or Domain: " IRAN_SERVER
        echo "Choose your configuration:"
        echo "1- TCP"
        echo "2- TCP Multiplexing"
        echo "3- WebSocket"
        echo "4- WebSocket Multiplexing"
        echo "5- Secure WebSocket"
        echo "6- Secure WebSocket Multiplexing"
        read -p "Please select an option: " config_option

        # Get variables for TCP configs
        read -p "Please insert your tunnel port: " PORT_TUNNEL
        read -p "Please choose a password: " TOKEN
        read -p "Please insert a web port: " WEB_PORT
        read -p "Please insert your configs port(s) e.g. 2087,51125,1005: " PORT_CONFIG

        case "$config_option" in
            1)
                config="[client]
remote_addr = \"$IRAN_SERVER:$PORT_TUNNEL\"
transport = \"tcp\"
token = \"$TOKEN\"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
nodelay = true
retry_interval = 3
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\""
                ;;
            2)
                config="[client]
remote_addr = \"$IRAN_SERVER:$PORT_TUNNEL\"
transport = \"tcpmux\"
token = \"$TOKEN\"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
retry_interval = 3
nodelay = true
mux_version = 1
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\""
                ;;
            3)
                config="[client]
remote_addr = \"$IRAN_SERVER:$PORT_TUNNEL\"
transport = \"ws\"
token = \"$TOKEN\"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
retry_interval = 3
nodelay = true
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\""
                ;;
            4)
                config="[client]
remote_addr = \"$IRAN_SERVER:$PORT_TUNNEL\"
transport = \"wsmux\"
token = \"$TOKEN\"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
nodelay = true
mux_version = 1
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\""
                ;;
            5)
                read -p "Please insert your domain: " DOMAIN
                read -p "Please insert your email address: " EMAIL_ADDRESS
                config="[client]
remote_addr = \"$IRAN_SERVER:$PORT_TUNNEL\"
transport = \"wss\"
token = \"$TOKEN\"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
retry_interval = 3
nodelay = true
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\""
                ;;
            6)
                read -p "Please insert your domain: " DOMAIN
                read -p "Please insert your email address: " EMAIL_ADDRESS
                config="[client]
remote_addr = \"$IRAN_SERVER:$PORT_TUNNEL\"
transport = \"wssmux\"
token = \"$TOKEN\"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
retry_interval = 3
nodelay = true
sniffer = false
web_port = $WEB_PORT
sniffer_log = \"/root/backhaul.json\"
log_level = \"info\""
                ;;
        esac

        echo "$config" > config.toml

        # SSL Certificate using ACME
        if [[ "$config_option" -eq 5 || "$config_option" -eq 6 ]]; then
            apt install curl socat -y
            curl https://get.acme.sh | sh
            ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
            ~/.acme.sh/acme.sh --register-account -m "$EMAIL_ADDRESS"
            ~/.acme.sh/acme.sh --issue -d "$DOMAIN" --standalone --key-file /root/server.key --fullchain-file /root/server.crt
        fi
    fi

    # Create Service
    echo "[Unit]
Description=Backhaul Reverse Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=/root/Backhaul$dir_index/backhaul -c /root/Backhaul$dir_index/config.toml
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/backhaul.service

    # Start and enable service
    systemctl daemon-reload
    systemctl start backhaul.service
    systemctl enable backhaul.service

    echo "Backhaul service has been set up successfully!"

elif [ "$option" -eq 2 ]; then
    echo "Feature under development!"
    exit 1
fi
