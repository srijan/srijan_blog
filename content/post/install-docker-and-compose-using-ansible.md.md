---
title: "Install docker and docker-compose using Ansible"
date: 2020-06-11T20:00:00+05:30
tags: ["docker", "docker-compose", "ansible", "linux", "devops"]
---

I wanted a simple, but optimal (and fast) way to install docker and
docker-compose using Ansible. I found a few ways online, but I was not
satisfied.

My requirements were:
* Support Debian and Ubuntu
* Install docker using apt repositories
* Do not even perform an `apt-get update` if docker is already installed using
  this method (to make it fast)
* Install docker-compose by downloading from it's website
* But, don't download if current version >= the minimum version required

I feel trying to achieve these requirements gave me a very good idea of how
powerful ansible can be.

The final role and vars files can be seen in [this
gist](https://gist.github.com/srijan/2028af568459195cb9a3dae8d111e754). But,
I'll go through each section below to explain what makes this better / faster.

## File structure

```:
roles
| -- docker
|    | -- defaults
|    |    | -- main.yml
|    | -- tasks
|    |    | -- main.yml
|    |    | -- docker_setup.yml
```

The `tasks/main.yml` file just imports tasks from `tasks/docker_setup.yml`

## Variables

First, we've defined some variables in `defaults/main.yml`. These will control
which release channel of docker and version of docker-compose will get installed.

```yaml:
---
docker_apt_release_channel: stable
docker_apt_arch: amd64
docker_apt_repository: "deb [arch={{ docker_apt_arch }}] https://download.docker.com/linux/{{ ansible_distribution | lower }} {{ ansible_distribution_release }} {{ docker_apt_release_channel }}"
docker_apt_gpg_key: https://download.docker.com/linux/{{ ansible_distribution | lower }}/gpg
docker_compose_version: "1.24.0"
```

## Docker Setup

This task is divided into the following sections:

### Install dependencies

```yaml:
- name: Install packages using apt
  apt:
    name: 
        - apt-transport-https
        - ca-certificates
        - curl
        - gnupg2
        - software-properties-common
    state: present
    update_cache: no
```

Here the `state: present` makes sure that these packages are only installed if
not already installed. The `update_cache: no` can cause a failure if `apt-get
update` has never been run on this system, but I think we can take that risk.

### Add docker repository

```yaml:
- name: Add Docker GPG apt Key
  apt_key:
    url: "{{ docker_apt_gpg_key }}"
    state: present

- name: Add Docker Repository
  apt_repository:
    repo: "{{ docker_apt_repository }}"
    state: present
    update_cache: true
```

Here, the `state: present` and `update_cache: true` make sure that the cache is
only updated if this state was changed. So, `apt-get update` is not run if the
docker repo is already present.

### Install and enable docker

```yaml:
- name: Update apt and install docker-ce
  apt:
    name: docker-ce
    state: present
    update_cache: false

- name: Run and enable docker
  service:
    name: docker
    state: started
    enabled: true
```

Again, due to `state: present` and `update_cache: false`, there are no extra
cache fetches if docker is already installed.

## Docker Compose Setup

This task has two sections:

### Check if docker-compose is installed and it's version

```yaml:
- name: Check current docker-compose version
  command: docker-compose --version
  register: docker_compose_vsn
  changed_when: false
  failed_when: false
  check_mode: no

- set_fact:
    docker_compose_current_version: "{{ docker_compose_vsn.stdout | regex_search('(\\d+(\\.\\d+)+)') }}"
  when:
    - docker_compose_vsn.stdout is defined
```

The first block saves the output of `docker-compose --version` into a variable
`docker_compose_vsn`. The `failed_when: false` ensures that this does not call a
failure even if the command fails to execute. (See [error handling in
ansible](https://docs.ansible.com/ansible/latest/user_guide/playbooks_error_handling.html)).

Sample output when docker-compose is installed: `docker-compose version 1.26.0, build d4451659`

The second block parses this output and extracts the version number using a
regex (see [ansible
filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html)).
There is a `when` condition which causes the second block to skip execution if
the first block failed (See [playbook
conditionals](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html)).


### Install or upgrade docker-compose if required

```yaml:
- name: Install or upgrade docker-compose
  get_url: 
    url : "https://github.com/docker/compose/releases/download/{{ docker_compose_version }}/docker-compose-Linux-x86_64"
    dest: /usr/local/bin/docker-compose
    mode: 'a+x'
    force: yes
  when: >
    docker_compose_current_version is not defined
    or docker_compose_current_version is version(docker_compose_version, '<')
```

This just downloads the required docker-compose binary and saves it to
`/usr/local/bin/docker-compose`, but it has a conditional that this will only be
done if either docker-compose is not already installed, or if the installed
version is less than the required version. To do version comparison, it uses
ansible's built-in [version comparison
function](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tests.html#version-comparison).

So, we used a few ansible features to achieve what we wanted. I'm sure there are
a lot of other things we can do to make this even better and more fool-proof.
Maybe a post for another day.