#!/usr/bin/env ruby

require 'json'
require 'date'

class Float
  def round_to_quarter
    (self * 4.0).ceil / 4.0
  end
end

config = ""
json = ""
config_done = false

ARGF.read.each_line do |line|
  if config_done
    json << line
  else

    tag_key = "temp.report.tags:"

    if line.start_with?(tag_key)
      tags = line.sub(tag_key, "").split(",").map(&:strip).select { |t| t != "" }
    end

    config << line
  end

  if line == "\n"
    config_done = true
  end
end

rows = []

offset = DateTime.now.offset
JSON.parse(json).select { |item| !!item["end"] }.filter { |item|
  # Group by the date
  DateTime.parse(item["start"]).new_offset(offset).to_date.to_s == Date.today.prev_day.to_s
}.map { |date_items|
  tag = date_items["tags"].filter { |t| t.strip != "BS" }.first

  puts "* #{tag}"
}
