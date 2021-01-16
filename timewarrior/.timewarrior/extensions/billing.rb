#!/usr/bin/env ruby

require 'json'
require 'date'
require 'csv'

class Float
  def round_to_quarter
    (self * 4.0).ceil / 4.0
  end
end

config = ""
json = ""
client_tag = nil
config_done = false

ARGF.read.each_line do |line|
  if config_done
    json << line
  else

    tag_key = "temp.report.tags:"

    if line.start_with?(tag_key)
      tags = line.sub(tag_key, "").split(",").map(&:strip).select { |t| t != "" }

      if tags.count != 1
        puts "Usage: timew billing <tag>"
        exit
      else
        client_tag = tags.first
      end
    end

    config << line
  end

  if line == "\n"
    config_done = true
  end
end

rows = []

offset = DateTime.now.offset
JSON.parse(json).select { |item| !!item["end"] }.group_by { |item|
  # Group by the date
  DateTime.parse(item["start"]).new_offset(offset).to_date.to_s
}.map { |date, date_items|

  # Group by the tag/activity
  date_items.group_by { |item|
    item["tags"]
  }.each { |tags, tag_items|
    row = []

    # Sum the total time for each item with the same date and tags
    total_seconds = tag_items.map { |item|
      diff = (DateTime.parse(item["end"]) - DateTime.parse(item["start"]))
      seconds = (diff * 24 * 60 * 60).to_i

      seconds
    }.sum()

    hours = (total_seconds / 3600.0).round_to_quarter

    row << Date.parse(date).strftime("%m/%d/%y")
    row << ""
    row << Time.at(total_seconds).utc.strftime("%H:%M:%S")
    row << hours
    row << ""
    row << ""
    tags.reject { |t| t == client_tag }.each { |t| row << t }

    rows << row
  }
}

#rows.each { |row|
#  puts row.join(",")
#}

config = {
  encoding: 'ISO-8859-1'
}

puts CSV.generate(config) { |csv|
  rows.each { |row| csv << row }
}
