docker create -p 0.0.0.0:80:9494 -p 0.0.0.0:443:9494 --name=savvy_mailer -e RACK_ENV=production savvy_mailer
start savvy_mailer
sleep 1
echo "Started"
