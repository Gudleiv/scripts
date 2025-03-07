#!/bin/bash

file="${1:-./package.json}"

[ -r "$file" ] || { echo "The file $file is not readable" ; exit 1 ; }

# Extract package names and versions with a custom delimiter (#)
readarray -t pkgs < <(jq --raw-output '.dependencies | to_entries[] | "\(.key)#\(.value)"' "$file")

# Fetch release dates for each package version
for pkg in "${pkgs[@]}"; do
  
  # Split the package string into name and version using the custom delimiter
  IFS='#' read -r name version <<< "$pkg"
  
  # Debug: Print the name and version
  #echo "Name: $name, Version: $version"
  
  # Remove any non-numeric characters from version (e.g., ^, ~)
  version=$(echo "$version" | sed 's/[^0-9.]//g')
  
  # Debug: Print the command that will be executed
  #echo "Executing: npm view '$name' time.'$version'"
  
  # Fetch the release date
  release_date=$(npm view "$name" time["$version"] 2>/dev/null)
  
  # Debug: Print the result of the command
  #echo "Release date for $name@$version: $release_date"
  
  # Combine package name, version, and release date
  echo "$release_date | $name | $version"
done