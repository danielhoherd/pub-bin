#!/usr/bin/env python3
# License: MIT
# Author: github.com/danielhoherd
# Purpose: Return the latest image:tag for the given image, or optionally print a list of recent tags for the image.
import requests
import typer
from packaging import version


def main(image: str, list_tags: bool = typer.Option(False, help="Print a list of recent tags")):
    tags = get_tags_for_image(image)

    if list_tags:
        for tag in sorted(tags):
            print(tag)
    else:
        newest = max(tags)
        print(f"{image}:{newest}")


def get_tags_for_image(image):
    """Return a sorted list of semver tags for the given image."""
    if image.startswith("quay.io"):
        tags = get_tags_for_image_quay_io(image)
    else:
        tags = get_tags_for_image_docker_io(image)

    return tags


def get_tags_for_image_docker_io(image):
    """Return a sorted list of tags for docker hub image."""
    data = requests.get(f"https://index.docker.io/v1/repositories/{image}/tags").json()
    return sorted({x["name"] for x in data if version.parse(x["name"]).release})


def get_tags_for_image_quay_io(image):
    """Reeturn a sorted list of tags for quay.io image."""
    data = requests.get(f"https://quay.io/api/v1/repository/{image.removeprefix('quay.io/')}/tag?limit=100").json()
    return sorted({x["name"] for x in data["tags"] if version.parse(x["name"]).release})


if __name__ == "__main__":
    typer.run(main)
