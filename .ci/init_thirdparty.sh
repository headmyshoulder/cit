set -x
set -e

wget https://googlemock.googlecode.com/files/gmock-1.7.0.zip -O /tmp/gmock.zip
unzip -q /tmp/gmock.zip
mv gmock-1.7.0 $CI_ROOT/third_party/gmock
