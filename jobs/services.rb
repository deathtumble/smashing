require 'net/http'
require 'uri'
require 'json'

SCHEDULER.every '10s' do

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
    product = service["product"]
    environment = service["environment"]
    desiredTasks = service["desiredTasks"]
    runningTasks = service["runningTasks"] 
    targets = service["targets"]
    healthyTargets = service["healthyTargets"]
    
    status = {
        :service => serverName, 
        :product => product, 
        :environment => environment, 
        :desiredTasks => desiredTasks, 
        :runningTasks => runningTasks, 
        :targets => targets, 
        :healthyTargets => healthyTargets
     }

    send_event('service_' + service + '_' + environment, { :items => status})
    
    if (environments.has_key?(environment))
      statuses = environments[environment] 
    else
      statuses = Array.new
      environments[environment] = statuses  
    end
    
    statuses.push(status)
  end
  
  environments.each do |environment, statuses|
     if !environment.nil?
        send_event('services_' + environment, { :items => statuses})
     end   
  end   
end