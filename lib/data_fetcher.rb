class DataFetcher
  attr_accessor :project

  def self.retrieve_rspec_json(build)
    http_get(build['url'] + 'artifact/rspec.json')
  end

  def initialize(project)
    @project = project
  end

  def all_data
    @_build_data ||= build_data
  end

  def all_builds
    @_all_builds ||= DataFetcher.http_get(base_url + '/api/json')['builds']
  end

  def all_builds_detailed
    @_all_builds_detailed ||= builds_detailed
  end

  def self.http_get(url)
    JSON.parse(Net::HTTP.get(URI(url)))
  rescue JSON::ParserError
    nil
  end

  def get_build(build_number)
    DataFetcher.http_get(base_url + '/' + build_number.to_s + '/api/json')
  end

  def overall_data
    DataFetcher.http_get(base_url + '/api/json')
  end

  def each_build
    all_builds.each do |build|
      yield DataFetcher.http_get("#{build['url']}api/json")
    end
  end

  private

  def build_data
    build_data = []
    each_build do |build|
      build_data << build
    end
    build_data
  end

  def builds_detailed
    builds_detailed = all_data.dup
    builds_detailed.map do |build|
      build[:detailed_output] = DataFetcher.http_get(build['url'] + 'artifact/rspec.json')
    end
    builds_detailed
  end

  def base_url
    ENV.fetch('CI_URL') + "job/#{project}"
  end
end
