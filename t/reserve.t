
# vi:ft=

use lib 'lib';
use Test::Nginx::Socket;

#repeat_each(2);

plan tests => repeat_each() * 2 * blocks();

$ENV{TEST_NGINX_BEANSTALKD_PORT} ||= 11300;

#master_on;
#worker_connections 1024;

#no_diff;

#log_level 'warn';

run_tests();

__DATA__

=== TEST 1:
--- config
    set $id "";
    location /bar {
        beanstalkd_query put 0 0 10 "hello";
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }

    location /foo {
        access_by_lua '
            ngx.location.capture("/bar")
        ';
        beanstalkd_query reserve;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }
--- request
    GET /foo
--- response_body_like: ^RESERVED \d+ 5\r\nhello\r\n$
--- post
system("killall beanstalkd");
system("beanstalkd -d");


=== TEST 2:
--- config
    location /bar {
        beanstalkd_query put 0 0 10 "\r";
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }

    location /foo {
        access_by_lua '
            ngx.location.capture("/bar")
        ';
        beanstalkd_query reserve;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }
--- request
    GET /foo
--- response_body_like: ^RESERVED \d+ 1\r\n\r\r\n$
--- post
system("killall beanstalkd");
system("beanstalkd -d");


=== TEST 3:
--- config
    location /bar {
        beanstalkd_query put 0 0 10 "\r\n";
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }

    location /foo {
        access_by_lua '
            ngx.location.capture("/bar")
        ';
        beanstalkd_query reserve;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }
--- request
    GET /foo
--- response_body_like: ^RESERVED \d+ 2\r\n\r\n\r\n$
--- post
system("killall beanstalkd");
system("beanstalkd -d");
