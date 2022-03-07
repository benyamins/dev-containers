#!/usr/bin/env bash

c_red=$(tput setaf 1)
c_green=$(tput setaf 2)
c_reset=$(tput sgr0)

help()
{
    echo "${c_green}Manages (Podman) Containers (MC)${c_reset}"
    echo ''
    echo '  mc (build | clean | run | manage | enter | list | help | <aliases>) [ARGS]'
    echo
    echo "${c_green}Examples:${c_reset}"
    echo '  mc manage start arch      # start arch container'
    echo '  mc m p arch               # pause arch container'
    echo
    echo "${c_green}Commands:${c_reset}"
    echo '  build |b: build the pod'
    echo '      mc b list             # List images'
    echo '      mc b <image>          # Build an image'
    echo '  clean |c: clean the pod'
    echo '  run   |r: run dev pod     # Runs an installed image for development'
    echo '      mc r <pod-name> <pod-hostname> <pod-tz> <pod-image>'
    echo '  manage|m: manage the pod'
    echo '      mc m s <container>    # starts the continer'
    echo '      mc m p <container>    # pauses the continer'
    echo '  list  |l: list all containers'
    echo '      mc l                  # list active containers'
    echo '      mc l a                # list "--all" containers'
    echo '  enter |e: enter the pod'
    echo '  help  |h: see help'
    echo
    echo "${c_green}Aliases:${c_reset}"
    echo '  mse : manage start and enter the pod'
    echo '      mc mse arch           # start the arch pod and enter it'
    echo
}


exit_error()
{
    message="$1"
    echo "${c_red}${message}${c_reset}"
    help
    exit 1
}


build()
{
    if [ "$1" = 'list' ]
    then
        echo Listing the pods    
        podman image list
        exit
    fi
    echo 'building the pod'
	podman build . -t "$1"
    exit
}

clean()
{
    echo "cleaing all the pods"
	podman rm -f "$(podman ps -a -q)"
    exit
}


run()
{
    pod="$1"           # eg. arch
    pod_hostname="$2"  # eg. podman-arch
    pod_tz="$3"        # eg. America/Santiago
    pod_image="$4"     # eg. arch-dev
    echo "Running \`${pod}\` the pod"
	podman run --userns=keep-id \
		--name "$pod" \
		--network=host \
		--hostname="$pod_hostname" \
		-e TZ="$pod_tz" \
		-v "$HOME/dev:$HOME/dev" \
		-v "$HOME/.config:$HOME/.config" \
		-v "$HOME/.local/share/nvim:$HOME/.local/share/nvim" \
		-t -d "$pod_image"
    exit
}


manage()
{
    action="$1"
    container="$2"

    if [[ -z "$action" || -z "$container" ]]
    then
        exit_error "No action or container where passed. TRY AGAIN"
    fi

    case "$action" in
        s|start) podman start "$container"
            ;;
        p|pause) podman stop "$container"
            ;;
        *) exit_error "Invalid manage option. TRY AGAIN"
            ;;
    esac
}


list()
{
    all_containers="$1"
    
    if [[ -z "$all_containers" ]]
    then
        podman ps       
    elif [[ "$all_containers" != "a" ]]
    then
        exit_error "Invalid --all option. use \`l\` with \`a\` for all pods"
    else
        podman ps --all        
    fi
}


enter()
{
    echo "${c_green}entering the \`$1\` pod${c_reset}"
	podman exec -it "$1" bash
}


alias_start_enter()
{
    container="$1"
    
    manage "start" "$container"
    enter "$container"
}


main()
{
    case "$1" in
        build|b) build "$2"
            ;;
        clean|c) clean "$2"
            ;;
        run|r) run "$2"
            ;;
        manage|m) manage "$2" "$3"
            ;;
        enter|e) enter "$2"
            ;;
        list|l) list "$2"
            ;;
        mse) alias_start_enter "$2"
            ;;
        help|--help|-h|h) help && exit
            ;;
        *) echo -e "${c_red}No valid command. See:\n${c_reset}"
            help
            exit 1
            ;;
    esac
}

main "$@"
