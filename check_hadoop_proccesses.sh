#!/bin/bash

# Function to check master processes
check_master() {
    required=("NameNode" "ResourceManager" "SecondaryNameNode" "NodeManager")
    missing=()
    
    for process in "${required[@]}"; do
        if ! jps | grep -q "$process"; then
            missing+=("$process")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        echo "All master processes are running"
    else
        echo "Missing master processes:"
        printf '%s\n' "${missing[@]}"
    fi
}

# Function to check slave processes
check_slave() {
    required=("NodeManager" "DataNode")
    missing=()
    
    for process in "${required[@]}"; do
        if ! jps | grep -q "$process"; then
            missing+=("$process")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        echo "All slave processes are running"
    else
        echo "Missing slave processes:"
        printf '%s\n' "${missing[@]}"
    fi
}

# Main script
PS3="Is this node a master or slave? "
select node_type in Master Slave; do
    case $node_type in
        Master)
            check_master
            break
            ;;
        Slave)
            check_slave
            break
            ;;
        *)
            echo "Invalid option, please choose 1 or 2"
            ;;
    esac
done
