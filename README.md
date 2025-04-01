sum:events("statefulset:<statefulset_name>").rollup(sum, 300)
Replace <statefulset_name> with the actual name of your StatefulSet.

Define Monitor: When creating the monitor, in the metric query section, you can reference this custom metric. Here's an example:

scss
Copy code
sum(last_5m):sum:events("statefulset:<statefulset_name>").rollup(sum, 300) by {statefulset_name} == 0
