require 'octokit'
require 'launchy'
require 'pry'
require './secrets.rb'
require './config.rb'

Octokit.auto_paginate = true

client = Octokit::Client.new(:access_token => API_ACCESS_TOKEN)

pr_list = []

diff = client.compare(REPO, BASE, HEAD)

# The 5 below is the max number of digits the method will match
# If the repo you're searching has over 100,000 prs / issues, change to 6, etc.
diff.commits.each do |c|
  pr_list << (/[#]\d{1,5}/.match(c.commit.message)).to_s.delete!('#') if c.commit.message =~ /[#]\d/
end

pr_list.each do |pr|
    Launchy.open(BASE_URL + pr)
    sleep(0.2) # prevent Launchy from dying when you have 20+ prs
end

puts diff.commits.size
puts "API calls left: #{client.rate_limit.remaining}"

# TODO

# - Ensure all opened; looks like you get 250 cutoff right now
# - Handle errors
# - Message if nothing opens because envs are actually identical
# - investigate launchy errors
