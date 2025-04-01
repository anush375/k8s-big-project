# To autoscale deployment
kubectl autoscale deployment -n apache-hpa php-apache --cpu-percent=50 --min=1 --max=10

#Describe hpa

kubectl describe hpa  -n apache-hpa

# Create a load for the web server by running a container.

kubectl run -it --rm load-generator --image=busybox /bin/sh --generator=run-pod/v1

# Run load imitation from inside the pod

while true; do wget -q -O- http://php-apache; done

# Give it a minute and check what happened

kubectl get hpa -n apache-hpa
