# mobymask-watcher

## Setup

* [Create a GitHub PAT (personal access token)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-token) with `repo` scope.

* Update the GIT_TOKEN in [.env](./.env) file with the GitHub PAT. This is used to access the private `graph-watcher-ts` repo.

## Run

* Intialize servers:

  ```bash
  docker-compose up -d
  ```

* Optionally, to follow the container logs:

  ```bash
  docker-compose logs -f
  ```

## Reset

* Reset databases:

  ```bash
  docker-compose down -v
  ```

## Demos

* [Mainnet demo](./demo/mainnet.md)
* [Local demo](./demo/local.md)
