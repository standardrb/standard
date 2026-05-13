#!/usr/bin/env ruby

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: parse_changelog.rb [options]"
  opts.on("--old VERSION", "Old version (e.g., 1.84.0)") { |v| options[:old] = v }
  opts.on("--new VERSION", "New version (e.g., 1.86.1)") { |v| options[:new] = v }
end.parse!

unless options[:old] && options[:new]
  warn "Error: Missing --old or --new version"
  exit 1
end

changelog = STDIN.read
lines = changelog.lines

new_version_found = false
relevant_lines = []

# RuboCop versions in CHANGELOG can be "## 1.86.0" or "## [1.86.0]"
lines.each do |line|
  if line =~ /^## \[?#{Regexp.escape(options[:new])}\]?/
    new_version_found = true
  elsif line =~ /^## \[?#{Regexp.escape(options[:old])}\]?/
    break if new_version_found
  end
  relevant_lines << line if new_version_found
end

def extract_cops(lines, section_header)
  cops = []
  in_section = false
  lines.each do |line|
    if line =~ /^### #{section_header}/
      in_section = true
    elsif line =~ /^### /
      in_section = false
    end

    next unless in_section

    # Formats:
    # 1. * Add new `Cop/Name` cop. ([#123](url))
    # 2. * [#123](url): Add new `Cop/Name` cop.
    # 3. * **Cop/Name**: Description ([#123](url))
    
    if line =~ /^\s*\*\s+.*`([^`]+)`.*\[#(\d+)\]\(([^)]+)\):?\s*(.*)$/
      cops << { name: $1, pr_id: $2, pr_url: $3, description: $4.strip.gsub(/\.$/, '') }
    elsif line =~ /^\s*\*\s+.*`([^`]+)`.*:?\s*(.*)\s+\(\[#(\d+)\]\(([^)]+)\)\)$/
      cops << { name: $1, pr_id: $3, pr_url: $4, description: $2.strip.gsub(/\.$/, '') }
    elsif line =~ /^\s*\*\s+\[#(\d+)\]\(([^)]+)\):\s+.*`([^`]+)`\s*(.*)$/
      cops << { name: $3, pr_id: $1, pr_url: $2, description: $4.strip.gsub(/\.$/, '') }
    elsif line =~ /^\s*\*\s+\*\*([^*]+)\*\*:\s*(.*)\s+\(\[#(\d+)\]\(([^)]+)\)\)$/
      cops << { name: $1, pr_id: $3, pr_url: $4, description: $2.strip.gsub(/\.$/, '') }
    end
  end
  cops.uniq { |c| c[:name] }
end

new_cops = extract_cops(relevant_lines, "New features")
changed_cops = extract_cops(relevant_lines, "Changes")

def print_table(title, cops, column_name)
  return if cops.empty?
  puts "## #{title}"
  puts ""
  if title == "New cops"
    puts "| Cop | Description | Recommendation | Rationale | PR |"
    puts "|-----|-------------|----------------|-----------|-----|"
    cops.each do |cop|
      desc = cop[:description].empty? ? "No description provided" : cop[:description]
      # Placeholders for the agent to fill in
      puts "| `#{cop[:name]}` | #{desc} | {RECOMMENDATION} | {RATIONALE} | [##{cop[:pr_id]}](#{cop[:pr_url]}) |"
    end
  else
    puts "| Cop | #{column_name} | PR |"
    puts "|-----|-------------|-----|"
    cops.each do |cop|
      desc = cop[:description].empty? ? "No description provided" : cop[:description]
      puts "| `#{cop[:name]}` | #{desc} | [##{cop[:pr_id]}](#{cop[:pr_url]}) |"
    end
  end
  puts ""
end

print_table("New cops", new_cops, "Description")
print_table("Changed cops", changed_cops, "Change")
