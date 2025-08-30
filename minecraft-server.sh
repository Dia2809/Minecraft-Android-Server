#!/bin/bash

# ive used https://github.com/drmatoi/minecraft.git as a base for this script
# but its heavily modified and basically a rewrite at this point

# Colors for beauty
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

SCRIPT_DIR="$HOME/minecraft-server"
SERVER_DIR="$SCRIPT_DIR/server"
JAVA_DIR="$SCRIPT_DIR/java"
LOGS_DIR="$SCRIPT_DIR/logs"

declare -A MC_VERSIONS=(
    ["1.7.10"]="https://launcher.mojang.com/v1/objects/952438ac4e01b4d115c5fc38f891710c4941df29/server.jar"
    ["1.12.2"]="https://piston-data.mojang.com/v1/objects/886945bfb2b978778c3a0288fd7fab09d315b25f/server.jar"
    ["1.16.5"]="https://piston-data.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar"
)

show_header() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${WHITE}               Minecraft Server Manager                 ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}


install_dependencies() {
    echo -e "${YELLOW}Installing required packages...${NC}"
    pkg update -y
    local packages=("openjdk-17" "wget" "curl" "procps" "tmux" "htop")

    for package in "${packages[@]}"; do
        echo -e "${CYAN}Installing $package...${NC}"
        pkg install -y "$package" || {
            echo -e "${RED}Failed to install $package${NC}"
            return 1
        }
    done

    echo -e "${GREEN}All dependencies installed successfully!${NC}"
    sleep 2
}


download_server() {
    local version="$1"
    local url="${MC_VERSIONS[$version]}"
    
    if [[ -z "$url" ]]; then
        echo -e "${RED}Invalid version selected!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Downloading Minecraft Server $version...${NC}"
    
    cd "$SERVER_DIR" || return 1
    
    # Check if this is an upgrade/reinstall
    local is_upgrade=false
    if [[ -f "server.jar" ]]; then
        echo -e "${CYAN}Existing server found. This will upgrade/reinstall the server.${NC}"
        echo -e "${YELLOW}Your world data and configurations will be preserved.${NC}"
        is_upgrade=true
        
        # Backup current server.jar
        [[ -f "server.jar" ]] && mv "server.jar" "server.jar.backup"
    fi
    
    # Download the server
    echo -e "${CYAN}Downloading server.jar...${NC}"
    wget -O "server.jar" "$url" || {
        echo -e "${RED}Failed to download server!${NC}"
        # Restore backup if download failed
        [[ -f "server.jar.backup" ]] && mv "server.jar.backup" "server.jar"
        return 1
    }
    
    # Remove backup if download was successful
    [[ -f "server.jar.backup" ]] && rm "server.jar.backup"
    
    # Handle EULA
    if [[ ! -f "eula.txt" ]] || ! grep -q "eula=true" "eula.txt" 2>/dev/null; then
        echo -e "${CYAN}Accepting EULA...${NC}"
        echo "eula=true" > eula.txt
    fi
    
    # Handle server.properties
    if [[ -f "server.properties" ]]; then
        echo -e "${CYAN}Existing server.properties found. Updating with sed...${NC}"
        
        # Function to update or add a property using sed
        update_property() {
            local key="$1"
            local value="$2"
            local file="server.properties"
            
            # Check if property exists (ignoring comments)
            if grep -q "^[[:space:]]*${key}[[:space:]]*=" "$file" 2>/dev/null; then
                # Property exists, update it
                sed -i "s/^[[:space:]]*${key}[[:space:]]*=.*/${key}=${value}/" "$file"
            else
                # Property doesn't exist, add it
                echo "${key}=${value}" >> "$file"
            fi
        }
        
        # Update essential properties
        update_property "server-port" "25565"
        update_property "online-mode" "false"
        update_property "enable-command-block" "false"
        
        # Update default values only if they don't exist
        if ! grep -q "^[[:space:]]*gamemode[[:space:]]*=" "server.properties" 2>/dev/null; then
            update_property "gamemode" "survival"
        fi
        
        if ! grep -q "^[[:space:]]*difficulty[[:space:]]*=" "server.properties" 2>/dev/null; then
            update_property "difficulty" "easy"
        fi
        
        if ! grep -q "^[[:space:]]*max-players[[:space:]]*=" "server.properties" 2>/dev/null; then
            update_property "max-players" "10"
        fi
        
        if ! grep -q "^[[:space:]]*spawn-protection[[:space:]]*=" "server.properties" 2>/dev/null; then
            update_property "spawn-protection" "16"
        fi
        
        if ! grep -q "^[[:space:]]*motd[[:space:]]*=" "server.properties" 2>/dev/null; then
            update_property "motd" "Termux Minecraft Server"
        fi
        
        echo -e "${GREEN}Server.properties updated successfully!${NC}"
        
    else
        echo -e "${CYAN}Creating new server.properties...${NC}"
        # Create server.properties with basic settings
        cat > server.properties << EOF
#Minecraft server properties
#$(date)
server-port=25565
gamemode=survival
difficulty=easy
spawn-protection=16
max-players=10
online-mode=false
enable-command-block=false
motd=Termux Minecraft Server
view-distance=8
simulation-distance=6
max-world-size=29999984
allow-nether=true
allow-flight=false
hardcore=false
white-list=false
broadcast-console-to-ops=true
pvp=true
generate-structures=true
op-permission-level=4
allow-nether=true
level-name=world
player-idle-timeout=0
max-build-height=256
server-ip=
level-seed=
rcon.port=25575
level-type=default
force-gamemode=false
max-tick-time=60000
rate-limit=0
network-compression-threshold=256
max-players=10
use-native-transport=true
enable-status=true
broadcast-rcon-to-ops=true
sync-chunk-writes=true
enable-jmx-monitoring=false
level-seed=
enable-rcon=false
EOF
    fi
    
    # Show what was done
    if [[ "$is_upgrade" == "true" ]]; then
        echo -e "${GREEN}Server upgraded to version $version successfully!${NC}"
        echo -e "${BLUE}Your world data and custom configurations have been preserved.${NC}"
    else
        echo -e "${GREEN}Server $version downloaded and configured successfully!${NC}"
    fi
    
    sleep 2
}

# I HATE TMUX, thanks Claude
start_server_with_monitoring() {
    local ram_mb="$1"
    
    # Create a tmux session for the server
    tmux new-session -d -s "mc-server" -c "$SERVER_DIR"
    
    echo -e "${GREEN}Starting Minecraft Server...${NC}"
    echo -e "${YELLOW}Server output will appear on the left. htop monitoring is shown on the right.${NC}"
    echo -e "${BLUE}Press 'q' in htop to close it, or Ctrl+C to stop the server.${NC}"
    echo
    
    # Start the server in tmux and attach to it
    tmux send-keys -t "mc-server" "cd '$SERVER_DIR' && java -Xmx${ram_mb}M -Xms${ram_mb}M -jar server.jar" Enter
    
    # Split tmux window to show htop on the right
    tmux split-window -t "mc-server" -h -p 30
    tmux send-keys -t "mc-server:0.1" "htop" Enter
    
    # Attach to the tmux session
    tmux attach-session -t "mc-server"
}

# Function to configure server settings
configure_server() {
    if [[ ! -f "$SERVER_DIR/server.properties" ]]; then
        echo -e "${RED}No server.properties found! Please start the once server first.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi

    show_header
    echo -e "${CYAN}Current Server Configuration:${NC}"
    echo
    cat "$SERVER_DIR/server.properties" | grep -E "(server-port|max-players|gamemode|difficulty|motd)" | while read line; do
        echo -e "${YELLOW}$line${NC}"
    done
    echo

    echo -e "${BLUE}What would you like to configure?${NC}"
    echo "1. Server Port"
    echo "2. Max Players"
    echo "3. Game Mode"
    echo "4. Difficulty"
    echo "5. Server MOTD"
    echo "6. Back to main menu"
    echo

    read -p "Enter your choice (1-6): " config_choice

    case $config_choice in
        1)
            read -p "Enter new server port (default 25565): " new_port
            sed -i "s/server-port=.*/server-port=${new_port:-25565}/" "$SERVER_DIR/server.properties"
            echo -e "${GREEN}Server port updated!${NC}"
            ;;
        2)
            read -p "Enter max players (default 10): " new_max
            sed -i "s/max-players=.*/max-players=${new_max:-10}/" "$SERVER_DIR/server.properties"
            echo -e "${GREEN}Max players updated!${NC}"
            ;;
        3)
            echo "Game modes: survival, creative, adventure, spectator"
            read -p "Enter game mode: " new_gamemode
            sed -i "s/gamemode=.*/gamemode=${new_gamemode:-survival}/" "$SERVER_DIR/server.properties"
            echo -e "${GREEN}Game mode updated!${NC}"
            ;;
        4)
            echo "Difficulties: peaceful, easy, normal, hard"
            read -p "Enter difficulty: " new_diff
            sed -i "s/difficulty=.*/difficulty=${new_diff:-easy}/" "$SERVER_DIR/server.properties"
            echo -e "${GREEN}Difficulty updated!${NC}"
            ;;
        5)
            read -p "Enter server MOTD: " new_motd
            sed -i "s/motd=.*/motd=${new_motd:-Termux Minecraft Server}/" "$SERVER_DIR/server.properties"
            echo -e "${GREEN}MOTD updated!${NC}"
            ;;
        6)
            return 0
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            ;;
    esac

    if [[ $config_choice != 6 ]]; then
        sleep 2
        configure_server
    fi
}

# Function to show server management options
manage_server() {
    if [[ ! -f "$SERVER_DIR/server.jar" ]]; then
        echo -e "${RED}No server found! Please install a server first.${NC}"
        read -p "Press Enter to continue..."
        return 1
    fi

    show_header
    echo -e "${BLUE}Server Management${NC}"
    echo
    echo "1. Start Server"
    echo "2. Configure Server"
    echo "3. View Server Files"
    echo "4. Delete Server"
    echo "5. Back to main menu"
    echo

    read -p "Enter your choice (1-5): " mgmt_choice

    case $mgmt_choice in
        1)
            # Ask for RAM allocation
            show_header
            echo -e "${YELLOW}RAM Allocation for Server${NC}"
            echo
            echo -e "${CYAN}Available RAM:${NC}"
            free -h | grep "Mem:" | awk '{print "Total: " $2 ", Available: " $7}'
            echo
            echo -e "${BLUE}Recommended allocations:${NC}"
            echo "• 512MB  - Minimal (1-2 players)"
            echo "• 1024MB - Small (3-5 players)"
            echo "• 2048MB - Medium (6-10 players)"
            echo "• 4096MB - Large (10+ players)"
            echo

            read -p "Enter RAM allocation in MB (default 1024): " ram_allocation
            ram_allocation=${ram_allocation:-1024}

            # Validtion, yes i wouldnt recommend using a server with lower than 256MB
            if ! [[ "$ram_allocation" =~ ^[0-9]+$ ]] || [[ $ram_allocation -lt 256 ]]; then
                echo -e "${RED}Invalid RAM allocation! Minimum is 256MB.${NC}"
                sleep 2
                return 1
            fi

            start_server_with_monitoring "$ram_allocation"
            ;;
        2)
            configure_server
            ;;
        3)
            show_header
            echo -e "${CYAN}Server Files:${NC}"
            echo
            ls -la "$SERVER_DIR"
            echo
            read -p "Press Enter to continue..."
            ;;
        4)
            echo -e "${RED}Are you sure you want to delete the server? (y/N): ${NC}"
            read -p "" confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                rm -rf "$SERVER_DIR"
                mkdir -p "$SERVER_DIR"
                echo -e "${GREEN}Server deleted successfully!${NC}"
                sleep 2
            fi
            ;;
        5)
            return 0
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            sleep 1
            manage_server
            ;;
    esac
}


install_server() {
    show_header
    echo -e "${BLUE}Select Minecraft Server Version:${NC}"
    echo

    local i=1
    local versions_array=()

    for version in "${!MC_VERSIONS[@]}"; do
        versions_array+=("$version")
        echo "$i. Minecraft $version"
        ((i++))
    done

    echo "$i. Back to main menu"
    echo

    read -p "Enter your choice: " version_choice

    # Back to menu option
    if [[ $version_choice -eq $i ]]; then
        return 0
    fi

    # Validate choice
    if ! [[ "$version_choice" =~ ^[0-9]+$ ]] || [[ $version_choice -lt 1 ]] || [[ $version_choice -gt ${#versions_array[@]} ]]; then
        echo -e "${RED}Invalid choice!${NC}"
        sleep 2
        install_server
        return
    fi

    # Get selected version
    local selected_version="${versions_array[$((version_choice-1))]}"

    show_header
    echo -e "${YELLOW}Installing Minecraft Server $selected_version...${NC}"
    echo

    # Setup directories
    setup_directories

    # Download and setup server
    download_server "$selected_version"

    echo -e "${GREEN}Minecraft Server $selected_version installed successfully!${NC}"
    echo -e "${BLUE}You can now start the server from the main menu.${NC}"
    sleep 3
}

# Function to show logs
show_logs() {
    show_header
    echo -e "${CYAN}Server Logs:${NC}"
    echo

    if [[ -f "$SERVER_DIR/logs/latest.log" ]]; then
        echo -e "${YELLOW}Showing last 50 lines of server log:${NC}"
        echo
        tail -50 "$SERVER_DIR/logs/latest.log"
    else
        echo -e "${YELLOW}No server logs found. Start the server first.${NC}"
    fi

    echo
    read -p "Press Enter to continue..."
}

# Function to kill all server processes
stop_server() {
    echo -e "${YELLOW}Stopping Minecraft Server...${NC}"

    # Kill tmux session
    tmux kill-session -t "mc-server" 2>/dev/null

    # Kill any remaining java processes
    pkill -f "minecraft.*server" 2>/dev/null
    pkill -f "server.jar" 2>/dev/null

    echo -e "${GREEN}Server stopped successfully!${NC}"
    sleep 2
}

# Main menu function
show_main_menu() {
    while true; do
        show_header
        echo -e "${BLUE}Main Menu:${NC}"
        echo
        echo "1. Install Dependencies"
        echo "2. Install Minecraft Server"
        echo "3. Manage Server"
        echo "4. View Server Logs"
        echo "5. Stop Running Server"
        echo "6. Exit"
        echo

        # Show server status
        if tmux has-session -t "mc-server" 2>/dev/null; then
            echo -e "${GREEN}● Server Status: RUNNING${NC}"
        else
            echo -e "${RED}● Server Status: STOPPED${NC}"
        fi

        if [[ -f "$SERVER_DIR/server.jar" ]]; then
            echo -e "${GREEN}● Server Installed: YES${NC}"
        else
            echo -e "${YELLOW}● Server Installed: NO${NC}"
        fi
        echo

        read -p "Enter your choice (1-7): " choice

        case $choice in
            1)
                show_header
                install_dependencies
                ;;
            2)
                install_server
                ;;
            3)
                manage_server
                ;;
            4)
                show_logs
                ;;
            5)
                stop_server
                ;;
            6)
                echo -e "${GREEN}Thank you for using Termux Minecraft Server Manager!${NC}"
                # Clean up any running monitoring processes
                tmux kill-session -t "mc-server" 2>/dev/null
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice! Please enter 1-7.${NC}"
                sleep 1
                ;;
        esac
    done
}


# Function to show initial setup wizard
initial_setup() {
    if [[ ! -f "$HOME/.mc-server-setup" ]]; then
        show_header
        echo -e "${YELLOW}Welcome to  Minecraft Server Manager!${NC}"
        echo
        echo -e "${CYAN}This appears to be your first time running this script.${NC}"
        echo -e "${CYAN}Let's set up everything you need to run a Minecraft server.${NC}"
        echo
        echo -e "${BLUE}The setup process will:${NC}"
        echo "• Install required dependencies (Java, wget, curl, etc.)"
        echo "• Create necessary directories"
        echo "• Allow you to download a Minecraft server"
        echo

        read -p "Would you like to run the initial setup? (Y/n): " setup_confirm

        if [[ ! "$setup_confirm" =~ ^[Nn]$ ]]; then
            show_header
            echo -e "${YELLOW}Running initial setup...${NC}"
            echo

            install_dependencies || {
                echo -e "${RED}Setup failed! Please try again.${NC}"
                exit 1
            }

            setup_directoriese
            touch "$HOME/.mc-server-setup"
            echo -e "${GREEN}Initial setup completed successfully!${NC}"
            echo -e "${BLUE}You can now install and manage Minecraft servers.${NC}"
            sleep 3
        else
            touch "$HOME/.mc-server-setup"
        fi
    fi
}

show_instructions() {
    show_header
    echo -e "${CYAN}Usage Instructions:${NC}"
    echo
    echo -e "${YELLOW}Getting Started:${NC}"
    echo "1. Run 'Install Dependencies' first (one-time setup)"
    echo "2. Install a Minecraft server version"
    echo "3. Configure server settings if needed"
    echo "4. Start the server with desired RAM allocation"
    echo
    echo -e "${YELLOW}Server Control:${NC}"
    echo "• Server runs in tmux session 'mc-server'"
    echo "• Press Ctrl+C to stop the server"
    echo "• Use 'tmux attach -t mc-server' to reconnect"
    echo "• Resource monitoring appears on the right panel"
    echo
    echo -e "${YELLOW}Important Notes:${NC}"
    echo "• Ensure you have enough storage (1GB+ recommended)"
    echo "• Allocate appropriate RAM for your device"
    echo "• Server files are stored in ~/minecraft-server/"
    echo
    read -p "Press Enter to continue..."
}

main() {

    # Show instructions on first run
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_instructions
        return 0
    fi

    initial_setup
    show_main_menu
}
main "$@"
