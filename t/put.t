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

=== TEST 2: simple put query
--- config
    location /foo {
        set $job "hello";
        beanstalkd_query put 1 1 1 $job;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }
--- request
    GET /foo
--- response_body_like: ^INSERTED \d+\r\n$



=== TEST 3: simple put query, autoredirect
--- config
    location /foo/ {
        set $job "hello";
        beanstalkd_query put 1 1 1 $job;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }
--- request
    GET /foo
--- response_body_like: ^INSERTED \d+\r\n$
--- SKIP



=== TEST 4: simple put query, cmd in variable
--- config
    location /foo {
        set $job "hello";
        set $cmd "put";
        beanstalkd_query $cmd 1 1 1 $job;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }
--- request
    GET /foo
--- response_body_like: ^INSERTED \d+\r\n$



=== TEST 5: simple put query 3, command in string
--- config
    location /foo {
        set $job "hello";
        set $cmd "put";
        beanstalkd_query "$cmd" 1 1 1 $job;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }
--- request
    GET /foo
--- response_body_like: ^INSERTED \d+\r\n$



=== TEST 6: simple put query 3, length of job is 0
--- config
    location /foo {
        set $cmd "put";
        beanstalkd_query $cmd 1 1 1 "";
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }
--- request
    GET /foo
--- response_body_like: ^INSERTED \d+\r\n$

