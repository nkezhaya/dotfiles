function pxmix --wraps='iex --dbg pry -S mix phx.server' --description 'alias pxmix iex --dbg pry -S mix phx.server'
    iex --dbg pry -S mix phx.server $argv
end
