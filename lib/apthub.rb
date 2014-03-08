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
      "Version: #{asset['version']}",
      "Architecture: all",
      "Maintainer: #{user}",
      #Installed-Size: 0
      "Filename: #{repo}/#{asset['id']}",
      "Size: #{asset['size']}",
      #MD5sum: c45431e9a34dc4076c78950a6d2091c9
      #SHA1: e4b506e239a3f0f4ef600623eb14d8a8fe27db0f
      #SHA256: e702a5ee1ab5a208877764b6419b1631e7d246c573cba20b77f3c16927f3279e
      "Section: default",
      "Priority: extra",
      "Homepage: https://github.com/#{user}/#{repo}",
      "Description: no description given",
      "License: unknown",
      "Vendor: apthub",
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
