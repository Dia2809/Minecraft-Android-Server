# 🎮 Termux Minecraft Server Manager

A comprehensive, user-friendly shell script for hosting Minecraft servers on Android devices using Termux. Features an intuitive UI, automatic dependency management, real-time resource monitoring, and support for multiple Minecraft versions.

![Minecraft Server](https://img.shields.io/badge/Minecraft-Java%20Edition-green)
![Termux](https://img.shields.io/badge/Platform-Termux-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Version](https://img.shields.io/badge/Version-1.0.0-orange)

## ✨ Features

### 🎯 **Easy Setup**
- **One-click dependency installation** - Automatically installs Java 17, wget, curl, and other required packages
- **First-time setup wizard** - Guides you through initial configuration
- **Automatic directory structure creation** - Sets up all necessary folders

### 🎮 **Multiple Minecraft Versions**
- **Automatic server download** with direct links from Mojang
- **Pre-configured server settings** with sensible defaults

### 📊 **Real-time Monitoring**
- **Split-screen interface** - Server console on left, htop monitoring on right
- **Live resource usage** - CPU, RAM, and process monitoring via htop
- **Server status indicators** - Visual feedback on server state

### ⚙️ **Server Management**
- **Configurable RAM allocation** - From 512MB to 4GB+ based on your device
- **Server configuration editor** - Modify port, max players, game mode, difficulty, and MOTD
- **Log viewing and management** - Easy access to server logs
- **Start/stop functionality** - Clean server lifecycle management

### 🎨 **User Experience**
- **Colorful, intuitive interface** - Clear navigation with color-coded feedback
- **Menu-driven operation** - No command-line knowledge required
- **Error handling and validation** - Prevents common configuration mistakes

## 📱 Requirements

### **Device Requirements**
- Android device with **2GB+ RAM** (4GB+ recommended)
- **1GB+ free storage space**
- Stable internet connection

### **Software Requirements**
- **Termux** app installed from [F-Droid](https://f-droid.org/packages/com.termux/) (recommended) or [GitHub](https://github.com/termux/termux-app)

## 🚀 Installation

### **Method 1: Direct Download**
```bash
# Download the script
curl -L -o minecraft-server.sh https://github.com/Dia2809/Minecraft-Android-Server/main/minecraft-server.sh
# Make it executable
chmod +x minecraft-server.sh
# Run the script
./minecraft-server.sh
```
### **Method 2: Manual Setup**
1. Copy the script content from the repository
2. Create a new file: `nano minecraft-server.sh`
3. Paste the content and save (Ctrl+X, Y, Enter)
4. Make executable: `chmod +x minecraft-server.sh`
5. Run: `./minecraft-server.sh`

## 📖 Quick Start Guide

### **1. First Run**
```bash
./minecraft-server.sh
```
- The script will detect it's your first time and run the setup wizard
- Choose "Yes" to install dependencies automatically
- Wait for Java 17 and other packages to install

### **2. Install a Minecraft Server**
- Select **"Install Minecraft Server"** from the main menu
- Choose your preferred Minecraft version (1.7.10 recommended)
- Wait for download and automatic configuration

### **3. Start Your Server**
- Go to **"Manage Server"** → **"Start Server"**
- Choose RAM allocation based on your device:
  - **512MB** - Minimal (1-2 players)
  - **1024MB** - Small (3-5 players) 
  - **2048MB** - Medium (6-10 players)
  - **4096MB** - Large (10+ players)

### **4. Connect to Your Server**
- **Network connections:** `[your-ip]:25565`
- Use `ip addr show wlan0` to find your IP address

## 🎛️ Interface Overview

### **Main Menu Options**
1. **Install Dependencies** - One-time setup of required packages
2. **Install Minecraft Server** - Download and configure server versions
3. **Manage Server** - Start, configure, and manage your server
4. **Check System Requirements** - Verify your system is ready
5. **View Server Logs** - Check server output and errors
6. **Stop Running Server** - Safely terminate server processes
7. **Exit** - Close the application

### **Server Management**
- **Start Server** - Launch with custom RAM allocation
- **Configure Server** - Edit server.properties settings
- **View Server Files** - Browse server directory
- **Delete Server** - Remove server installation

### **Split-Screen Mode**
When running a server:
- **Left Panel (70%)** - Minecraft server console
- **Right Panel (30%)** - htop system monitor
- **Navigation** - Use tmux controls or press Ctrl+C to stop

## ⚙️ Configuration

### **Server Settings**
The script allows you to configure:
- **Server Port** (default: 25565)
- **Max Players** (default: 10)
- **Game Mode** (survival, creative, adventure, spectator)
- **Difficulty** (peaceful, easy, normal, hard)
- **Server MOTD** (Message of the Day)

### **File Locations**
```
~/minecraft-server/
├── server/           # Server files and world data
├── logs/            # Server logs
└── java/            # Java installation (if needed)
```

### **Advanced Configuration**
For advanced users, you can manually edit:
- `~/minecraft-server/server/server.properties` - Main server configuration
- `~/minecraft-server/server/whitelist.json` - Player whitelist
- `~/minecraft-server/server/ops.json` - Server operators

## 🔧 Troubleshooting

### **Common Issues**

#### **"Java not found" Error**
```bash
# Reinstall Java
pkg install openjdk-17 -y
```

#### **"Permission denied" Error**
```bash
# Fix permissions
chmod +x minecraft-server.sh
```

#### **Server won't start**
1. Check available RAM: `free -h`
2. Verify Java installation: `java -version`
3. Check server logs in the script menu
4. Ensure server.jar exists in `~/minecraft-server/server/`

#### **Can't connect to server**
1. Check if server is running: Server status in main menu
2. Verify port (default 25565) isn't blocked
3. For network play, check firewall settings
4. Use correct IP address: `ip addr show wlan0`

#### **Low performance**
1. Reduce RAM allocation if you allocated too much
2. Lower render distance in client settings
3. Close unnecessary apps on your device
4. Consider using older Minecraft versions (1.7.10)

### **Getting Help**
1. Check the **"View Server Logs"** option in the script
2. Run **"Check System Requirements"** to verify setup
3. Open an issue on GitHub with:
   - Your device specifications
   - Error messages or logs
   - Steps to reproduce the problem

## 📊 Performance Tips

### **Optimization for Android**
- **RAM allocation:** Don't exceed 70% of your device's total RAM
- **CPU usage:** Monitor with htop and adjust settings if needed
- **Storage:** Use fast internal storage, avoid SD cards
- **Network:** Use 5GHz WiFi for better performance

### **Server Optimization**
- Lower `view-distance` in server.properties (default: 10 → 6-8)
- Reduce `max-players` for better performance
- Use `peaceful` or `easy` difficulty to reduce mob processing
- Regular world backups and cleanup of unused chunks

### **Device Settings**
- Enable "Developer Options" and disable animations
- Close background apps before starting server
- Use airplane mode + WiFi for dedicated server device
- Consider using a cooling fan for extended sessions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Termux Minecraft Server Manager

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 🙏 Acknowledgments

- **Termux Team** - For providing the amazing Android terminal emulator
- **Mojang Studios** - For creating Minecraft
- **Community Contributors** - For testing, feedback, and improvements
- **Open Source Projects** - htop, tmux, and other tools used in this script
- **Clifano** - [For making the Database for the server.jar](https://gist.github.com/cliffano/77a982a7503669c3e1acb0a0cf6127e9)
- **drmatoi** - [For the orignal Base](https://github.com/drmatoi/minecraft)

---

**⭐ If this project helped you, please give it a star on GitHub!**

**🐛 Found a bug or have a suggestion? [Open an issue](https://github.com/yourusername/termux-minecraft-server/issues/new)**

**💬 Questions? Join the discussion in our [GitHub Discussions](https://github.com/yourusername/termux-minecraft-server/discussions)**
