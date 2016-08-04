now=$(date +"%m_%d_%Y")

git reset --hard origin/master
git pull

docker build -t savvy_mailer .
stop savvy_mailer
sleep 2
docker rm savvy_mailer_backup
docker rename savvy_mailer savvy_mailer_backup
./bin/docker/containerize_and_run.sh
