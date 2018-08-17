<%
from jsonxs import jsonxs
import socket
import getpass
from functools import reduce

##
## Column definitions
##
import datetime




# Set whether host info is collapsed by default or not
collapsed_class = "uncollapsed"
collapse_toggle_text = ""
if collapsed == "1":
  collapsed_class = "collapsed"
  collapse_toggle_text = ""
%>

## Se obtiene la información del host con ayuda de las cadenas de expresión de ruta de con JSON
## Detailed host information blocks
##
<%def name="host_general(host)">
  <h4 class="toggle-collapse ${collapsed_class}">General</h4>
  <div class="container collapsable ${collapsed_class}">
  <table class="table">
    <tbody>
      <tr class="info"><th>Node name</th><td>${jsonxs(host, 'ansible_facts.ansible_nodename', default='')}</td></tr>
      <tr ><th>Virtualization role</th><td>${jsonxs(host, 'ansible_facts.ansible_virtualization_role',  default='')}</td></tr>
      <tr class="info"><th>Virtualization type</th><td>${jsonxs(host, 'ansible_facts.ansible_virtualization_type',  default='')}</td></tr>
    </tbody>
  </table>
  </div>
</%def>

## Si el host tiene grupos se van a colocar en forma de lista
<%def name="host_groups(host)">
  % if len(host.get('groups', [])) != 0:
    <h4>Groups</h4>
    <div>
    <ul>
      % for group in sorted(host.get('groups', [])):
        <li>${group}</li>
      % endfor
    </ul>
    </div>
  % endif
</%def>

## Si existe variables de host buscará dentro de los valores si es un directorio, una lista o simplemente tiene un valor, en caso de que aparezca un valor de tipo directorio o lista realizará una función distinta.
<%def name="host_custvars(host)">
  % if len(host['hostvars']) != 0:
    <h4>Custom variables</h4>
    <div class="container">
    <table class="table">
      <tbody>
        % for var_name, var_value in host['hostvars'].items():
          <tr class="info">
            <th><b>${var_name}</b></th>
            <td>
              % if type(var_value) == dict:
                ${r_dict(var_value)}
              % elif type(var_value) == list:
                ${r_list(var_value)}
              % else:
                ${var_value}
              % endif
            </td>
          </tr>
      </tbody>
        % endfor
    </table>
    </div>
  % endif
</%def>

## Se va a mostrar los local facts del host en dado caso de que existan y pasaría lo mismo con factor facts

<%def name="host_localfacts(host)">
  % if len(jsonxs(host, 'ansible_facts.ansible_local', default={}).items()) != 0:
    <h4>Host local facts</h4>
    <div>
    ${r_dict(jsonxs(host,  'ansible_facts.ansible_local', default={}))}
    </div>
  % endif
</%def>
<%def name="host_factorfacts(host)">
  <%
  facter_facts = {}
  for key, value in jsonxs(host, 'ansible_facts', default={}).items():
    if key.startswith('facter_'):
      facter_facts[key] = value
  %>
  % if len(facter_facts) != 0:
    <h4>Facter facts</h4>
    <div>
    ${r_dict(facter_facts)}
    </div>
  % endif
</%def>


## Se muestra
<!-- Custom Facts -->

<%def name="host_customfacts(host)">
  
  <%def name="procesaDict(js)">
    % for key in js:
      % if type(js[key]) is dict:
        <% procesaDict(js[key]) %>
      % elif type(js[key]) is list:
        <% procesaList(key, js[key]) %>
      % else:
        <tr class=""><th>${key}</th></tr>
        <tr class=""><td>${js[key]}</td></tr>
      % endif
    % endfor
  </%def>

  <%def name="procesaList(key,lista)">    
    <%
    flag=0
    %>
    % for value in lista:
      % if type(value) is dict:
        <% procesaDict(value) %>
      % elif type(value) is list:
        <% procesaList(key, value) %>
      % else:
        % if value != "":
          % if flag == 0:
            <tr class=""><th>${key}</th><td>${value}</td></tr>
              <%
              flag=1
              %>
          % elif flag == 1:
            <tr><td></td><td class="odd">${value}</td></tr>
          % else:
            
          %endif          
        % else: 
        % endif
      % endif
    % endfor
  </%def>

  % if len(host.get('custom_facts', {}).items()) != 0:
  <h4 class="toggle-collapse ${collapsed_class}">Custom Facts</h4>
  <div class="container collapsable ${collapsed_class}">
  <table class="table table-bordered">
   
    <% procesaDict(host.get('custom_facts', {})) %>     

  </table>
  </div>
  % endif
</%def>



<!-- Kernel Facts -->
##De los kernel facts se obtiene 


<%def name="host_kernelfacts(host)">
  % if len(host.get('KernelFacts', {})) != 0:
    <h4>Kernel Facts</h4>
    <div class="container">
    <table class="table">
    <% 
    cont_name=0; 
    cont_cont=1;
    %>
    % for x in range(0, (len(host.get('KernelFacts')))/2):
        <tr class="btn-primary"><th>${host.get('KernelFacts')[cont_name]}</th><td>${host.get('KernelFacts')[cont_cont]}</td></tr>
        <% 
            cont_name=cont_name+2; 
            cont_cont=cont_cont+2;
           %>
    % endfor
    </table>    
    </div>
  % endif
</%def>



<!-- Bases de datos -->
## Se obtienen las bases de datos del host

<%def name="host_databases(host)">
  % if len(host.get('Databases', {})) != 0:
    <h4>DataBases</h4>
    <div>
    <ul>    
      % for x in range(0, (len(host.get('Databases')))):
          <li>${host.get('Databases')[x]}</li>
      % endfor
     </ul>  
    </div>
  % endif
</%def>



<!-- Static Routes -->

<%def name="host_staticroutes(host)">
  % if len(host.get('StaticRoutes', {})) != 0:
    
    <h4>Static Routes</h4>
    <div>
      <ul>
       % for item_index in range(0, (len(host.get('StaticRoutes')))):
           <li class="liSR">${host.get('StaticRoutes')[item_index]} </li>
       % endfor
      </ul>    
    </div>
  % endif
</%def>



<!-- Ports -->

<%def name="host_listenports(host)">
  % if len(host.get('Ports', {})) != 0:
    <h4>Listen Ports</h4>
    <div>
    <ul>
    % for x in range(0, (len(host.get('Ports')))):
        <li>${host.get('Ports')[x]}</li>
    % endfor    
    </ul>
    </div>
  % endif
</%def>



<!-- Virtual hosts -->

<%def name="host_virtualhosts(host)">
  % if len(host.get('VirtualHosts', {})) != 0:
      <h4>Virtual Hosts</h4>
      <div class="container">
      <table class="table">
            <% open=0 %>
            % for x in range(0, (len(host.get('VirtualHosts')))):
                % if host.get('VirtualHosts')[x] == '/etc/nginx/vhosts/':
                    % if open == 0:
                        <div><b>Root vhosts:</b></div>
                         <% open=1 %>
                    % else:
                         <% open=0 %>
                        <div><b>Root vhosts:</b></div>
                    % endif
                % elif host.get('VirtualHosts')[x] == '/var/containers/nginx/etc/nginx/vhosts/':
                    % if open == 0:
                        <div><b>Dockerized vhosts:</b></div>
                         
                        <% open=1 %>
                    % else:
                        <% open=0 %>
                         
                        <div><b>Dockerized vhosts:</b></div>
                         
                    % endif
                % else:
                    <li class="liVH">${host.get('VirtualHosts')[x]}</li>
                % endif
            % endfor 
            
      </table>
      </div>
  % endif
</%def>



<!-- Limits -->

<%def name="host_limits(host)">
  % if len(host.get('Limits', {})) != 0:
      <h4>Limits</h4>
      <div class="container">
      <table class="table">
            <% open=0 %>
            % for x in range(0, (len(host.get('Limits')))):
                % if host.get('Limits')[x] == 'limits.conf':
                    <div><b>Limits.conf</b></div>
                % else:
                    <li class="liVH">${host.get('Limits')[x]}</li>
                % endif
            % endfor 
      </table>
      </div>
  % endif
</%def>



##Se realiza la consulta a host, ansible facts y pide los valores que necesita para cada campo.
<%def name="host_hardware(host)">
  <h4 class="toggle-collapse ${collapsed_class}">Hardware</h4>
  <div class="container collapsable ${collapsed_class}">
  <table class="table">
    <tbody>
      <tr class="success"><th>Vendor</th><td>${jsonxs(host, 'ansible_facts.ansible_system_vendor',  default='')}</td></tr>
      <tr class=""><th>Product name</th><td>${jsonxs(host, 'ansible_facts.ansible_product_name',  default='')}</td></tr>
      <tr class="success"><th>Product serial</th><td>${jsonxs(host, 'ansible_facts.ansible_product_serial',  default='')}</td></tr>
      <tr class=""><th>Architecture</th><td>${jsonxs(host, 'ansible_facts.ansible_architecture',  default='')}</td></tr>
      <tr class="success"><th>Virtualization role</th><td>${jsonxs(host, 'ansible_facts.ansible_virtualization_role',  default='')}</td></tr>
      <tr class=""><th>Virtualization type</th><td>${jsonxs(host, 'ansible_facts.ansible_virtualization_type',  default='')}</td></tr>
      <tr class="success"><th>Machine</th><td>${jsonxs(host, 'ansible_facts.ansible_machine',  default='')}</td></tr>
      <tr class=""><th>Processor count</th><td>${jsonxs(host, 'ansible_facts.ansible_processor_count',  default='')}</td></tr>
      <tr class="success"><th>Processor cores</th><td>${jsonxs(host, 'ansible_facts.ansible_processor_cores',  default='')}</td></tr>
      <tr class=""><th>Processor threads per core</th><td>${jsonxs(host, 'ansible_facts.ansible_processor_threads_per_core',  default='')}</td></tr>
      <tr class="success"><th>Processor virtual CPUs</th><td>${jsonxs(host, 'ansible_facts.ansible_processor_vcpus',  default='')}</td></tr>
      <tr class=""><th>Mem total mb</th><td>${jsonxs(host, 'ansible_facts.ansible_memtotal_mb',  default='')}</td></tr>
      <tr class="success"><th>Mem free mb</th><td>${jsonxs(host, 'ansible_facts.ansible_memfree_mb',  default='')}</td></tr>
      <tr class=""><th>Swap total mb</th><td>${jsonxs(host, 'ansible_facts.ansible_swaptotal_mb',  default='')}</td></tr>
      <tr class="success"><th>Swap free mb</th><td>${jsonxs(host, 'ansible_facts.ansible_swapfree_mb',  default='')}</td></tr>
    </tbody>
  </table>
  </div>
</%def>
<%def name="host_os(host)">
  <h4 class="toggle-collapse ${collapsed_class}">Operating System</h4>
  <div class="container">
  <table class="table table-striped table-bordered">
    <tbody>
      <tr class=""><th>System</th><td>${jsonxs(host, 'ansible_facts.ansible_system',  default='')}</td></tr>
      <tr class=""><th>OS Family</th><td>${jsonxs(host, 'ansible_facts.ansible_os_family',  default='')}</td></tr>
      <tr class=""><th>Distribution</th><td>${jsonxs(host, 'ansible_facts.ansible_distribution',  default='')}</td></tr>
      <tr class=""><th>Distribution version</th><td>${jsonxs(host, 'ansible_facts.ansible_distribution_version',  default='')}</td></tr>
      <tr class=""><th>Distribution release</th><td>${jsonxs(host, 'ansible_facts.ansible_distribution_release',  default='')}</td></tr>
      <tr class=""><th>Kernel</th><td>${jsonxs(host, 'ansible_facts.ansible_kernel',  default='')}</td></tr>
      <tr class=""><th>Userspace bits</th><td>${jsonxs(host, 'ansible_facts.ansible_userspace_bits',  default='')}</td></tr>
      <tr class=""><th>Userspace_architecture</th><td>${jsonxs(host, 'ansible_facts.ansible_userspace_architecture',  default='')}</td></tr>
      <tr class=""><th>Date time</th><td>${jsonxs(host, 'ansible_facts.ansible_date_time.iso8601', default='')}</td></tr>
      <tr class=""><th>Locale / Encoding</th><td>${jsonxs(host, 'ansible_facts.ansible_env.LC_ALL', default='Unknown')}</td></tr>
      <tr class=""><th>SELinux?</th><td>${jsonxs(host, 'ansible_facts.ansible_selinux', default='')}</td></tr>
      <tr class=""><th>Package manager</th><td>${jsonxs(host, 'ansible_facts.ansible_pkg_mgr', default='')}</td></tr>
    </tbody>
  </table>
  </div>
</%def>
<%def name="host_network(host)">
  <h4 class="toggle-collapse ${collapsed_class}">Network</h4>
  <div class="container">
  <table class="table table-bordered " class="net_info">
    <tbody>
      <tr class=""><th>Hostname</th><td>${jsonxs(host, 'ansible_facts.ansible_hostname',  default='')}</td></tr>
      <tr class="warning"><th>Domain</th><td>${jsonxs(host, 'ansible_facts.ansible_domain',  default='')}</td></tr>
      <tr class=""><th>FQDN</th><td>${jsonxs(host, 'ansible_facts.ansible_fqdn',  default='')}</td></tr>
      <tr class="warning"><th>All IPv4</th><td>${'<br>'.join(jsonxs(host, 'ansible_facts.ansible_all_ipv4_addresses', default=[]))}</td></tr>
      </tbody>
  </table>
  % if jsonxs(host, 'ansible_facts.ansible_os_family', default='') != "Windows":
    <table class="table" class="net_overview">
      <tr class="">
        <th>IPv4 Networks</th>
        <td>
          <table class="table table-bordered" class="net_overview">

            <thead>
                <tr>
                <th>dev</th>
                <th>address</th>
                <th>network</th>
                <th>netmask</th>
              </tr>
            </thead>
            % for iface_name in sorted(jsonxs(host, 'ansible_facts.ansible_interfaces', default=[])):
              <% iface = jsonxs(host, 'ansible_facts.ansible_' + iface_name, default={}) %>
              % for net in [iface.get('ipv4', {})] + iface.get('ipv4_secondaries', []):
                % if 'address' in net:
                  <tr class="danger">
                    <td>${iface_name}</td>
                    <td>${net['address']}</td>
                    <td>${net['network']}</td>
                    % if 'netmask' in net:
                      <td>${net['netmask']}</td>
                    % else:
                      <td></td>
                    % endif
                  </tr>
                % endif
              % endfor
            % endfor
          </table>
        </td>
      </tr>
    </table>
  % endif
  <table class="table" class="net_iface_details">
    <tr class="">
      <th>Interface details</th>
      <td>
        <table class="table toggle1">
            % for iface in sorted(jsonxs(host, 'ansible_facts.ansible_interfaces', default=[])):
                <th class="">${iface}</th>
                 <td class="">
                  
                  % try:
                    ${r_dict(jsonxs(host, 'ansible_facts.ansible_%s' % iface, default=jsonxs(host, 'ansible_facts.ansible_%s.features' % iface,'del',default=jsonxs(host, 'ansible_facts.ansible_%s.ipv6' % iface,'del',default=jsonxs(host, 'ansible_facts.ansible_%s.ipv4.broadcast' % iface,'del',default=jsonxs(host, 'ansible_facts.ansible_%s.ipv4.network' % iface,'del'))))))}
                  % except KeyError:
                    No information available
                  % endtry
                  
                </td>
              </tr>
            % endfor
        </table>
      </td>
    </tr>
  </table>
  </div>
</%def>
<%def name="host_storage(host)">
  <h4 class="toggle-collapse ${collapsed_class}">Storage</h4>
  <div class="container">
  <table class="table toggle1">
    <tr class="">
      <th>Devices</th>
      <td>
        % if type(jsonxs(host, 'ansible_facts.ansible_devices', default=[])) == list:
          ${r_list_devices(jsonxs(host, 'ansible_facts.ansible_devices', default=[]))}
        % else:
          ${r_dict_devices(jsonxs(host, 'ansible_facts.ansible_devices', default={}))}
        % endif
      </td>
    </tr>
    <tr class="">
      <th>Mounts</th>
      <td>
        % if type(jsonxs(host, 'ansible_facts.ansible_mounts', default=[])) == list:
          ${r_list_mount(jsonxs(host, 'ansible_facts.ansible_mounts', default=[]))}
        % else:
          ${r_dict_mount(jsonxs(host, 'ansible_facts.ansible_mounts', default={}))}
        % endif

      </td>
    </tr>
  </table>

  </div>
</%def>

## Aquí se definen las funciones que se utlizan cuando existe una lista o un directorio para los distintos reqerimientos como lo son los mounts, devices e iface.

##
## Helper functions for dumping python datastructures
##
<%def name="r_list(l)">
  
  % for i in l:
    % if type(i) == list:
      ${r_list(i)}
    % elif type(i) == dict:
      ${r_dict(i)}
    % else:
      ${i}     
    % endif
  % endfor
</%def>

<%def name="r_dict(d)">
  <table class="table block toggle1">
    <a class=" btn btn-primary ifaces"> + Open  </a>
    % for k, v in d.items():
      <tr class="odd">
      <th>${k.replace('ansible_', '')}</th>
      <td>
      % if type(v) == list:
        ${r_list(v)}
      % elif type(v) == dict:
        <!-- botones direct -->
        ${r_dict(v)}
      % else:    
        ${v}
      % endif
      </td>
      </tr>
    % endfor
  </table>
</%def>
<!-- Lista para mounts -->
<%def name="r_list_mount(l)">
  
  % for i in l:
    % if type(i) == list:
      ${r_list_mount(i)}
    % elif type(i) == dict:
      ${r_dict_mount(i)}
    % else:
      <!--${i}-->     
    % endif
  % endfor
</%def>

<!-- Directorio para mounts -->
<%def name="r_dict_mount(d)">
  <table class="table block toggle1">
    <tbody>
      <tr>
     <!--${jsonxs(host, 'ansible_facts.ansible_mounts.mount', default={})}-->
    % for k, v in d.items():
      % if k == 'mount':
        % if type(v) == list:
          ${r_list_mount(v)}
        % elif type(v) == dict:
          <!-- botones direct -->
          ${r_dict_mount(v)}
        % else:    
          ${v}
        % endif
      % endif
    % endfor
     <a class=" btn btn-primary ifaces"> + Open </a>
      </tr>
    % for k, v in d.items():
      <tr class="odd">
      <th>${k.replace('ansible_', '')}</th>
      <td>
      % if type(v) == list:
        ${r_list_mount(v)}
      % elif type(v) == dict:
        <!-- botones direct -->
        ${r_dict_mount(v)}
      % else:    
        ${v}
      % endif
      </td>
      </tr>
    % endfor
    </tbody>
  </table>
</%def>

<!-- Lista para Devices -->
<%def name="r_list_devices(l)">
  
  % for i in l:
    % if type(i) == list:
      ${r_list(i)}
    % elif type(i) == dict:
      ${r_dict(i)}
    % else:
      ${i}     
    % endif
  % endfor
</%def>

<!-- Directorio para devices -->
<%def name="r_dict_devices(d)">
  <table class="table toggle1">
    <a class=" btn btn-primary ifaces"> + Open</a>
    % for k, v in d.items():
      <tr class="odd">
      <th>${k.replace('ansible_', '')}</th>
      <td>
      % if type(v) == list:
        ${r_list(v)}
      % elif type(v) == dict:
        <!-- botones direct -->
        ${r_dict(v)}
      % else:    
        ${v}
      % endif
      </td>
      </tr>
    % endfor
  </table>
</%def>

##
## HTML
##
<%
  if local_js == "0":
    res_url = "https://cdn.datatables.net/1.10.2/"
  else:
    res_url = "file://" + data_dir + "/static/"
%>

<html>
<head>
  <meta charset="UTF-8">
  <title>Inventario de Infraestructura</title>
  <style type="text/css">
    /* reset.css */
    html, body, div, span, applet, object, iframe,
    h1, h2, h3, h4, h5, h6, p, blockquote, pre,
    a, abbr, acronym, address, big, cite, code,
    del, dfn, em, img, ins, kbd, q, s, samp,
    small, strike, strong, sub, sup, tt, var,
    b, u, i,
    dl, dt, dd, ol, ul, li,
    fieldset, form, label, legend,
    table, caption, tbody, tfoot, thead, tr, th, td,
    article, aside, canvas, details, embed, 
    figure, figcaption, footer, header, hgroup, 
    menu, nav, output, section, summary,
    time, mark, audio, video { 
      margin: 0; padding: 0; border: 0; font-size: 100%; font: inherit; vertical-align: baseline;
    }
    /* HTML5 display-role reset for older browsers */
    article, aside, details, figcaption, figure, 
    footer, header, hgroup, menu, nav, section { display: block; }
    body { line-height: 1; }
    ol, ul { list-style: none; }
    blockquote, q { quotes: none; }
    blockquote:before, blockquote:after,
    q:before, q:after { content: ''; content: none; }
    table { border-collapse: collapse; border-spacing: 0; }

    /* ansible-cmdb */
    *, body { font-family: sans-serif; font-weight: lighter; }
    a { text-decoration: none; }

    header { position: fixed; top: 0px; left: 0px; right: 0px; background-color: #0071b8; overflow: auto; color: #E0E0E0; padding:0 15px 15px 15px; z-index: 1000; }
    header h1 { font-size: x-large; float: left; line-height: 32px; font-weight: bold; }
    header #clear_settings { float: right; line-height: 32px; font-size: small; margin-left: 12px; }
    header #clear_settings a { color: #FFFFFF; font-weight: bold; padding: 6px; background-color: #0090F0; box-shadow: 2px 2px 0px 0px rgba(0,0,0,0.15); }
    header #generated { float: right; line-height: 32px; font-size: small; }
    header #top { display: none; }
    header #top a { line-height: 32px; margin-left: 64px; color: #FFFFFF; border-bottom: 1px solid #909090; }
    header #generated .detail { font-weight: bold; }

    footer { display: block; position: fixed; bottom: 0px; right: 0px; left: 0px; background-color: #d5d5d5; overflow: auto; color: #505050; padding: 4px; font-size: x-small; text-align: right; padding-right: 8px; }
    footer a { font-weight: bold; text-decoration: none; color: #202020; }


    #host_overview { margin: 32px; }
    #host_overview h2 { display: block; font-size: 1.4em; color: #606060; }
    #host_overview_tbl_wrapper{ margin-left: 16px; }
    #host_overview table { width: 100%; clear: both; }
    #host_overview tr { border-bottom: 1px solid #F0F0F0; }
    #host_overview tr:hover { background-color: #F0F0F0; }
    #host_overview thead th { text-align: left; color: #707070; padding: 16px 0px 8px 16px; border-bottom: 1px solid #C0C0C0; font-weight: bold; cursor: pointer; background-repeat: no-repeat; background-position: center right; background-image: url("${res_url}/images/sort_both.png"); }
    #host_overview thead th.sorting_desc { background-image: url("${res_url}/images/sort_desc.png"); }
    #host_overview thead th.sorting_asc { background-image: url("${res_url}/images/sort_asc.png"); }
    #host_overview tbody td { color: #000000; padding: 8px 12px 8px 12px; }
    #host_overview tbody a { text-decoration: none; color: #005c9d; }
    #host_overview_tbl_filter { float: right; color: #808080; padding-bottom: 32px; }
    #host_overview_tbl_filter label input { margin-left: 12px; }
    #host_overview_tbl_filter #filter_link a { color: #000000; background: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAoUlEQVR4Xu2TIQ6EMBBF/+4dOUBFBYoboBHoBsuRUCgcnpDg3/Y7ICQVK3ebvPxJ30xH9QXom/PO/PoDAjSOY8pwIwFFr2EYUobjONj33bjGd3Ylr77v2bYNp7Hwhifs3HOeUdu2LMuCE1DXdedtl612cJ1R0zRM04TT1HVNjPERO/ecZxRCSBnmeWZdV+Ma39mVvABVVZUy3EhA0f//gvQB4y08WIiD/goAAAAASUVORK5CYII=) no-repeat left center; padding: 5px 0 5px 25px; }
    #host_overview_tbl_info { margin-top: 16px; color: #C0C0C0; }
    #host_overview .bar { clear: both; margin-bottom: 1px; }
    #host_overview .prog_bar_full { float: left; display: block; height: 12px; border: 1px solid #000000; padding: 1px; margin-right: 4px; color: white; text-align: center; }
    #host_overview .prog_bar_used { display: block; height: 12px; background-color: #8F4040; }
    #host_overview tbody td.error a { color: #FF0000; }
    #host_overview span.usage_detail { color: #606060; }

    #hosts { margin-left: 32px; margin-bottom: 120px; }
    #hosts .toggle-collapse { cursor: pointer; }
    #hosts a.toggle-all { margin-top: 20px; display: inline-block; color: #0080FF; }
    #hosts h3.collapsed::before { color: #505050; margin-right: 16px; content: "⊞";  font-weight: 200; font-size: large; }
    #hosts h3.uncollapsed::before { color: #505050; margin-right: 16px; content: "⊟";  font-weight: 200; font-size: large;}
    #hosts h4.collapsed::before { color: #505050; margin-right: 16px; content: "⊞";  font-weight: 200; font-size: large;}
    #hosts h4.uncollapsed::before { color: #505050; margin-right: 16px; content: "⊟"; font-weight: 200; font-size: large;}
    #hosts div.collapsable { margin-left: 16px; }
    #hosts div.collapsed { display: none; }
    #hosts a { color: #000000; }
    #hosts h3.uncollapsed { line-height: 1.5em; font-size: xx-large; border-bottom: 1px solid #D0D0D0; }
    #hosts h3.collapsed {  line-height: 1.5em; font-size: xx-large; }
    #hosts h4 { font-size: large; font-weight: bold; color: #404040; margin-top: 32px; margin-bottom: 32px; }
    #hosts h1 { font-size: 1.7em; font-weight: bold; color: #0071b8; margin-top: 100px; margin-bottom: 10px; }
    #hosts th { text-align: left; color: #808080; padding-bottom: 10px; }
    #hosts td { padding-left: 16px; color: #303030; padding-bottom: 10px; }
    #hosts ul { list-style: square; margin-left: 48px; }
    #hosts table.net_overview td, #hosts table.net_overview th { text-align: left; padding: 0px 0px 8px 16px; margin: 0px; }
    #hosts table.net_overview { margin: 16px 0px 16px 0px; }
    #hosts .error { color: #FF0000; }

    #hosts li.liSR { list-style-type: decimal; list-style-position:outside; }
    #hosts li.liVH { list-style-type: none; margin-left: 3em; }
    #hosts b {color: white; }
    
    .titulos{
      margin-top: 20px;
    }
    .titulos{color: white !important;}
    /*.ocultar{display: none;}*/
    .buscador{margin-top: 20px;}
    .fixed{position: fixed; margin-top: 100px; z-index: 1000;}
    .resaltar{background-color:#FFEE58;}
    a.btns{font-size: 10px !important;}
    .center{margin-left: 50px !important;}
    .odd:nth-child(odd){background: #d9edf7 !important;}
    .ifaces{color: white!important; font-size: 16px!important; font-weight: bold!important;}
    .block{display: none;}
  </style>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <!-- DataTables assets -->
  % if local_js is "0":
    <script type="text/javascript" charset="utf8" src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
  % else:
    <script type="text/javascript" charset="utf8" src="${res_url}/js/jquery-1.10.2.min.js"></script>
  % endif
  <script type="text/javascript" charset="utf8" src="${res_url}/js/jquery.dataTables.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.4/css/select2.min.css" rel="stylesheet" />


</head>
<body>

<header>
  <h1>Inventario de Infraestructura</h1>
  <div class="input-group buscador col-md-4 pull-right">
   
    <form id="f1" name="f1" action="javascript:void()" onsubmit="if(this.t1.value!=null &amp;&amp; this.t1.value!='')parent.findString(this.t1.value);return false;">
<input type="text" id="t1 filtrar" name="t1"  size="20" placeholder="Buscar" class="form-control col-md-2">
<!--<input type="submit" name="b1" value="Buscar" class="btn btn-primary col-md-2">-->
</form>
  </div>
</header>

<div id="hosts">
  % for hostname, host in hosts.items():
    <%
    log.debug("Rendering host details for {0}".format(hostname))
    %>
    <div class="hosts ${host['name']}">
          <h1 class="titulo" id="${host['name']}" data-host-name="${host['name']}">${host['name']}</h1>
        
      <div class="collapsable ${collapsed_class} ocultar">
        <a class="toggle-all" href="">${collapse_toggle_text}</a>
        % if 'ansible_facts' not in host:
          <p>No host information collected</p>
          % if 'msg' in host:
            <p class="error">${host['msg']}</p>
          % endif
          <% host_groups(host) %>
          <% host_custvars(host) %>
        % else:
          <% host_general(host) %>
          <% host_groups(host) %>
          <% host_custvars(host) %>
          <% host_localfacts(host) %>
          <% host_factorfacts(host) %>

          <% host_customfacts(host) %>
          <% host_kernelfacts(host) %>
          <% host_databases(host) %>
          <% host_staticroutes(host) %>
          <% host_listenports(host) %>
          <% host_virtualhosts(host) %>
          <% host_limits(host) %>

          <% host_hardware(host) %>
          <% host_os(host) %>
          <% host_network(host) %>
          <% host_storage(host) %>
        % endif
      </div>
  </div><!-- div de cada host -->
  % endfor
</div>

<footer>
</footer>
<script>
$(document).ready(function () {
            (function ($) {
                $('#filtrar').keyup(function () {
                    var rex = new RegExp($(this).val(), 'i');
                    $('.table tr').hide();
                    $('.table tr').filter(function () {
                        return rex.test($(this).text());
                    }).show();
                  })
            }(jQuery));
        });
</script>

  <script type='text/javascript' >
    $.expr[':'].icontains = function(obj, index, meta, stack){
    return (obj.textContent || obj.innerText || jQuery(obj).text() || '').toLowerCase().indexOf(meta[3].toLowerCase()) >= 0;
    };
    $(document).ready(function(){   
        $('#filtrar').keyup(function(){
                     buscar = $(this).val();
                     $('.table tr').removeClass('resaltar');
                            if(jQuery.trim(buscar) != ''){
                               $(".table tr:icontains('" + buscar + "')").addClass('resaltar');
                            }
            });
    });   
 </script>


<script language="JavaScript">

var TRange=null;

function findString (str) {
 if (parseInt(navigator.appVersion)<4) return;
 var strFound;
 if (window.find) {

  strFound=self.find(str);
  if (!strFound) {
   strFound=self.find(str,0,1);
   while (self.find(str,0,1)) continue;
  }
 }
 else if (navigator.appName.indexOf("Microsoft")!=-1) {


  if (TRange!=null) {
   TRange.collapse(false);
   strFound=TRange.findText(str);
   if (strFound) TRange.select();
  }
  if (TRange==null || strFound==0) {
   TRange=self.document.body.createTextRange();
   strFound=TRange.findText(str);
   if (strFound) TRange.select();
  }
 }
 else if (navigator.appName=="Opera") {
  alert ("Opera browsers not supported, sorry...")
  return;
 }
 if (!strFound) alert ("String '"+str+"' not found!")
 return;
}
</script>
<script>
  $(document).ready(function() {
  $('.toggle1')
  .find('.ifaces')
  .click(function(e) {
    var date = $(e.target).next();
    displaying = date.css("display");
        if(displaying == "block") {
          date.fadeOut('slow',function() {
           date.css("display","none");
          });
        } else {
          date.fadeIn('slow',function() {
            date.css("display","block");
          });
        }
  });


  // Show host name in header bar when scrolling
  $( window ).scroll(function() {
    var scrollTop = $(window).scrollTop();
    var curElem = false;
    $( ".hosts h1" ).each(function( index ) {
      var el = $(this);
      if ((el.offset().top - 128) <= scrollTop) {
        curElem = el;
      } else {
        return false;
      }
    });
    if (curElem) {
      $("header h1").text(curElem.text());
      $('#top').show();
    } else {
      $("header h1").text("Inventario Infraestructura");
      $('#top').hide();
    };
  });

  $('.toggle-collapse').on('click', function(e) {
    $(this).toggleClass('collapsed');
    $(this).toggleClass('uncollapsed');
    $(this).next().toggleClass('collapsed');
  });
  });
</script>

</body>
</html>
