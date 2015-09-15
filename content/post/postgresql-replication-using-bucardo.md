---
date: 2015-09-16T02:03:00+08:00
title: PostgreSQL replication using Bucardo
tags: [postgresql, replication, bucardo, backup]
---

There are many different ways to use replication in PostgreSQL, whether for high
availability (using a failover), or load balancing (for scaling), or just for
keeping a backup. Among the various tools I found online, I though bucardo is
the best for my use case - keeping a live backup of a few important tables.

I've assumed the following databases:

- Primary: Hostname = `host_a`, Database = `btest`
- Backup: Hostname = `host_b`, Database = `btest`

We will install bucardo in the primary database (it required it's own database
to keep track of things).

1. Install postgresql

	```shell
	sudo apt-get install postgresql-9.4
	```

2. Install dependencies on `host_a`

	```shell
	sudo apt-get install libdbix-safe-perl libdbd-pg-perl libboolean-perl build-essential postgresql-plperl-9.4
	```

3. On `host_a`, Download and extract bucardo source

	```shell
	wget https://github.com/bucardo/bucardo/archive/5.4.0.tar.gz
	tar xvfz 5.4.0.tar.gz
	```

4. On `host_a`, Build and Install

	```shell
	perl Makefile.PL
	make
	sudo make install
	sudo mkdir /var/run/bucardo
	sudo mkdir /var/log/bucardo
	```

5. Create bucardo user on all hosts

	```sql
	CREATE USER bucardo SUPERUSER PASSWORD 'random_password';
	CREATE DATABASE bucardo;
	GRANT ALL ON DATABASE bucardo TO bucardo;
	```

	Note: All commands from now on are to be run on `host_a` only.

6. On `host_a`, set a password for the `postgres` user:

	```sql
	ALTER USER postgres PASSWORD 'random_password';
	```

7. On `host_a`, add this to the installation user's `~/.pgpass` file:

	```config
	host_a:5432:*:postgres:random_password
	host_a:5432:*:bucardo:random_password
	```

	Also add entries for the other hosts for which users were created in step 5.

	Note: It is also a good idea to chmod the `~/.pgpass` file to `0600`.

8. Run the bucardo install command:

	```shell
	bucardo -h host_a install
	```

9. Copy schema from A to B:

	```shell
	psql -h host_b -U bucardo template1 -c "drop database if exists btest;"
	psql -h host_b -U bucardo template1 -c "create database btest;"
	pg_dump -U bucardo --schema-only -h host_a btest | psql -U bucardo -h host_b btest
	```

10. Add databases to bucardo config

	```shell
	bucardo -h host_a -U bucardo add db main db=btest user=bucardo pass=host_a_pass host=host_a
	bucardo -h host_a -U bucardo add db bak1 db=btest user=bucardo pass=host_b_pass host=host_b
	```

	This will save database details (host, port, user, password) to bucardo
	database.

11. Add tables to be synced

	To add all tables:

	```shell
	bucardo -h host_a -U bucardo add all tables db=main relgroup=btest_relgroup
	```

	To add one table:

	```shell
	bucardo -h host_a -U bucardo add table table_name db=main relgroup=btest_relgroup
	```

	Note: Only table which have a primary key can be added here. This is a
	limitation of bucardo.

12. Add db group

	```shell
	bucardo -h host_a -U bucardo add dbgroup btest_dbgroup main:source bak1:target
	```

13. Create sync

	```shell
	bucardo -h host_a -U bucardo add sync btest_sync dbgroup=btest_dbgroup relgroup=btest_relgroup conflict_strategy=bucardo_source onetimecopy=2 autokick=0
	```

14. Start the bucardo service

	```shell
	sudo bucardo -h host_a -U bucardo -P random_password start
	```

	Note that this command requires passing the password because it uses sudo,
	and root user's `.pgpass` file does not have the credentials saved for bucardo
	user.

15. Run sync once

	```shell
	bucardo -h host_a -U bucardo kick btest_sync 0
	```

16. Set auto-kick on any changes

	```shell
	bucardo -h host_a -U bucardo update sync btest_sync autokick=1
	bucardo -h host_a -U bucardo reload config
	```

That's it. Now, the tables specified in step 11 will be replicated from `host_a`
to `host_b`.

I also plan to write about other alternatives I've tried soon.

