#!/bin/bash

# Places.sh — Terminal Quick Reference

echo "----------------------------------------"
echo "Core Scripts (in ~/bin)"
echo "----------------------------------------"
echo "ignite.sh        nano ~/bin/ignite.sh     Master ignition — launches ngrok, sets webhook, starts n8n."
echo "checkup.sh       nano ~/bin/checkup.sh    Verifies health of ngrok, n8n, and Telegram webhook."
echo "set-telegram-webhook.sh  nano ~/bin/set-telegram-webhook.sh    Manually reset Telegram webhook (fallback manual control)."
echo "places.sh        nano ~/bin/places.sh      This reference file — easily edit or update."
echo ""
echo "----------------------------------------"
echo "Common Terminal Places"
echo "----------------------------------------"
echo "User home        cd ~                    Quickly jump to home directory."
echo "bin folder       cd ~/bin                 Where all personal scripts are stored."
echo "zshrc config     nano ~/.zshrc            Edit shell environment config & aliases."
echo "n8n config       nano ~/.n8n/config       Edit local n8n system configuration file."
echo "n8n database backup   cd ~/.n8n          Check your database backup or SQLite file."
echo "system processes  ps aux | grep n8n       View active system processes."
echo "port check (5678) lsof -i tcp:5678        Check if port 5678 is in use."
echo "kill port 5678    lsof -ti tcp:5678 | xargs kill -9     Kill processes on port 5678."
echo "active ngrok tunnels  curl -s http://127.0.0.1:4040/api/tunnels  See current ngrok URL."
echo "ngrok sessions dashboard   https://dashboard.ngrok.com/agents  View & clear ngrok sessions online."
echo ""
echo "----------------------------------------"
echo "System Commands (handy reminders)"
echo "----------------------------------------"
echo "source ~/.zshrc   Reload shell config changes without restarting terminal."
echo "chmod +x ~/bin/scriptname.sh  Make a script executable."
echo "pkill -f ngrok    Kill all ngrok processes manually."
echo "pkill -f n8n      Kill all running n8n processes."
echo "pm2 list (if installed)  View daemonized processes."
echo "launchctl list | grep n8n    Check if n8n is loaded in system services."
echo ""
echo "----------------------------------------"
echo "Optional Backup Commands (if relevant)"
echo "----------------------------------------"
echo "cd ~/ignite_backups    Go to script backup folder."
echo "ls -l ~/ignite_backups  See backup versions of ignite & changelog."
echo ""
echo "----------------------------------------"
echo "Pro tip: You can type nano ~/bin/places.sh to edit this file and keep it updated as your system evolves."

