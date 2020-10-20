以nginx镜像为例

```
docker-compose up -d nginx                     构建建启动nignx容器

docker-compose exec nginx bash            登录到nginx容器中

docker-compose down                              删除所有nginx容器,镜像

docker-compose ps                                   显示所有容器

docker-compose restart nginx                   重新启动nginx容器

docker-compose run --no-deps --rm php-fpm php -v  在php-fpm中不启动关联容器，并容器执行php -v 执行完成后删除容器

docker-compose build nginx                     构建镜像 。        

docker-compose build --no-cache nginx   不带缓存的构建。

docker-compose logs  nginx                     查看nginx的日志 

docker-compose logs -f nginx                   查看nginx的实时日志

 

docker-compose config  -q                        验证（docker-compose.yml）文件配置，当配置正确时，不输出任何内容，当文件配置错误，输出错误信息。 

docker-compose events --json nginx       以json的形式输出nginx的docker日志

docker-compose pause nginx                 暂停nignx容器

docker-compose unpause nginx             恢复ningx容器

docker-compose rm nginx                       删除容器（删除前必须关闭容器）

docker-compose stop nginx                    停止nignx容器

docker-compose start nginx                    启动nignx容器
```
