#!/bin/bash

# echo "Removing dangling images"
docker system prune -f || exit 1

# echo "Getting name of repositories"
repositories=$(docker images --format "{{.Repository}}" | sort | uniq)

# echo "Checking if exist some repositories"
if [ -z "${repositories}" ]; then
	echo "0 repositories found"
	exit 0
else
	for repository in ${repositories}; do
		# echo "Getting tags of each repository and ordering for created datetime"
		tags=$(docker images ${repository} --format "{{.CreatedAt}} {{.Tag}}" | sort -r | awk '{print $NF}')
		i=0
		for tag in ${tags}; do
			# echo "Ignoring the first image, the most recent"
			if [[ ${i}>0 ]]; then
				# echo "Removing image ${repository}:${tag}"
				docker rmi ${repository}:${tag} || exit 1
			else
				echo "### Keeping image ${repository}:${tag}"
			fi
			let "i++"
		done
	done
	echo
	docker images
fi
