# Inventario de Infraestructura (Ansible y Ansible-cmdb)

Repositorio con información y archivos sobre la implementación de un inventario de una infraestructura, utilizando un sistema operativo MacOS Sierra.

## Instalación

Para instalar ``Ansible`` se puede realizar mediante el comando

```
sudo pip install ansible
```

Para instalar ``Ansible-cmdb`` se puede realziar mediante el comando:

```
sudo pip install ansible-cmdb
```

En caso de ser actualizados, para ``Ansible`` se puede realizar mediante:

```
sudo pip install --upgrade ansible
```

Mientras que para actualizar ``Ansible-cmdb`` se puede realizar mediante:

```
sudo pip install --upgrade ansible-cmdb
```

## Uso

### Uso completo Ansible

```
Usage: ansible <host-pattern> [options]

Options:
  -a MODULE_ARGS, --args=MODULE_ARGS
                        module arguments
  --ask-vault-pass      ask for vault password
  -B SECONDS, --background=SECONDS
                        run asynchronously, failing after X seconds
                        (default=N/A)
  -C, --check           don't make any changes; instead, try to predict some
                        of the changes that may occur
  -D, --diff            when changing (small) files and templates, show the
                        differences in those files; works great with --check
  -e EXTRA_VARS, --extra-vars=EXTRA_VARS
                        set additional variables as key=value or YAML/JSON
  -f FORKS, --forks=FORKS
                        specify number of parallel processes to use
                        (default=5)
  -h, --help            show this help message and exit
  -i INVENTORY, --inventory-file=INVENTORY
                        specify inventory host path
                        (default=/etc/ansible/hosts) or comma separated host
                        list.
  -l SUBSET, --limit=SUBSET
                        further limit selected hosts to an additional pattern
  --list-hosts          outputs a list of matching hosts; does not execute
                        anything else
  -m MODULE_NAME, --module-name=MODULE_NAME
                        module name to execute (default=command)
  -M MODULE_PATH, --module-path=MODULE_PATH
                        specify path(s) to module library (default=None)
  --new-vault-password-file=NEW_VAULT_PASSWORD_FILE
                        new vault password file for rekey
  -o, --one-line        condense output
  --output=OUTPUT_FILE  output file name for encrypt or decrypt; use - for
                        stdout
  -P POLL_INTERVAL, --poll=POLL_INTERVAL
                        set the poll interval if using -B (default=15)
  --syntax-check        perform a syntax check on the playbook, but do not
                        execute it
  -t TREE, --tree=TREE  log output to this directory
  --vault-password-file=VAULT_PASSWORD_FILE
                        vault password file
  -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)
  --version             show program's version number and exit

  Connection Options:
    control as whom and how to connect to hosts

    -k, --ask-pass      ask for connection password
    --private-key=PRIVATE_KEY_FILE, --key-file=PRIVATE_KEY_FILE
                        use this file to authenticate the connection
    -u REMOTE_USER, --user=REMOTE_USER
                        connect as this user (default=None)
    -c CONNECTION, --connection=CONNECTION
                        connection type to use (default=smart)
    -T TIMEOUT, --timeout=TIMEOUT
                        override the connection timeout in seconds
                        (default=10)
    --ssh-common-args=SSH_COMMON_ARGS
                        specify common arguments to pass to sftp/scp/ssh (e.g.
                        ProxyCommand)
    --sftp-extra-args=SFTP_EXTRA_ARGS
                        specify extra arguments to pass to sftp only (e.g. -f,
                        -l)
    --scp-extra-args=SCP_EXTRA_ARGS
                        specify extra arguments to pass to scp only (e.g. -l)
    --ssh-extra-args=SSH_EXTRA_ARGS
                        specify extra arguments to pass to ssh only (e.g. -R)

  Privilege Escalation Options:
    control how and which user you become as on target hosts

    -s, --sudo          run operations with sudo (nopasswd) (deprecated, use
                        become)
    -U SUDO_USER, --sudo-user=SUDO_USER
                        desired sudo user (default=root) (deprecated, use
                        become)
    -S, --su            run operations with su (deprecated, use become)
    -R SU_USER, --su-user=SU_USER
                        run operations with su as this user (default=root)
                        (deprecated, use become)
    -b, --become        run operations with become (does not imply password
                        prompting)
    --become-method=BECOME_METHOD
                        privilege escalation method to use (default=sudo),
                        valid choices: [ sudo | su | pbrun | pfexec | doas |
                        dzdo | ksu ]
    --become-user=BECOME_USER
                        run operations as this user (default=root)
    --ask-sudo-pass     ask for sudo password (deprecated, use become)
    --ask-su-pass       ask for su password (deprecated, use become)
    -K, --ask-become-pass
                        ask for privilege escalation password
```
### Uso completo Ansible-cmdb

```
Usage: /usr/local/bin/ansible-cmdb [option] <dir> > output.html

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -t TEMPLATE, --template=TEMPLATE
                        Template to use. Default is 'html_fancy'
  -i INVENTORY, --inventory=INVENTORY
                        Inventory to read extra info from
  -f, --fact-cache      <dir> contains fact-cache files
  -p PARAMS, --params=PARAMS
                        Params to send to template
  -d, --debug           Show debug output
  -c COLUMNS, --columns=COLUMNS
                        Show only given columns
```

### Archivo hosts

Anisble incluye un archivo ``hosts``, ubicado en ``/etc/ansible/`` en el cuál se ingresa un nombre de grupo entre corchetes y en dicho grupo se deben incluir las direcciones de hosts a analizar.

```
[Nombre de grupo]

"Nombre 1"  ansible_ssh_host:"Dirección IP 1"   ansible_ssh_user:"Usuario SSH 1"
"Nombre 2"  ansible_ssh_host:"Dirección IP 2"   ansible_ssh_user:"Usuario SSH 2"
"Nombre 3"  ansible_ssh_host:"Dirección IP 3"   ansible_ssh_user:"Usuario SSH 3"

```

### Verificar conexión entre hosts

Antes de realizar la implementación de obtener información sobre los hosts remotos es recomendable revisar que exista una correcta conexión entre el host que tiene ``Ansible`` y los hosts a analizar. 

```
ansible "Nombre de grupo" -m ping
```

### Obtener facts generados automaticamente por Ansible

Una vez que se ha comprobado la conexión se puede realizar la recolección de informacion de los hosts.

1. Crear directorio donde se almacenarán los ``ansible facts`` de los hosts.

```
mkdir AnsibleFacts
```

2. Obtener información.

```
ansible -m setup --tree AnsibleFacts/ all
```

### Obtener custom facts utilizando Ansible

1. Crear directorio donde se almacenarán los ``custom facts`` de los hosts.

```
mkdir CustomFacts
```

2. Uso de módulo ``shell``.

```
ansible "Nombre de grupo" -m shell -a "Comando a ejecutar entre comillas dobles"
```

3. Obtener bases de datos utilizadas en los hosts utilizando ``shell``.

    Para la obtención de las bases de datos utilizadas en cada host se utiliza el modulo ``shell``, en donde el comando a         utilizar consta de ``ps`` para conocer los procesos, ``awk`` para obtener los primeros valores de cada proceso, y ``grep``     para delimitar que se necesita conocer. 

    La salida de este análisis será almacenada en el directorio ``CustomFacts``.

```
ansible "Nombre de grupo" -m shell -a "ps -ef | awk '{print \$1;}' | grep -e mysql -e sqlserver -e db2 -e oracle -e postgresql -e sqlite -e sybase -e redis -e couchdb -e mongodb" -t CustomFacts/
```

### Ansible, Ansible-cmdb y facts

``Ansible`` permite la ejecución de cualquier comando en los hosts remotos, esto mediante el módulo ``shell``.

La forma de hacerlo es similar a la mostrada en la obtención de los ``custom facts``, sin embargo es necesario hacer un cambio en el nombre del directorio donde se almacenará la información. Por ejemplo: 

```
mkdir VHostsFacts
```

Una vez realizado esto se procede a realizar la ejecución del comando de ``Ansible``, indicando al final el nombre del nuevo directorio.

```
ansible "Nombre de grupo" -m shell -a "comando a ejecutar remotamente" -t VHostsFacts/
```

Al terminar de realizar las tres ejecuciones (AnsibleFacts, CustomFacts y VHostsFacts) se podrán visualizar estos tres directorios en el directorio base que se esté utilizando.

![](https://raw.githubusercontent.com/MartinRoman7/InventarioInfraestructura/master/Images/Captura%20de%20pantalla%202017-09-05%20a%20la(s)%2018.48.32.png)

### Formato de archivos

1. En el directorio ``AnsibleFacts`` se debe tener el siguiente formato ``JSON``.

```
{
  "ansible_facts":
  { 
  
  }
}
```


2. En el directorio ``CustomFacts`` se debe tener el siguiente formato ``JSON``.

```
{
  "custom_facts":
  { 
  
  }
}
```

3. En general para cada directorio que se genere es necesario colocar una llave identificadora en sus archivos para que ``Ansible-cmdb`` pueda hacer uso de la información que se tiene en cada uno de ellos y mostrarla en la salida del archivo HTML.

```
{
  "Llave Identificadora":
  { 
  
  }
}
```

### HTML de inventario personalizado

El archivo ``html_fancy.tpl`` tiene el formato por default de la salida generada por ``Ansible-cmdb``.

La ubicación del archivo es ``/usr/local/lib/ansiblecmdb/data/tpl/``.

``html_fancy.tpl`` incluye llaves por default para leer la información de los archivos que cuenten con dichas llaves. En este caso una de ellas es ``"custom_facts"``.

![](https://raw.githubusercontent.com/MartinRoman7/InventarioInfraestructura/master/Images/Captura%20de%20pantalla%202017-09-05%20a%20la(s)%2019.08.07.png)

![](https://raw.githubusercontent.com/MartinRoman7/InventarioInfraestructura/master/Images/Captura%20de%20pantalla%202017-09-05%20a%20la(s)%2019.09.06.png)

Para hacer uso de la información extra obtenida por el comando ``shell``, se deben declarar las llaves identificadoras asignadas en cada directorio.

En este caso se colocará la llave identificadora ``VHosts_facts`` en el directorio ``VHostsFacts``, teniendo que modificar el nuevo archivo ``html_fancy.tpl`` creado a partir del original. Para poder identificarlos se puede colocar un nombre diferente para cada uno de ellos.

Trabajando sobre el archivo ``html_fancy_modificado.tpl`` se coloca la nueva llave identificadora.

![](https://raw.githubusercontent.com/MartinRoman7/InventarioInfraestructura/master/Images/Captura%20de%20pantalla%202017-09-05%20a%20la(s)%2019.23.50.png)

![](https://raw.githubusercontent.com/MartinRoman7/InventarioInfraestructura/master/Images/Captura%20de%20pantalla%202017-09-05%20a%20la(s)%2019.23.21.png)

De este modo Ansible-cmdb puede hacer uso de los archivos que tengan la llave identificadora ``VHosts_facts``.

En caso de requerir más información se pueden generar más directorios dependiende de cada fact, o se pueden adjuntar en uno sólo. 

### Mostrar información

``Ansible-cmdb`` permite mostrar la información recolectada en una página ``HTML``, para ello se utiliza el siguiente comando.

```
ansible-cmdb AnsibleFacts/ CustomFacts/ VHostsFacts/ > overview.html
``` 

Donde se tomará el archivo ``html_fancy.tpl`` ubicado en ``/usr/local/lib/ansiblecmdb/data/tpl/`` como principal.

Para obtener la salida personalizada que se ha generado, es necesario colocar la dirección global del archivo

``html_fancy_modificado.tpl`` en el comando de ejecución.

Esto se puede realizar del siguiente modo:

```
ansible-cmdb -t "ubicación global del archivo tpl modificado" AnsibleFacts/ CustomFacts/ VHostsFacts/ > overview.html
```


## Licencia

Ansible y Ansible-cmdb están bajo la licencia GPLv3:

```
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

For the full license, see the LICENSE file.
```
