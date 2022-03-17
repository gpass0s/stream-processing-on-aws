#!/bin/bash

echo "Executing build.sh..."

if [[ $root_directory ]]; then # if the root_directory is set
  cd $root_directory
fi

if [[ -z $package_output_name ]]; then # if package_output_name is not set
  package_output_name=python_dependencies
fi

if [[ -z $function_name ]]; then # if function_name is not set
  function_name=layer
fi

if [[ -z $runtime ]]; then # if runtime is not set
  runtime=python3.8
fi

if [[ -z $requirements_path ]]; then # if requirements_path is not set
  requirements_path=requirements.txt
fi

mkdir $package_output_name

# Create and activate virtual environment...
virtualenv -p $runtime env_$function_name
source env_$function_name/bin/activate

# Installing python dependencies...
FILE=$requirements_path

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

cp -r env_$function_name/lib/$runtime/site-packages/. $package_output_name
cp -r lambdas/dependencies $package_output_name

# Removing virtual environment folder...
echo "Removing virtual environment folder..."
rm -rf $env_$function_name

# Zipping deployment package...
echo "Zipping deployment package..."
rm -rf $$package_output_name.zip
rm -rf $package_output_name/*pandas*
zip -r $package_output_name.zip $package_output_name/.

# Removing deployment package folder
echo "Removing deployment package folder..."
rm -rf $package_output_name
rm -rf lambdas/.zip
echo "Finished script execution!"