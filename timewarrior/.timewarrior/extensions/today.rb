#!/usr/bin/env ruby

require 'json'
require 'date'

class Float
  def round_to_quarter
    (self * 4.0).ceil / 4.0
  end
end

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

rows = []

offset = DateTime.now.offset
JSON.parse(json).group_by { |item|
  # Group by the date
  DateTime.parse(item["start"]).new_offset(offset).to_date.to_s
}.select { |date, item|
  date.to_s == Date.today.to_s
}.map { |date, date_items|

  # Group by the tag/activity
  date_items.group_by { |item|
    item["tags"]
  }.each { |tags, tag_items|
    row = []

    # Sum the total time for each item with the same date and tags
    total_seconds = tag_items.map { |item|
      if item["end"]
        finish = DateTime.parse(item["end"])
      else
        finish = DateTime.now
      end

      diff = (finish - DateTime.parse(item["start"]))
      seconds = (diff * 24 * 60 * 60).to_i

      seconds
    }.sum()

    hours = (total_seconds / 3600.0).round_to_quarter

    tags.each { |t| row << t }
    row << Time.at(total_seconds).utc.strftime("%H:%M:%S")
    row << hours

    rows << row
  }
}

rows.each { |row|
  puts row.join(" - ")
}

total = rows.map { |row| row.last }.sum()

puts "\nTotal: #{total}"
