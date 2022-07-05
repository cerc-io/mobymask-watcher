# mobymask-watcher

## Setup

* Copy [.env.example](./.env.example) and create a `.env` file.

  ```bash
  cp .env.example .env
  ```

* Update the GIT_TOKEN in `.env` file. This is used to access the private repo and packages.

  Follow the steps below to generate the token:

  1. Create a github PAT (personal access token) if it does not already exist.
  
      https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-token

  2. Configure the PAT with `repo` and `read:packages` scopes.
      
      Scopes required for github packages is mentioned in https://docs.github.com/en/packages/learn-github-packages/about-permissions-for-github-packages#about-scopes-and-permissions-for-package-registries.
  
  3. Set the PAT generated in `.env` file and assign it to GIT_TOKEN.

* Reset databases (if docker was already running):

    ```bash
    docker-compose down -v
    ```

* Intialize servers:

  ```bash
  docker-compose up -d --build
  ```

* Optionally, to follow the container logs:

  ```bash
  docker-compose logs -f
  ```

## Demos

* [Local demo](./local-demo.md)
