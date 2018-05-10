source ~/.bash_profile

echo $USER
echo $PATH
echo base url: $1
export BASE_URL=$1

bundle install
rspec --format doc
