# Inventario de Infraestructura (Ansible y Ansible-cmdb)

Repositorio con información y archivos sobre la implementación de un inventario de una infraestrcutura.

## Uso


### Archivo hosts

Anisble incluye un archivo ``hosts``, ubicado en ``/etc/ansible/`` en el cuál se ingresa un nombre de grupo entre corchetes y en dicho grupo se deben incluir las direcciones de hosts a analizar.

```
[Nombre de grupo]

"Nombre 1"  ansible_ssh_host:"Dirección IP 1"   ansible_ssh_user:"Usuario SSH 1"
"Nombre 2"  ansible_ssh_host:"Dirección IP 2"   ansible_ssh_user:"Usuario SSH 2"
"Nombre 3"  ansible_ssh_host:"Dirección IP 3"   ansible_ssh_user:"Usuario SSH 3"

```

### Verificar conexión entre hosts

Antes de realizar la implementación de obtener información sobre los hosts remotos es recomendable revisar que exista una correcta conexión entre el host que tiene `Ansible` y los hosts a analizar. 

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

Ansble permite la ejecución de cualquier comando en los hosts remotos, esto mediante el módulo ``shell``.

La forma de hacerlo es similar a la mostrada en la obtención de los ``custom facts``, sin embargo es necesario hacer un cambio en el nombre del directorio donde se almacenará la información. Por ejemplo: 

```
mkdir VHostsFacts
```

Una vez realizado esto se procede a realizar la ejecución del comando de Ansible, indicando al final el nombre del nuevo directorio.

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

> Es necesario que se tengan las llaves correspondientes para que ``Ansible-cmdb`` pueda obtener la información y mostrarla en la salida del archivo HTML.

### HTML de inventario personalizado

El archivo ``html_fancy.tpl`` tiene el formato por default de la salida generada por ``Ansible-cmdb``.

La ubicación del archivo es ``/usr/local/lib/ansiblecmdb/data/tpl/``.

Para obetener la salida personalizada que se ha generado, es necesario colocar la dirección global del archivo ``html_fancy.tpl`` en el comando de ejecución.

Esto se puede realizar del siguiente modo:

```
ansible-cmdb -t "ubicación global del archivo tpl" AnsibleFacts/ CustomFacts/ > overview.html
``` 

### Mostrar información

``Ansible-cmdb`` permite mostrar la información recolectada en una página ``HTML``, para ello se utiliza el siguiente comando.

```
ansible-cmdb AnsibleFacts/ CustomFacts/ > overview.html
``` 

Donde se tomará el archivo ``html_fancy.tpl`` ubicado en ``/usr/local/lib/ansiblecmdb/data/tpl/`` como principal.

# Extra

En el directorio ``Documentación`` se podrá encontrar más información sobre Ansible y Ansible-cmdb. 

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
