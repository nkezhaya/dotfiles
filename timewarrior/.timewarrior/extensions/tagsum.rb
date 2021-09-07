#!/usr/bin/env ruby

require 'json'

json = ""
config_done = false

ARGF.read.each_line do |line|
  if config_done
    json << line
  end

  if line == "\n"
    config_done = true
  end
end

JSON.parse(json).select { |item| item["id"] <= 10 }.each { |item|
  puts "@#{item["id"]} #{item["tags"].join(", ")}"
}
