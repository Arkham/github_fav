class GithubUser
  class UserNotFound < StandardError; end

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def favourite_language
    favourite_language_with_count ? favourite_language_with_count.first : nil
  end

  def favourite_language_with_count
    repos.map do |repo|
      repo["language"]
    end.each_with_object(Hash.new(0)) do |language, hash|
      hash[language] += 1
    end.max_by { |_,v| v }
  end

  def repos
    client.user_repos(name)
  rescue GithubClient::NotFound
    raise GithubUser::UserNotFound
  end

  private

  def client
    @client ||= GithubClient.new
  end
end

require 'json'
require 'net/http'

class GithubClient
  class NotFound < StandardError; end

  API_URL = "https://api.github.com"

  def user_repos(user)
    request(user_repos_url(user))
  end

  def user_repos_url(user)
    [ user_url(user), "repos" ].join("/")
  end

  def user_url(user)
    [ API_URL, "users", user ].join("/")
  end

  def request(url)
    response = Net::HTTP.get_response(URI.parse(url))

    case response
    when Net::HTTPSuccess then
      JSON.parse(response.body)
    when Net::HTTPNotFound then
      raise GithubClient::NotFound
    end
  end
end

