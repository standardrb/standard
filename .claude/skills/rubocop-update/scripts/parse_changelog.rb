#!/usr/bin/env ruby

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: parse_changelog.rb [options]"
  opts.on("--old VERSION", "Old version (e.g., 1.84.0)") { |v| options[:old] = v }
  opts.on("--new VERSION", "New version (e.g., 1.86.1)") { |v| options[:new] = v }
  opts.on("--no-recommendations", "Skip recommendation and rationale columns") { options[:no_recommendations] = true }
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
    
    # Regex 1: * [#123](url): Add new `Cop/Name` cop. ([@user][])
    # Regex 2: * Add new `Cop/Name` cop. ([#123](url))
    # Regex 3: * **Cop/Name**: Description ([#123](url))
    
    # Regex 1: * [#123](url): Add new `Cop/Name` cop. ([@user][])
    # Regex 2: * Add new `Cop/Name` cop. ([#123](url))
    # Regex 3: * **Cop/Name**: Description ([#123](url))
    
    if line =~ /^\s*\*\s+\[#(\d+)\]\(([^)]+)\):\s+(.*)\s*`([^`]+)`.*$/
      pr_id, pr_url, desc, name = $1, $2, $3, $4
    elsif line =~ /^\s*\*\s+(.*)\s*`([^`]+)`.*\[#(\d+)\]\(([^)]+)\).*$/
      desc, name, pr_id, pr_url = $1, $2, $3, $4
    elsif line =~ /^\s*\*\s+\*\*([^*]+)\*\*:\s*(.*)\s+\(\[#(\d+)\]\(([^)]+)\)\)$/
      name, desc, pr_id, pr_url = $1, $2, $3, $4
    else
      next
    end

    # Clean up description
    desc = desc.to_s.strip
    desc = desc.gsub(/\s*\(\[@[\w-]*\]\[\]\)$/, '') # Strip ([@user][])
    desc = desc.gsub(/\s*cop\.?$/, '') # Strip " cop" at end
    desc = desc.gsub(/^\s*:?\s*/, '') # Strip leading colon/space
    desc = desc.strip
    desc = "New cop" if desc.empty?
    
    cops << { name: name, pr_id: pr_id, pr_url: pr_url, description: desc.gsub(/\.$/, '') }
  end
  cops.uniq { |c| c[:name] }
end

new_cops = extract_cops(relevant_lines, "New features")
changed_cops = extract_cops(relevant_lines, "Changes")

def print_table(title, cops, column_name, options = {})
  return if cops.empty?
  puts "## #{title}"
  puts ""
  if title == "New cops"
    if options[:no_recommendations]
      puts "| Cop | Description | PR |"
      puts "|-----|-------------|-----|"
    else
      puts "| Cop | Description | Recommendation | Rationale | PR |"
      puts "|-----|-------------|----------------|-----------|-----|"
    end
    cops.each do |cop|
      desc = cop[:description].empty? ? "No description provided" : cop[:description]
      if options[:no_recommendations]
        puts "| `#{cop[:name]}` | #{desc} | [##{cop[:pr_id]}](#{cop[:pr_url]}) |"
      else
        # Placeholders for the agent to fill in
        puts "| `#{cop[:name]}` | #{desc} | {RECOMMENDATION} | {RATIONALE} | [##{cop[:pr_id]}](#{cop[:pr_url]}) |"
      end
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

print_table("New cops", new_cops, "Description", options)
print_table("Changed cops", changed_cops, "Change", options)
