class Dashing.Service extends Dashing.Widget

  ready: ->
    this.executed = false
    setInterval(@countDown, 20000)
    
  countDown: =>
    if this.executed == false
        data = { 
            items: {
                service: this.title,
                lost: true,
                source: "countdown",
                runningTasks: 0,
                desiredTasks: 0,
                tasksStatus: 'success',
                target: 0,
                healthyTargets: 0,
                targetsStatus: 'success'
            },
            id: this.id,
            updatedAt: new Date
        }
    
        this.receiveData(data);

    this.executed = false

    return

  onData: (data) ->
    if data.items.source == 'events' 
        this.executed = true
        data.items.lost = false;
    
    if data.items.runningTasks == 0 or data.items.runningTasks < data.items.desiredTasks
      data.items.tasksStatus = 'failure' 
    else 
      data.items.tasksStatus = 'success'   
        
    if data.items.targets == 0 || data.items.healthyTargets < data.items.targets
      data.items.targetsStatus = 'failure'
    else 
      data.items.targetsStatus = "success"
    
    data.items.serviceurl = this.url 
    data.items.title = this.title
    data.items.service = this.title
    
    this.items = data.items
    
    @set 'items', this.items

    console.log(data.items.service, ": ", data.items.source, ", ", data.items.lost, ", ", data.items.tasksStatus);
    
    data        
