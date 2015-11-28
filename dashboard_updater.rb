class DashboardUpdater

  attr_reader :dashboard_id, :data

  def initialize(dashboard_id, data)
    @dashboard_id = dashboard_id
    @data = data
  end

  def update
    uri = URI("http://0.0.0.0:3030/widgets/#{dashboard_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = { "auth_token" => "TOKEN_1"}.merge(data).to_json
    http.request(req)
  end
end