function tmixf --wraps='mix test --failed' --description 'alias tmixf=mix test --failed'
  mix test --failed $argv
        
end
