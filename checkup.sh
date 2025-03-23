#!/bin/bash

LOGFILE=~/checkup.log

echo "----------------------------------------"
echo "System Checkup - v1.0"
echo "----------------------------------------"

NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | sed -e 's/\"public_url\":\"//')

# Check ngrok status
echo "Checking ngrok status..."

NGROK_STATUS=$(curl -s http://127.0.0.1:4040/api/tunnels)

if echo "$NGROK_STATUS" | grep -q '"public_url"'; then
echo "$(date +'%Y-%m-%d %H:%M:%S') - [✓] Ngrok is running and responding." | tee -a $LOGFILE
else
  echo "[❌] Ngrok is not running or not responding."
fi

# Check n8n status
echo "Checking n8n status..."

if curl --output /dev/null --silent --head --fail http://localhost:5678/; then
echo "$(date +'%Y-%m-%d %H:%M:%S') - [✓] n8n is running and responsive." | tee -a $LOGFILE
else
  echo "[❌] n8n is not running or not responsive."
fi

# Check Telegram webhook status
echo "Checking Telegram webhook status..."

# Debug output
echo "NGROK_URL: $NGROK_URL"
echo "WEBHOOK_UUID: $WEBHOOK_UUID"

WEBHOOK_URL=$(curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getWebhookInfo" | jq -r .result.url)

if [[ "$WEBHOOK_URL" == "$NGROK_URL/webhook/$WEBHOOK_UUID/webhook" ]]; then
echo "$(date +'%Y-%m-%d %H:%M:%S') - [✓] Telegram webhook is correctly set." | tee -a $LOGFILE
else
  echo "[❌] Telegram webhook is not set correctly."
fi

if [[ "$NGROK_STATUS" == *"public_url"* ]] && curl --output /dev/null --silent --head --fail http://localhost:5678/; then
  echo "$(date +'%Y-%m-%d %H:%M:%S') - ✅ All systems are running smoothly." | tee -a $LOGFILE
else
  echo "$(date +'%Y-%m-%d %H:%M:%S') - ❌ Issues detected. See above for details." | tee -a $LOGFILE
fi

