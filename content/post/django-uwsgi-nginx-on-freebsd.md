---
title: Django, uWSGI, Nginx on Freebsd
tags: [sysadmin, freebsd, python, nginx]
date: "2015-03-05T00:00:00"
aliases: "/notes/django-uwsgi-nginx-on-freebsd.html"
---

Here are the steps I took for configuring Django on Freebsd using
uWSGI and Nginx.

The data flow is like this:

    Web Request ---> Nginx ---> uWSGI ---> Django

I was undecided for a while on whether to choose uWSGI or
gunicorn. There are [some][1] [blog][2] [posts][3] discussing the pros
and cons of each. I chose uWSGI in the end.

Also, to start uWSGI in freebsd, I found two methods: using
[supervisord][4], or using a [custom freebsd init script][5] which
could use uWSGI ini files. Currently using supervisord.


## Install Packages Required

    $ sudo pkg install python py27-virtualenv nginx uwsgi py27-supervisor

Also install any database package(s) required.

## Setup your Django project

Choose a folder for setting up your Django project
sources. `/usr/local/www/myapp` is suggested. Clone the sources to
this folder, then setup the python virtual environment.

    $ virtualenv venv
    $ source venv/bin/activate
    $ pip install -r requirements.txt

If required, also setup the database and run the migrations.

## Setup uWSGI using supervisord

Setup the supervisord file at `/usr/local/etc/supervisord.conf`.

Sample supervisord.conf:

<script src="https://gist.github.com/srijan/de43ac9ab30e6576de0d.js"></script>

And start it:

    $ echo supervisord_enable="YES" >> /etc/rc.conf
    $ sudo service supervisord start
    $ sudo supervisorctl tail -f uwsgi_myapp:uwsgi_myapp0

## Setup Nginx

Use the following line in `nginx.conf`'s http section to include all
config files from `conf.d` folder.

    include /usr/local/etc/nginx/conf.d/*.conf;

Create a `myapp.conf` in `conf.d`.

Sample myapp.conf:

<script src="https://gist.github.com/srijan/5f3ef70da9f5150d845e.js"></script>

And start Nginx:

    $ echo nginx_enable="YES" >> /etc/rc.conf
    $ sudo service nginx start
    $ sudo tail -f /var/log/nginx-error.log

Accessing http://myapp.example.com/ should work correctly after
this. If not, see the supervisord and Nginx logs opened and correct
the errors.


[1]: http://cramer.io/2013/06/27/serving-python-web-applications/
[2]: http://mattseymour.net/blog/2014/07/uwsgi-or-gunicorn/
[3]: http://blog.kgriffs.com/2012/12/18/uwsgi-vs-gunicorn-vs-node-benchmarks.html
[4]: http://amix.dk/blog/post/19689
[5]: http://lists.freebsd.org/pipermail/freebsd-questions/2014-February/256073.html
