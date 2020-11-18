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

puts title
puts "# #{title} ✨ \\"

res["data"]["repository"]["project"]["columns"]["edges"].each do |column|
  puts "## #{column["node"]["name"]} \\ \n\n"

  column["node"]["cards"]["edges"].each do |card|
    issue = card["node"]["content"]
    assignees = issue["assignees"]["edges"]

    assigneesArr = assignees.map do |a|
      "@#{a["node"]["login"]}"
    end

    attribution_string = assigneesArr.any? ? "by #{assigneesArr.join(',')}" : ""

    puts "* [#{issue["title"]}]\\(#{issue["url"]}\\) #{attribution_string} \\ \n"
  end

  puts "\\ \n"
end
