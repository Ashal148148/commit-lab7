# How to get a valid certificate
* step 1: own a domain and pick a FQDN you want to get the certificate for (e.g: website.example.com).
* step 2: open the ACM console and request a new certificate, choose DNS validation for the validation method.
* step 3: create the validation records that appear in your certification request. it should be something like this: "_UUID.website.example.com"
* step 4: wait a few minutes for AWS to process
* step 5: use the newly created certificate for your ALB listener