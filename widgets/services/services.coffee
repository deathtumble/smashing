class Dashing.Services extends Dashing.Widget

  ready: ->

  onData: (data) ->
    for item in data.items
      if item.runningTasks == 0 or item.runningTasks < item.desiredTasks
        item.tasksStatus = 'failure' 
      else 
        item.tasksStatus = 'success'   
          
      if item.targets == 0 || item.healthyTargets < item.targets
        item.targetsStatus = 'failure'
      else 
        item.targetsStatus = 'success' 
    
    data
     

