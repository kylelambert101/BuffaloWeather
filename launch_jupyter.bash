#!/bin/bash

# Launches the jupyter datascience-notebook docker container
#     * starts Docker if it is not already running
#     * maps port 8888 between local env and docker env
#     * maps the current working directory to the home directory in docker env
#     * (optional) enables Jupyter Labs in the newly running instance
#
# Usage:
#     ./launch.bash -> Launch Jupyter Notebook without enabling labs
#     ./launch.bash -l OR ./launch.bash --labs -> Launch Jupyter Notebook Labs


# If docker isn't running, start it
docker info &> /dev/null
if [[ $? -eq 1 ]]
then
    open -a Docker
    # wait for it to open before moving on
    printf "Waiting for Docker to Start\n "
    i=1
    sp="/-\|"
    docker info &> /dev/null
    until [ $? -eq 0 ]
    do
        printf "\b${sp:i++%${#sp}:1}"
        sleep 0.25
        docker info &> /dev/null
    done
    printf "\b\nDocker is now running.\n"
else 
    echo "Docker is already running."
fi

# Components of the command to run
DOCKER_RUN="docker run -it --rm"
# TODO I want an option to change the first port so I can access from my machine on something other than 8888
MAP_PORTS="-p 8888:8888"
MAP_DIRS="-v $(pwd)/:/home/jovyan"
ENABLE_LABS=""
POST_COMMAND=""
MESSAGE="\nNote: Docker is still running. You can kill it with the following command:\n\tpkill -x Docker\n"

# TODO Parse arguments - needs to be refactored to include more than just first arg. 
while [[ "$#" -gt 0 ]]; do
    case $1 in
        # -l enables jupyter labs
        -l|--labs) ENABLE_LABS="-e JUPYTER_ENABLE_LAB=yes"; shift ;;
        # -k tells the script to kill docker after the container shuts down
        -k|--kill) POST_COMMAND="pkill -x Docker"; MESSAGE="Docker has been shut down"; shift ;;
        *) echo "Argument not recognized: $1"; exit 1 ;;
    esac
    shift
done

# Assemble the command from the pieces above
COMMAND="$DOCKER_RUN $MAP_PORTS $MAP_DIRS $ENABLE_LABS jupyter/datascience-notebook"

# Show the command to the user before running
echo "Generated Command:"
echo ">> $COMMAND"

# Execute the command
$COMMAND
# Execute the post-command
$POST_COMMAND
# Display the message to the user
printf "$MESSAGE"