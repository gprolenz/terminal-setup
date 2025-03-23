#!/bin/bash
BOT_TOKEN="7916132027:AAEj2jVSPjqAfjaeYKLKB3wBnBvogE8tuKw"
NGROK_URL="https://c4f9-2600-4041-534b-6a00-8d31-e98e-a42a-ebff.ngrok-free.app"
curl -F "url=${NGROK_URL}/webhook" https://api.telegram.org/bot${BOT_TOKEN}/setWebhook
