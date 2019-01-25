# CPU-MEM stat

A handy script to find time, cpu and memory usage of a specific application.
The script will report total time spend on a application, percentage of cpu
and memory. The cpu and memory percentage is collected from top command
polling every second. At the end of execution, maximum reported cpu and memory
usage is reported. 

Comments and suggestions are welcome.

### Eg:
```
    $ ../pstat.sh stress --cpu 1 --timeout 10s
    exectuing stress --cpu 1 --timeout 10s
    stress: info: [23579] dispatching hogs: 1 cpu, 0 io, 0 vm, 0 hdd
    stress: info: [23579] successful run completed in 10s
    %CPU    :100
    %memory :0.0
    time    : 11s
    
```

NOTE :: Do not run the script with same application more than once from single
session. This will cause issues in finding the processes that are started by
the specific instance of script.

The time to execute the application can have difference in 1-2 seconds due to the script
execution overhad.
