# if seconds is 0 get balance from deepseek
if [ $(date +%S) -eq 0 ]; then
    # execute python command from a string
    OPENAI_API_KEY=`cat ~/tokens/deepseek.token` python ~/bin/tmux-scripts/deepseek.py 2>&1 |tee /tmp/deepseek_balance &
else
    # show balance saved
    cat /tmp/deepseek_balance
fi
