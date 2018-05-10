set -x 

fullpath=`greadlink -f $0`
SPECS=`dirname $fullpath`

IMAGE=10ea291d50ba
# BASE_URL=http://search3.apps.test.cirrostratus.org
BASE_URL=http://host.docker.internal:8080

docker run -it \
  -v $SPECS:/home/ubuntu/specs \
  $IMAGE \
  su ubuntu -c "cd /home/ubuntu/specs ; /home/ubuntu/specs/su-ubuntu-run.sh $BASE_URL"
