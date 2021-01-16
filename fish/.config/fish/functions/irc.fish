# Defined in - @ line 0
function irc --description 'alias irc=ssh -t wpc tmux attach'
	ssh -t wpc tmux attach $argv;
end
