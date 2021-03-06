# nowplaying.sh
### a pure sh POSIX script to print the "Plex Now Playing" status to stdout.

![Image](/images/screenshot.png)

### Purpose
This started out as a quick way to make sure I didn't kick anyone off the Plex server before doing an update or server reboot over SSH. It has become a little bit of of a hobby project to learn more about how the shell works, including a built-in XML parser.

### Features
- Fully POSIX-compliant out of the box
- Tested on Debian, Ubuntu, Fedora, Slackware, and FreeBSD
- No PlexPass or API credentials needed.

### Dependencies
- Just about any shell (sh, bash, zsh, fish, tcsh...)
- cuRl, wget, or fetch (looks in that order)
- Standard coreutils: sed, grep, command, tput

### Installation
Simply copy it into your path. Without any arguments it looks for a Plex server running on your local server.
See "Usage" below for more options.

I have put it in my .bashrc and pipe it into "lolcat" because it makes me happy.

### Usage

    Example: '"$PRGNAM" -p localhost,127.0.0.1,192.168.1.1 -w 80 -d "." 

        --plex, -p    IP address(es) or domain name of Plex Server
                      separated by commas, no spaces.
                      Default=localhost,127.0.0.1

        OPTIONAL PARAMATERS:

        --width, -w   Maximum number of columns width.
                      Default=0, "infinite"
        --delim, -d   Dot leader for display. Default = "."
       
        --force, -f   Skip dependency checks.

        --curl        Force curl as downloader.
        --wget        Force wget as downloader.
        --fetch       Force fetch as downloader.

### Exit Codes
- 0 It worked
- 1 Something went wrong
- 2 No XML file found

### Roadmap
- [x] Remove BASHisms and make it pure sh/posix compatible
- [ ] Reduce the dependancy on grep and sed
- [ ] Add colors, bold, italics, etc.
- [ ] Create a MAKEFILE for installation
