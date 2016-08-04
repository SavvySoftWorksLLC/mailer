docker create --name=savvy_mailer -e RACK_ENV=production savvy_mailer
start savvy_mailer
sleep 1
echo "Started"
