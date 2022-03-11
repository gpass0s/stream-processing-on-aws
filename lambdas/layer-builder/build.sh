#!/bin/bash

echo "Executing create_pkg.sh..."

cd $root_directory
root_directory_path=$(pwd)
mkdir $package_output_name

# Create and activate virtual environment...
virtualenv -p $runtime env_$function_name
source $root_directory_path/env_$function_name/bin/activate

# Installing python dependencies...
FILE=$root_directory_path/$requirements_path

if [ -f "$FILE" ]; then
  echo "Installing dependencies..."
  echo "From: requirement.txt file exists..."
  pip install -r "$FILE"

else
  echo "Error: requirement.txt does not exist!"
fi

# Deactivate virtual environment...
deactivate

# Create deployment package...
echo "Creating deployment package..."
cd env_$function_name/lib/$runtime/site-packages/
cp -r . $root_directory_path/$package_output_name
cp -r $root_directory_path/lambdas/dependencies $root_directory_path/$package_output_name

# Removing virtual environment folder...
echo "Removing virtual environment folder..."
cd $root_directory_path
rm -rf $env_$function_name

# Zipping deployment package...
echo "Zipping deployment package..."
cd $package_output_name
zip -r $root_directory_path/$package_output_name.zip .

# Removing deployment package folder
echo "Removing deployment package folder..."
cd $root_directory_path
rm -rf $package_output_name

echo "Finished script execution!"