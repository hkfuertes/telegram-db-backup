#! /bin/bash
# Usage: $ ./upload_to_telegram.sh <file_path>
# TELEGRAM_TOKEN & CHAT_ID env variables must exist!

if [ -e LAST_MESSAGE ]
then
    LAST_MESSAGE=`cat LAST_MESSAGE`
    # Remove previous upload if LAST_MESSAGE exists
    curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/deleteMessage?chat_id=$CHAT_ID&message_id=$LAST_MESSAGE" -o /dev/null
fi

# Run the upload
curl -s -F document=@"$1" "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument?chat_id=$CHAT_ID" | jq '.result.message_id' > LAST_MESSAGE