# Defined in - @ line 0
function gsw --description 'alias gsw=git switch' --wraps "git switch"
	git switch $argv;
end
