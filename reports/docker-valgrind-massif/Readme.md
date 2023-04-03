# Docker-way to use valgrind massif-visualizer on Mac

## Prepare
- `brew cask install xquartz` # для проброса gui из докера на mac
- `reboot`
- в xquartz preferences на вкладке Security поставить обе галочки, в том числе "Allow connections from network clients"
- https://sourabhbajaj.com/blog/2017/02/07/gui-applications-docker-mac/


## Альтернативный запуск
Если стандартное решение не помогло, то можно воспользоваться решением через socat

Для этого:

1. Установите socat:
`brew install socat`

2. Найдите незанятый порт, например 6000:
`lsof -i TCP:6000`

3. Запустите socat в отдельном окне на этом порту
`socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"`

4. Проверьте, что у вас запущен socat на этом порту
`lsof -i TCP:6000`

5. В env переменных докера укажите DISPLAY
`DISPLAY=docker.for.mac.host.internal:0`

6. Запускайте нужный вам докер образ

Пример:
```
docker run -d -ti --rm \
    -e DISPLAY=docker.for.mac.host.internal:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd):/home/massif/test \
    spajic/docker-valgrind-massif \
    massif-visualizer
```

Пример другого приложения:
`docker run -e DISPLAY=docker.for.mac.host.internal:0 jess/tor-browser`

- Решение: [Stackoverflow](https://stackoverflow.com/a/53548183)

## Run

```bash
./build-docker.sh # собрать докер-image по Dockerfile
./profile.sh # выполнить профилирование в valgrind
./visualize.sh # открыть окно massif-visualizer, там открыть файл, полученный на шаге profile (massif.out.1)
```
