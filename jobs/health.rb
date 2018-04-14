require 'net/http'
require 'uri'
require 'json'

SCHEDULER.every '20s' do

  proxyUri = "http://172.17.0.1:8080/servers";
  uri = URI.parse(proxyUri)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  
  servers = JSON.parse(response.body)

  environments = Hash.new  
  statuses = Array.new
    
  servers.each do |server|
    hasEndpoint = server["hasEndpoint"]
    serverName = server["name"]
    ecosystem = server["ecosystem"]
    environment = server["environment"]
    
    if (environments.has_key?(environment))
      statuses = environments[environment] 
    else
      statuses = Array.new
      environments[environment] = statuses  
    end

    if (hasEndpoint)
      privateUriString = 'http://' + server["privateIpAddress"] + ':8082/healthz'
      publicUriString = 'http://' + server["publicIpAddress"] + ':8082/healthz'

      uri = URI.parse(privateUriString)

      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = 5
      http.open_timeout = 5
      response = http.start() {|http|
          http.get(url.path)
      }
      
      if response.code == "200"
        status = 'success'
      else
        status = 'failure'
      end

      statuses.push({:status => status, :server => serverName, :uri => publicUriString, :ecosystem => ecosystem, :environment => environment})
    else 
      statuses.push({:status => 'warning', :server => serverName, :ecosystem => ecosystem, :environment => environment})
    end
  end
  
  environments.each do |environment, statuses|
     send_event('health_' + environment, { :items => statuses})
  end   
end