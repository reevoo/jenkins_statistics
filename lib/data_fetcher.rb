class DataFetcher
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def all_data
    @_build_data ||= build_data
  end

  def all_builds
    @_all_builds ||= DataFetcher.http_get(base_url)['builds']
  end

  def all_builds_detailed
    @_all_builds_detailed ||= get_builds_detailed
  end

  def self.http_get(url)
    JSON.parse(Net::HTTP.get(URI(url)))
  rescue JSON::ParserError
    nil
  end

  private

  def build_data
    build_data = []
    all_builds.each do |build|
      build_data << DataFetcher.http_get("#{build['url']}api/json")
    end
    build_data
  end

  def get_builds_detailed
    builds_detailed = all_data.dup
    builds_detailed.map do |build|
      build[:detailed_output] = DataFetcher.http_get(build['url'] + 'artifact/rspec.json')
    end
    builds_detailed
  end

  def base_url
    "http://ci-url.com/job/#{project}/api/json"
  end
end