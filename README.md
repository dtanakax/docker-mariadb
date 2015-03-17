# docker-mariadb

### Base Docker Image

[tanaka0323/centosjp](https://bitbucket.org/tanaka0323/docker-centosjp "tanaka0323/centosjp")

### 説明

tanaka0323/centosjpへMariaDB(MySQL)を追加したDockerコンテナイメージです。

[Dockerとは？](https://docs.docker.com/ "Dockerとは？")  
[Docker Command Reference](https://docs.docker.com/reference/commandline/cli/ "Docker Command Reference")

### 使用方法

git pull後に

    $ cd docker-mariadb

イメージ作成

    $ docker build -t <tag>/mariadb .

データベースの作成と起動

    $ docker run -d --name <name> \
                 -p 3306:3306 \
                 -v /tmp/mariadb:/var/lib/mysql \ # 詳細は下記のデータの永続化について
                 -e ROOT_PASSWORD="password" \
                 -e DB_NAME="demodb" \
                 -e DB_USER="demo" \
                 -e DB_PASSWORD="demopassword" \
                 -ti <tag>/mariadb

コンテナ内へログイン

    $ docker exec -ti <name> bash

### 環境変数

- <code>ROOT_PASSWORD</code>root ユーザーパスワード。指定しない場合は実行時ランダムパスワードが生成され、コンテナ実行時に表示されます。
- <code>DB_NAME</code>作成するデータベース名。指定しない場合は作成されません。
- <code>DB_USER</code>DB_NAMEへアクセス可能なユーザー名。
- <code>DB_PASSWORD</code>ユーザーパスワード。指定しない場合は空パスワードになります。

### 利用可能なボリューム

以下のボリュームが利用可能

        /var/lib/mysql      # データ領域
        /var/log/mariadb    # ログ

### データの永続化について

- ホストの/tmp/mariadbフォルダへデータを永続化する方法

    下記オプションを付けてデータベース起動

        -v /tmp/mariadb:/var/lib/mysql

- データのみを格納するコンテナを作成し、データを永続化する方法

    データ格納コンテナのDockerfileを作成

        FROM busybox
        VOLUME /var/lib/mysql
        CMD /bin/sh

    イメージ作成

        docker build -t <tag>/storage .

    起動

        docker run --name <mystorage> -ti <tag>/storage

    以下一行でも可能

        docker run --name <mystorage> -v /var/lib/mysql -ti busybox /bin/sh

    下記オプションを付けてデータベース起動

        --volumes-from <mystorage>

### 他コンテナとのリンク

以下のように他コンテナへデータベースコンテナをリンクすることができます。  

    $ docker run -ti -link mariadb:db <tag>/centosjp bash

-link mariadb:dbは、他コンテナにdbエイリアスを追加します。

### Figでの使用方法

[Figとは](http://www.fig.sh/ "Figとは")  

以下はWordpress構成サンプル

    web:
      image: tanaka0323/nginx-php
      links:
        - db
      ports:
        - "8081:80"
        - "8082:443"
      volumes_from:
        - storage
        - log
    db:
      image: tanaka0323/mariadb
      environment:
        ROOT_PASSWORD: secret
        DB_NAME: wordpress
        DB_USER: wpuser
        DB_PASSWORD: wppass
      volumes_from:
        - storage
        - log

    storage:
      image: tanaka0323/wordpress
      volumes:
        - /var/www/html
        - /var/lib/mysql

    log:
      image: tanaka0323/syslog
      volumes:
        - /var/log
