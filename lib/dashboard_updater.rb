class DashboardUpdater

  attr_reader :dashboard_id, :data

  def initialize(dashboard_id, data)
    @dashboard_id = dashboard_id
    @data = data
  end

  def update
    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Post.new(url.path,  'Content-Type' => 'application/json')
    req.body = { 'auth_token' => ENV.fetch('DASHBOARD_AUTH_TOKEN') }.merge(data).to_json
    http.request(req)
  end

  private

  def url
    URI(ENV.fetch('DASHBOARD_URL') + dashboard_id)
  end
end
