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

JSON.parse(json).map { |item|
  { id: item["id"], tags: item["tags"].join(", ") }
}.reverse.reduce([]) { |acc, item|
  break acc if acc.count >= 10
  next acc if acc.any? { |i| i[:tags] == item[:tags] }

  acc.push(item)
}.each { |item|
  puts "@#{item[:id]} #{item[:tags]}"
}
