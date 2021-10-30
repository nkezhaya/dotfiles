# Defined in - @ line 0
function glg --description 'alias glg=git log'
	env LESS=-Ri git log $argv;
end
