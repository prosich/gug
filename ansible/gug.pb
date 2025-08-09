---
- name: Configuracion basica Ubuntu
  hosts: u24
  gather_facts: false
  become: true
  
  vars:
    ansible_user: suser

  handlers:
    - name: Reinicia_ssh
      service:
        name: ssh
        state: restarted

  tasks:
    - name: update 
      apt:
        upgrade: yes
        update_cache: yes
    - name: instala
      apt:
        name:
          - xterm
          - docker.io 
          - fail2ban
        state: present

    - name: claves ssh
      ansible.posix.authorized_key:
        user: suser
        state: present
        key: '{{ item }}'
      with_file:
        - peque.pub
        - hp.pub

    - name: Habilitar y arrancar servicios
      systemd:
        name: "{{ item }}"
        enabled: yes
        state: started
      loop:
        - docker
        - fail2ban

    #- name: Crear el usuario minerva # falta de password y ficheros punto
    #  # falta: password, ficheros punto.
    #  user:
    #    name: minerva
    #    state: present
    #    create_home: yes
    #    groups: "docker, adm, cdrom, sudo, dip, lxd"
    #    generate_ssh_key: yes
    #    ssh_key_bits: 2048
    #    ssh_key_file: .ssh/id_rsa

    - name: Allow incoming SSH connections (port 22/tcp)
      community.general.ufw:
        rule: allow         
        port: '22'          
        proto: tcp          
        direction: in       
        state: enabled

    - name: Enable UFW firewall
      community.general.ufw:
        state: enabled    

    - name: Borrar confs que impiden PasswordAuthentication
      ansible.builtin.file:
        path: "{{ item }}" 
        state: absent
      loop:
        - /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
      notify: Reinicia_ssh

    - name: permitir PasswordAuthentication
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PasswordAuthentication'
        line: 'PasswordAuthentication yes'
      notify: Reinicia_sshd

  roles:
    - name: swap1g

