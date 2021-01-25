#!/usr/bin/env python3
"""Show a table of info about Github users or orgs."""
import datetime
from os import getenv
from sys import exit

import arrow
import github  # PyGithub
import typer
from cachier import cachier
from dateutil import tz
from rich import box
from rich.console import Console
from rich.table import Table

console = Console()
TZ = tz.gettz("US/Pacific")

gh = github.Github(login_or_token=getenv("GITHUB_TOKEN"))
gh.per_page = 100

app = typer.Typer()


def hash_org(args, kwargs):
    return args[0].name


def hash_repo(args, kwargs):
    return args[0].url


@cachier(stale_after=datetime.timedelta(days=1), hash_params=hash_org)
def get_all_repos_for_org(org: github.Organization.Organization) -> list:
    return sorted([repo for repo in org.get_repos()], key=lambda x: x.updated_at)


@cachier(stale_after=datetime.timedelta(days=1))
def get_all_repos_for_user(user: github.NamedUser.NamedUser) -> list:
    return sorted([repo for repo in user.get_repos()], key=lambda x: x.updated_at)


@cachier(stale_after=datetime.timedelta(days=1))
def get_all_starred_repos_for_user(user: github.NamedUser.NamedUser) -> list:
    return sorted([repo for repo in user.get_starred()], key=lambda x: x.updated_at)


@cachier(stale_after=datetime.timedelta(days=30), hash_params=hash_repo)
def get_license_for_repo(repo):
    try:
        LICENSE = repo.get_license()
        license = LICENSE.license.name
    except github.GithubException:
        license = ""
    return license


def print_repo_table(title: str, repos: list) -> bool:
    table = Table(title=title, show_lines=True, style="grey19", box=box.MINIMAL)
    table.add_column("Index", style="grey42")
    table.add_column("Last update", style="grey42")
    table.add_column("Name", style="light_goldenrod1")
    table.add_column("URL", style="blue3")
    table.add_column("Homepage", style="blue3")
    table.add_column("Description", style="grey93")
    table.add_column("License", style="light_goldenrod1")

    for index, repo in enumerate(repos):
        table.add_row(
            str(index + 1),
            arrow.get(repo.updated_at, TZ).format("YYYY-MM-DD"),
            repo.name,
            repo.html_url,
            repo.homepage,
            repo.description,
            get_license_for_repo(repo),
        )
    console.print(table)


@app.command()
def get_org_repos(org: str):
    gh_org = gh.get_organization(org)

    repos = get_all_repos_for_org(gh_org)

    print_repo_table(title=f"Repositories for {org}", repos=repos)


@app.command()
def get_user_repos(user: str):
    gh_user = gh.get_user(user)

    repos = get_all_repos_for_user(gh_user)

    print_repo_table(title=f"Repositories for {user}", repos=repos)


@app.command()
def get_user_stars(user: str):
    try:
        gh_user = gh.get_user(user)
    except github.GithubException as e:
        print(e)
        exit(1)

    stars = get_all_starred_repos_for_user(gh_user)

    print_repo_table(title=f"Starred repositories for {user}", repos=stars)


if __name__ == "__main__":
    app()
