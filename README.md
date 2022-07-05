# mobymask-watcher

## Setup

Reset databases (if docker was already running):

```bash
docker-compose down -v
```

Intialize servers:

```bash
docker-compose up -d --build
```

Optionally, to follow the container logs:

```bash
docker-compose logs -f
```
