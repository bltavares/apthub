require "sinatra"
require "faraday"
require "faraday_middleware"
require "json"

get '/:user/:repo/Packages' do | user, repo |
  reply = Faraday.get("https://api.github.com/repos/#{user}/#{repo}/releases")
  releases = JSON.parse(reply.body)
  assets = releases.flat_map { |release|
    release['assets'].select { |asset|
      asset['name'] =~ /.deb$/
    }.map { |asset|
      asset.merge({ 'version' => release['tag_name'] })
    }
  }

  assets.flat_map { |asset|
    [
      "Package: #{repo}",
      "Maintainer: #{user}",
      "Filename: #{repo}/#{asset['id']}",
      "Homepage: https://github.com/#{user}/#{repo}",
      "Version: #{asset['version']}",
      "Size: #{asset['size']}",
      "",
    ]
  }.join "\n"
end

get '/:user/:repo/:id' do | user, repo, id |
  pass unless id =~ /^[0-9]+$/
  content_type "application/x-deb"


  user = :bltavares
  repo = :baseline
  id = 88566
  Faraday.new("https://api.github.com") {|connection|
    connection.use FaradayMiddleware::FollowRedirects
    connection.adapter Faraday.default_adapter
  }.get("/repos/#{user}/#{repo}/releases/assets/#{id}", {}, { Accept: 'application/octet-stream' }).body
end
