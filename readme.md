

# To do

- We still need SSH access from the bastion to the web subnet
- we need the actual bastion vm 
- we need the actual webserver vm
- we need some public ip addresses


# stretch goals

3-tier application:
- add a db subnet, containing a managed postgres
- add a gateway subnet, that hosts a azure app gateway / azure load balancer, whichever you 
  think is most appropiate
- make that gateway loadbalance to the webserver vm's
- make sure the webservers aren't publically accessible anymore, but only through the loadbalancer
- somehow, automatically provision Nginx on the webservers
  - could be a (custom) vm image
  - could be a startup script
  - could be ansible
  - ...

