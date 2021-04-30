# Defined in - @ line 1
function psql --wraps=pgcli --description 'alias psql=pgcli'
  pgcli  $argv;
end
