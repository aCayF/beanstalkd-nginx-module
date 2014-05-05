# vi:ft=

use lib 'lib';
use Test::Nginx::Socket;

#repeat_each(2);

plan tests => repeat_each() * ( 3 * blocks() + 6 );

$ENV{TEST_NGINX_BEANSTALKD_PORT} ||= 11300;

#master_on;
#worker_connections 1024;

#no_diff;

#log_level 'warn';

run_tests();

__DATA__

=== TEST 1: duplicated beanstalkd_pass in the same location block
--- config
    location /foo {
        set $job "hello";
        beanstalkd_query put 1 1 1 $job;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }
--- request
    GET /foo
--- must_die
--- error_log
"beanstalkd_pass" directive is duplicate
--- no_error_log
[error]



=== TEST 2: duplicated beanstalkd_pass in the nested location blocks
--- config
    location /foo {
        set $job "hello";
        beanstalkd_query put 1 1 1 $job;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
        location /foo/bar {
            set $job "world";
            beanstalkd_query put 1 1 1 $job;
            beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
        }
    }
--- request eval
["GET /foo", "GET /foo/bar"]
--- response_body_like eval
[qr/^INSERTED \d+\r\n$/, qr/^INSERTED \d+\r\n$/]
--- no_error_log
[error]



=== TEST 3: duplicated beanstalkd_pass in the parallel location blocks
--- config
    location /foo {
        set $job "hello";
        beanstalkd_query put 1 1 1 $job;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }

    location /bar {
        set $job "world";
        beanstalkd_query put 1 1 1 $job;
        beanstalkd_pass 127.0.0.1:$TEST_NGINX_BEANSTALKD_PORT;
    }
--- request eval
["GET /foo", "GET /bar"]
--- response_body_like eval
[qr/^INSERTED \d+\r\n$/, qr/^INSERTED \d+\r\n$/]
--- no_error_log
[error]
