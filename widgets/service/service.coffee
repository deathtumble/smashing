class Dashing.Service extends Dashing.Widget

  ready: ->
    this.executed = false
    setInterval(@countDown, 20000)
    
  countDown: =>
    if this.executed == false
        data = {
            service: this.title,
            lost: true,
            eventsource: "countdown",
            runningTasks: 0,
            desiredTasks: 0,
            tasksstatus: 'success',
            target: 0,
            healthyTargets: 0,
            targetsstatus: 'success'
            id: this.id,
            updatedAt: new Date
         }
    
        this.receiveData(data);

    this.executed = false

    return

  onData: (data) ->
    if data.eventsource == 'events' 
        this.executed = true
        data.lost = false;
    
    if data.runningTasks == 0 or data.runningTasks < data.desiredTasks
      data.tasksstatus = 'failure' 
    else 
      data.tasksstatus = 'success'   
        
    if data.targets == 0 || data.healthyTargets < data.targets
      data.targetsstatus = 'failure'
    else 
      data.targetsstatus = "success"
    
    data.serviceurl = this.url 
    data.title = this.title
    data.service = this.title
    
    @set 'title', data.title
    @set 'serviceurl', data.serviceurl 
    @set 'tasksstatus', data.tasksstatus
    @set 'targetsstatus', data.targetsstatus
    
    data        
