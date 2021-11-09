INDEX_FILE_PATH=$(readlink -f ../src/index.rb)
INDEX_FILE_DIR=$(dirname $INDEX_FILE_PATH)
echo "alias aws_ec2_simple_connector = cd $INDEX_FILE_DIR && ruby $INDEX_FILE_PATH" >> ~/.bashrc
source ~/.bashrc