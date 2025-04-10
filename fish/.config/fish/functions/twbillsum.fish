function twbillsum
  if not set -q argv[1]
    echo "arg required"
    return
  end

  timew billing $argv :year :ids | grep -E (date '+^%m/../%y') | awk -F, '{s+=$3} END {print s}'
end
