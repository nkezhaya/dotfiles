function tmixoc --wraps='mix test --only current' --description 'alias tmixoc=mix test --only current'
  mix test --only current $argv
        
end
