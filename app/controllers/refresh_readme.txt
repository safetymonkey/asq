By default, Rails apps can't listen for web requests while responding 
to web requests at the same time. This works in production because 
(as of this writing) we use Passenger to spawn multiple instances 
of the app. Check out the refresh_readme.txt for more details. 

In a dev environment, the open-uri parse() method isn't going to 
work unless: 
1) You have a second instance of Rails' preferred web service running
2) You have the vip_name set to use the port other than the 
   one the main server is listening on. 

As of this writing, we use thin as our Rails web server in dev. To 
test the ability of the Refresh controller to get a host name from
a provided VIP address, you need to start a second instance of thin. 

To do that, go to the repo for Asq and execute:
thin start -p 3001 -d

Use the port from that second instance of thin for the value you put
into the vip_name setting. FOr example, if you're testing on 
blades.sea:3000, then use port 3001 for your second thin isntance, and use 
blades.sea:3001 as the VIP name. 

When you're done, you can issue a thin stop to kill that second thin
instance. 
