#!/bin/bash

START_TIME=$(date +%s)

echo "----------------------------------------"
echo "Checking for processes on port 5678..."
PORT_PROCESSES=$(lsof -ti tcp:5678)

if [ -z "$PORT_PROCESSES" ]; then
  echo "✅ No processes found on port 5678."
else
  echo "Found process(es) on port 5678:"
  lsof -i tcp:5678
  echo "Killing these processes..."
  echo "$PORT_PROCESSES" | xargs kill -9 2>/dev/null
  echo "✔ Port 5678 cleared."
fi

echo "----------------------------------------"
echo "Stopping old n8n sessions..."
pkill -f "node /usr/local/bin/n8n"
pkill -f "task-runner"

echo "Checking for old ngrok sessions..."
NGROK_PROCESSES=$(pgrep -fl ngrok)
if [ -z "$NGROK_PROCESSES" ]; then
  echo "✅ No ngrok processes found."
else
  echo "Found ngrok process(es):"
  echo "$NGROK_PROCESSES"
  echo "Stopping old ngrok sessions..."
  pkill -f ngrok
  sleep 2
  if pgrep -f ngrok > /dev/null; then
    echo "⚠️ Warning: ngrok processes still running! Attempting force kill..."
    pkill -9 -f ngrok
    sleep 2
    if pgrep -f ngrok > /dev/null; then
      echo "❌ Unable to terminate ngrok processes. Please check manually or clear sessions at https://dashboard.ngrok.com/agents"
      exit 1
    else
      echo "✔ ngrok processes force-killed successfully."
    fi
  else
    echo "✔ All ngrok processes stopped cleanly."
  fi
fi

echo "----------------------------------------"
echo "Starting ngrok..."
ngrok http 5678 > /dev/null &

NGROK_URL=""
MAX_ATTEMPTS=10
ATTEMPT=1
echo "Waiting for ngrok to be ready..."
while [ -z "$NGROK_URL" ] && [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | sed -e 's/\"public_url\":\"//')
  if [ -z "$NGROK_URL" ]; then
    echo "Attempt $ATTEMPT/$MAX_ATTEMPTS: ngrok not ready yet..."
    sleep 2
    ((ATTEMPT++))
  fi
done

if [ -z "$NGROK_URL" ]; then
  echo "❌ ngrok did not start in time. Please check your setup and try again."
  exit 1
else
  echo "✅ Ngrok is ready! URL: $NGROK_URL"
fi

echo "----------------------------------------"
echo "Setting Telegram webhook..."
WEBHOOK_URL="$NGROK_URL/webhook/$WEBHOOK_UUID/webhook"
WEBHOOK_RESPONSE=$(curl -s -F "url=$WEBHOOK_URL" "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/setWebhook")

if echo "$WEBHOOK_RESPONSE" | grep -q '"ok":true'; then
  echo "✅ Telegram webhook set successfully."
else
  ERROR_DESC=$(echo "$WEBHOOK_RESPONSE" | grep -o '"description":"[^"]*' | sed 's/"description":"//')
  echo "❌ Failed to set Telegram webhook: $ERROR_DESC"
  exit 1
fi

echo "----------------------------------------"
echo "Starting n8n with no authentication or MFA..."
N8N_BASIC_AUTH_ACTIVE=false N8N_SKIP_WEBHOOK_DEREGISTRATION=true WEBHOOK_URL=$NGROK_URL n8n start > /dev/null &

echo "Waiting for n8n to be ready..."
MAX_ATTEMPTS=15
ATTEMPT=1
until curl --output /dev/null --silent --head --fail http://localhost:5678/ || [ $ATTEMPT -gt $MAX_ATTEMPTS ]; do
  printf "Attempt %d/%d: n8n not ready yet...\n" "$ATTEMPT" "$MAX_ATTEMPTS"
  ((ATTEMPT++))
  sleep 2
done

if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
  echo "❌ n8n did not start in time. Please check the process and try again."
  exit 1
else
  echo "✅ n8n is ready and responding at http://localhost:5678/"
fi

echo ""
echo "✅ All systems are live!"
echo "➡️  Open $NGROK_URL to access your workflow. Webhooks and UI are fully synced for local development."

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
echo "⏱️  Ignite sequence completed in $ELAPSED seconds."

