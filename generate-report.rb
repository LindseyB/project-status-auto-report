require 'net/http'
require 'uri'
require 'json'

projectQuery = <<~GRAPHQL
  query {
    repository(name: "Shopping-Expansion-Team", owner:"stitchfix") {
      project(number:4){
        columns(last: 4) {
          edges {
            node {
              name
              cards(first: 25) {
                totalCount
                edges {
                  node {
                    content {
                      ... on Issue {
                        title
                        state
                        url
                        assignees(first: 10) {
                          edges {
                            node {
                              login
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
GRAPHQL

uri = URI.parse("https://api.github.com/graphql")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "bearer #{ENV["GITHUB_TOKEN"]}"
request.body = JSON.dump({
  "query" => projectQuery
})

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

res = JSON.parse(response.body)
time = Time.new

title = "Weekly Status Report for the Week of #{time.strftime("%m/%d")}"

body = ""

body += "# #{title} ✨ \n"

res["data"]["repository"]["project"]["columns"]["edges"].each do |column|
  body += "## #{column["node"]["name"]} (total: #{column["node"]["cards"]["totalCount"]})\n\n"

  column["node"]["cards"]["edges"].each do |card|
    issue = card["node"]["content"]
    assignees = issue["assignees"]["edges"]

    assigneesArr = assignees.map do |a|
      "@#{a["node"]["login"]}"
    end

    attribution_string = assigneesArr.any? ? "by #{assigneesArr.join(',')}" : ""

    body += "* [#{issue["title"]}](#{issue["url"]}) #{attribution_string}\n"
  end

  puts "\n"
end


uri = URI.parse("https://api.github.com/repos/stitchfix/Shopping-Expansion-Team/issues")
request = Net::HTTP::Post.new(uri)
request["Accept"] = "application/vnd.github.v3+json"
request["Authorization"] = "token #{ENV["GITHUB_TOKEN"]}"
request.body = JSON.dump({
  "title" => title,
  "body" => body,
  "labels" => ["status"]
})
req_options = {
  use_ssl: uri.scheme == "https"
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
