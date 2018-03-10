require 'net/http'
require 'uri'
require 'json'

SCHEDULER.every '20s' do

  proxyUri = "http://172.17.0.1:8080/services";
  uri = URI.parse(proxyUri)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  
  services = JSON.parse(response.body)

  environments = Hash.new  
  statuses = Array.new
    
  services.each do |service|
    elbUrl = service["elbUrl"]
    serverName = service["name"]
    ecosystem = service["ecosystem"]
    environment = service["environment"]
    
    if (environments.has_key?(environment))
      statuses = environments[environment] 
    else
      statuses = Array.new
      environments[environment] = statuses  
    end
    
    if (elbUrl)
      uri = URI.parse(elbUrl)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
        
      if response.code == "200"
        status = 'success'
      else
        status = 'failure'
      end

      statuses.push({:status => status, :service => serverName, :uri => elbUrl, :ecosystem => ecosystem, :environment => environment})
    else 
      statuses.push({:status => 'warning', :service => serverName, :ecosystem => ecosystem, :environment => environment})
    end
  end
  
  environments.each do |environment, statuses|
     send_event('serverhealth_' + environment, { :items => statuses})
  end   
end