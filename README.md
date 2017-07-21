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

El archivo ``html_fancy.tpl`` tiene el formato principal de la salida generada por ``Ansible-cmdb``.

La ubicación del archivo es ``/usr/local/lib/ansiblecmdb/data/tpl/``.

Para obetener la salida personalizada que se ha generado se debe sustituir el archivo ``html_fancy.tpl`` original por el archivo ``html_fancy.tpl`` que se encuentra en este repositorio en el directorio ``tpl``.

Esto se puede realizar del siguiente modo:

1. Clonar o descargar el repositorio.

2. Acceder desde terminal a la ubicación del archivo ``html_fancy.tpl`` original.
    
```
cd /usr/local/lib/ansiblecmdb/data/tpl/
```
    
3. Eliminar el archivo ``html_fancy.tpl`` original y visualizar que se ha eliminado.

```
sudo rm html_fancy.tpl
ls -l
```
    
4. Copiar el archivo ``html_fancy.tpl`` del repositorio a la ubicación por default.

```
sudo cp "Ubicación del archivo html_fancy.tpl en el repositorio" /usr/local/lib/ansiblecmdb/data/tpl/
```

  - Por ejemplo:
       
```
sudo cp /Users/Invitado/Downloads/InventarioInfraestructura-master/tpl/html_fancy.tpl /usr/local/lib/ansiblecmdb/data/tpl/
```

5. Visualizar que se copio correctamente el archivo html_fancy.tpl
    
```
ls -l
```

### Mostrar información

``Ansible-cmdb`` permite mostrar la información recolectada en una página ``HTML``, para ello se utiliza el siguiente comando.

```
ansible-cmdb AnsibleFacts/ CustomFacts/ > overview.html
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
