<%
from jsonxs import jsonxs
import socket
import getpass

##
## Column definitions
##
import datetime


# Enable columns specified with '--columns'
if columns is not None:
  for col in cols:
    if col["id"] in columns:
      col["visible"] = True
    else:
      col["visible"] = False


# Set whether host info is collapsed by default or not
collapsed_class = "uncollapsed"
collapse_toggle_text = ""
if collapsed == "1":
  collapsed_class = "collapsed"
  collapse_toggle_text = ""
%>

##
## Column functions
##
<%def name="col_name(host)">
  <a href="#${jsonxs(host, 'name')}">${jsonxs(host, "name")}</a>
</%def>
<%def name="col_dtap(host)">
  ${jsonxs(host, 'hostvars.dtap', default='')}
</%def>
<%def name="col_groups(host)">
  ${'<br>'.join(jsonxs(host, 'groups', default=''))}
</%def>
<%def name="col_fqdn(host)">
  ${jsonxs(host, 'ansible_facts.ansible_fqdn', default='')}
</%def>
<%def name="col_main_ip(host)">
  <%
    default_ipv4 = ''
    if jsonxs(host, 'ansible_facts.ansible_os_family', default='') == 'Windows':
      ipv4_addresses = [ip for ip in jsonxs(host, 'ansible_facts.ansible_ip_addresses', default=[]) if ':' not in ip]
      if ipv4_addresses:
        default_ipv4 = ipv4_addresses[0]
    else:
      default_ipv4 = jsonxs(host, 'ansible_facts.ansible_default_ipv4.address', default={})
  %>
  ${default_ipv4}
</%def>
<%def name="col_all_ip4(host)">
  <%
    if jsonxs(host, 'ansible_facts.ansible_os_family', default='') == 'Windows':
      ipv4_addresses = [ip for ip in jsonxs(host, 'ansible_facts.ansible_ip_addresses', default=[]) if ':' not in ip]
    else:
      ipv4_addresses = jsonxs(host, 'ansible_facts.ansible_all_ipv4_addresses', default=[])
  %>
  ${'<br>'.join(ipv4_addresses)}
</%def>
<%def name="col_all_ip6(host)">
  ${'<br>'.join(jsonxs(host, 'ansible_facts.ansible_all_ipv6_addresses', default=[]))}
</%def>
<%def name="col_os(host)">
  % if jsonxs(host, 'ansible_facts.ansible_distribution', default='') in ["OpenBSD"]:
    ${jsonxs(host, 'ansible_facts.ansible_distribution', default='')} ${jsonxs(host, 'ansible_facts.ansible_distribution_release', default='')}
  % else:
    ${jsonxs(host, 'ansible_facts.ansible_distribution', default='')} ${jsonxs(host, 'ansible_facts.ansible_distribution_version', default='')}
  % endif
</%def>
<%def name="col_kernel(host)">
  ${jsonxs(host, 'ansible_facts.ansible_kernel', default='')}
</%def>
<%def name="col_arch(host)">
  ${jsonxs(host, 'ansible_facts.ansible_architecture', default='')} / ${jsonxs(host, 'ansible_facts.ansible_userspace_architecture', default='')}
</%def>
<%def name="col_virt(host)">
  ${jsonxs(host, 'ansible_facts.ansible_virtualization_type', default='?')} / ${jsonxs(host, 'ansible_facts.ansible_virtualization_role', default='?')}
</%def>
<%def name="col_cpu_type(host)">
  <% cpu_type = jsonxs(host, 'ansible_facts.ansible_processor', default=0)%>
  % if isinstance(cpu_type, list) and len(cpu_type) > 0:
    ${ cpu_type[-1] }
  % endif
</%def>
<%def name="col_vcpus(host)">
  % if jsonxs(host, 'ansible_facts.ansible_distribution', default='') in ["OpenBSD"]:
    0
  % else:
    ${jsonxs(host, 'ansible_facts.ansible_processor_vcpus', default=jsonxs(host, 'ansible_facts.ansible_processor_cores', default=0))}
  % endif
</%def>
<%def name="col_ram(host)">
  ${'%0.1f' % ((int(jsonxs(host, 'ansible_facts.ansible_memtotal_mb', default=0)) / 1024.0))}
</%def>
<%def name="col_mem_usage(host)">
  % try:
    <%
    i = jsonxs(host, 'ansible_facts.ansible_memory_mb', default=0) 
    sort_used = '%f' % (float(jsonxs(i, "nocache.used", default=0)) / jsonxs(i, "real.total", default=0))
    used = float(i["nocache"]["used"]) / i["real"]["total"] * 100
    detail_used = round(jsonxs(i, "nocache.used", default=0) / 1024.0, 1)
    detail_total = round(jsonxs(i, "real.total", default=0) / 1024.0, 1)
    %>
    <div class="bar">
      ## hidden sort helper
      <span style="display:none">${sort_used}</span>
      <span class="prog_bar_full" style="width:100px">
        <span class="prog_bar_used" style="width:${used}px"></span>
      </span>
      <span class="usage_detail">(${detail_used} / ${detail_total} GiB)</span>
    </div>
  % except:
    n/a
  % endtry
</%def>
<%def name="col_swap_usage(host)">
  % try:
    <%
      i = jsonxs(host, 'ansible_facts.ansible_memory_mb', default=0)
      sort_used = '%f' % (float(jsonxs(i, "swap.used", default=0)) / jsonxs(i, "swap.total", default=0))
      used = float(jsonxs(i, "swap.used", default=0)) / jsonxs(i, "swap.total", default=0) * 100
      detail_used = round((jsonxs(i, "swap.used", default=0)) / 1024.0, 1)
      detail_total = round(jsonxs(i, "swap.total", default=0) / 1024.0, 1)
    %>
    <div class="bar">
      ## hidden sort helper
      <span style="display:none">${sort_used}</span>
      <span class="prog_bar_full" style="width:100px">
        <span class="prog_bar_used" style="width:${used}px"></span>
      </span>
      <span class="usage_detail">(${detail_used} / ${detail_total} GiB)</span>
    </div>
  % except:
    n/a
  % endtry
</%def>
<%def name="col_disk_usage(host)">
  % for i in jsonxs(host, 'ansible_facts.ansible_mounts', default=[]):
    % try:
      <%
        try:
          sort_used = '%f' % (float((i["size_total"] - i["size_available"])) / i["size_total"])
          used = float((i["size_total"] - i["size_available"])) / i["size_total"] * 100
          detail_used = round((i['size_total'] - i['size_available']) / 1073741824.0, 1)
          detail_total = round(i['size_total'] / 1073741824.0, 1)
        except ZeroDivisionError:
          sort_used = '0'
          used = 0
          detail_used = 0
          detail_total = 0
      %>
      ## hidden sort helper
      <span style="display:none">${sort_used}</span>
      <div class="bar">
        <span class="prog_bar_full" style="width:100px">
          <span class="prog_bar_used" style="width:${used}px"></span>
        </span> ${i['mount']} <span class="usage_detail">(${detail_used} / ${detail_total} GiB)</span>
      </div>
    % except:
      n/a
      <%
      break  ## Stop listing disks, since there was an error.
      %>
    % endtry
  % endfor
</%def>
<%def name="col_physdisk_sizes(host)">
  % try:
    % for physdisk_name, physdisk_info in jsonxs(host, 'ansible_facts.ansible_devices', default={}).items():
      ${physdisk_name}: ${jsonxs(physdisk_info, 'size', default='')}<br />
    % endfor
  % except AttributeError:
    
  % endtry
</%def>
<%def name="col_nr_of_ifaces(host)">
  ${len(jsonxs(host, 'ansible_facts.ansible_interfaces', default=[]))}
</%def>
<%def name="col_comment(host)">
  ${jsonxs(host, 'hostvars.comment', default='')}
</%def>
<%def name="col_ext_id(host)">
  ${jsonxs(host, 'hostvars.ext_id', default='')}
</%def>
<%def name="col_gathered(host)">
  % if 'ansible_date_time' in host['ansible_facts']:
    ${host['ansible_facts']['ansible_date_time'].get('iso8601')}
  % endif
</%def>

##
## Detailed host information blocks
##
<%def name="host_general(host)">
  <h4>General</h4>
  <div>
  <table>
    <tr><th>Node name</th><td>${jsonxs(host, 'ansible_facts.ansible_nodename', default='')}</td></tr>
    <tr><th>Form factor</th><td>${jsonxs(host, 'ansible_facts.ansible_form_factor',  default='')}</td></tr>
    <tr><th>Virtualization role</th><td>${jsonxs(host, 'ansible_facts.ansible_virtualization_role',  default='')}</td></tr>
    <tr><th>Virtualization type</th><td>${jsonxs(host, 'ansible_facts.ansible_virtualization_type',  default='')}</td></tr>
  </table>
  </div>
</%def>
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
<%def name="host_custvars(host)">
  % if len(host['hostvars']) != 0:
    <h4>Custom variables</h4>
    <div>
    <table>
        % for var_name, var_value in host['hostvars'].items():
          <tr>
            <th>${var_name}</th>
            <td>
              % if type(var_value) == dict:
                ${r_dict(var_value)}
              % elif type(var_value) == list:
                ${r_list(var_value)}
              % else:
                ${var_value}
              % endif
        % endfor
    </table>
    </div>
  % endif
</%def>
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
<%def name="host_customfacts(host)">
  % if len(host.get('custom_facts', {}).items()) != 0:
    <h4>Custom facts</h4>
    <div>
    <table>
    <tr><th>Databases</th><td>${r_list(host.get('custom_facts',{})['stdout'])}</td></tr>
  </table>    
    </div>
  % endif
</%def>
<%def name="host_hardware(host)">
  <h4>Hardware</h4>
  <div>
  <table>
    <tr><th>Vendor</th><td>${jsonxs(host, 'ansible_facts.ansible_system_vendor',  default='')}</td></tr>
    <tr><th>Product name</th><td>${jsonxs(host, 'ansible_facts.ansible_product_name',  default='')}</td></tr>
    <tr><th>Product serial</th><td>${jsonxs(host, 'ansible_facts.ansible_product_serial',  default='')}</td></tr>
    <tr><th>Architecture</th><td>${jsonxs(host, 'ansible_facts.ansible_architecture',  default='')}</td></tr>
    <tr><th>Form factor</th><td>${jsonxs(host, 'ansible_facts.ansible_form_factor',  default='')}</td></tr>
    <tr><th>Virtualization role</th><td>${jsonxs(host, 'ansible_facts.ansible_virtualization_role',  default='')}</td></tr>
    <tr><th>Virtualization type</th><td>${jsonxs(host, 'ansible_facts.ansible_virtualization_type',  default='')}</td></tr>
    <tr><th>Machine</th><td>${jsonxs(host, 'ansible_facts.ansible_machine',  default='')}</td></tr>
    <tr><th>Processor count</th><td>${jsonxs(host, 'ansible_facts.ansible_processor_count',  default='')}</td></tr>
    <tr><th>Processor cores</th><td>${jsonxs(host, 'ansible_facts.ansible_processor_cores',  default='')}</td></tr>
    <tr><th>Processor threads per core</th><td>${jsonxs(host, 'ansible_facts.ansible_processor_threads_per_core',  default='')}</td></tr>
    <tr><th>Processor virtual CPUs</th><td>${jsonxs(host, 'ansible_facts.ansible_processor_vcpus',  default='')}</td></tr>
    <tr><th>Mem total mb</th><td>${jsonxs(host, 'ansible_facts.ansible_memtotal_mb',  default='')}</td></tr>
    <tr><th>Mem free mb</th><td>${jsonxs(host, 'ansible_facts.ansible_memfree_mb',  default='')}</td></tr>
    <tr><th>Swap total mb</th><td>${jsonxs(host, 'ansible_facts.ansible_swaptotal_mb',  default='')}</td></tr>
    <tr><th>Swap free mb</th><td>${jsonxs(host, 'ansible_facts.ansible_swapfree_mb',  default='')}</td></tr>
  </table>
  </div>
</%def>
<%def name="host_os(host)">
  <h4>Operating System</h4>
  <div>
  <table>
    <tr><th>System</th><td>${jsonxs(host, 'ansible_facts.ansible_system',  default='')}</td></tr>
    <tr><th>OS Family</th><td>${jsonxs(host, 'ansible_facts.ansible_os_family',  default='')}</td></tr>
    <tr><th>Distribution</th><td>${jsonxs(host, 'ansible_facts.ansible_distribution',  default='')}</td></tr>
    <tr><th>Distribution version</th><td>${jsonxs(host, 'ansible_facts.ansible_distribution_version',  default='')}</td></tr>
    <tr><th>Distribution release</th><td>${jsonxs(host, 'ansible_facts.ansible_distribution_release',  default='')}</td></tr>
    <tr><th>Kernel</th><td>${jsonxs(host, 'ansible_facts.ansible_kernel',  default='')}</td></tr>
    <tr><th>Userspace bits</th><td>${jsonxs(host, 'ansible_facts.ansible_userspace_bits',  default='')}</td></tr>
    <tr><th>Userspace_architecture</th><td>${jsonxs(host, 'ansible_facts.ansible_userspace_architecture',  default='')}</td></tr>
    <tr><th>Date time</th><td>${jsonxs(host, 'ansible_facts.ansible_date_time.iso8601', default='')}</td></tr>
    <tr><th>Locale / Encoding</th><td>${jsonxs(host, 'ansible_facts.ansible_env.LC_ALL', default='Unknown')}</td></tr>
    <tr><th>SELinux?</th><td>${jsonxs(host, 'ansible_facts.ansible_selinux', default='')}</td></tr>
    <tr><th>Package manager</th><td>${jsonxs(host, 'ansible_facts.ansible_pkg_mgr', default='')}</td></tr>
  </table>
  </div>
</%def>
<%def name="host_network(host)">
  <h4>Network</h4>
  <div>
  <table class="net_info">
    <tr><th>Hostname</th><td>${jsonxs(host, 'ansible_facts.ansible_hostname',  default='')}</td></tr>
    <tr><th>Domain</th><td>${jsonxs(host, 'ansible_facts.ansible_domain',  default='')}</td></tr>
    <tr><th>FQDN</th><td>${jsonxs(host, 'ansible_facts.ansible_fqdn',  default='')}</td></tr>
    <tr><th>All IPv4</th><td>${'<br>'.join(jsonxs(host, 'ansible_facts.ansible_all_ipv4_addresses', default=[]))}</td></tr>
    <tr><th>All IPv6</th><td>${'<br>'.join(jsonxs(host, 'ansible_facts.ansible_all_ipv6_addresses', default=[]))}</td></tr>
  </table>
  % if jsonxs(host, 'ansible_facts.ansible_os_family', default='') != "Windows":
    <table class="net_overview">
      <tr>
        <th>IPv4 Networks</th>
        <td>
          <table class="net_overview">
            <tr>
              <th>dev</th>
              <th>address</th>
              <th>network</th>
              <th>netmask</th>
            </tr>
            % for iface_name in sorted(jsonxs(host, 'ansible_facts.ansible_interfaces', default=[])):
              <% iface = jsonxs(host, 'ansible_facts.ansible_' + iface_name, default={}) %>
              % for net in [iface.get('ipv4', {})] + iface.get('ipv4_secondaries', []):
                % if 'address' in net:
                  <tr>
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
  <table class="net_iface_details">
    <tr>
      <th>Interface details</th>
      <td>
        <table>
            % for iface in sorted(jsonxs(host, 'ansible_facts.ansible_interfaces', default=[])):
              <tr>
                <th>${iface}</th>
                 <td>
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
  <h4>Storage</h4>
  <div>
  <table>
    <tr>
      <th>Devices</th>
      <td>
        % if type(jsonxs(host, 'ansible_facts.ansible_devices', default=[])) == list:
          ${r_list(jsonxs(host, 'ansible_facts.ansible_devices', default=[]))}
        % else:
          ${r_dict(jsonxs(host, 'ansible_facts.ansible_devices', default={}))}
        % endif
      </td>
    </tr>
    <tr>
      <th>Mounts</th>
      <td>
        ${r_list(host['ansible_facts'].get('ansible_mounts', []))}
      </td>
    </tr>
  </table>
  </div>
</%def>

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
  <table>
    % for k, v in d.items():
      <tr>
        <th>${k.replace('ansible_', '')}</th>
        <td>
        % if type(v) == list:
          ${r_list(v)}
        % elif type(v) == dict:
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
  <title>Inventario de infraestructura</title>
  <style type="text/css">
    /* reset.css */
    html, body, div, span, applet, object, iframe,
    h1, h2, h3, h4, h5, h6, p, blockquote, pre,
    a, abbr, acronym, address, big, cite, code,
    del, dfn, em, img, ins, kbd, q, s, samp,
    small, strike, strong, sub, sup, tt, var,
    b, u, i, center,
    dl, dt, dd, ol, ul, li,
    fieldset, form, label, legend,
    table, caption, tbody, tfoot, thead, tr, th, td,
    article, aside, canvas, details, embed, 
    figure, figcaption, footer, header, hgroup, 
    menu, nav, output, ruby, section, summary,
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

    header { position: fixed; top: 0px; left: 0px; right: 0px; background-color: #0071b8; overflow: auto; color: #E0E0E0; padding: 15px; z-index: 1000; }
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
    #hosts h1 { font-size: 1.7em; font-weight: bold; color: #0071b8; margin-top: 85px; margin-bottom: 10px; }
    #hosts th { text-align: left; color: #808080; padding-bottom: 10px; }
    #hosts td { padding-left: 16px; color: #303030; padding-bottom: 10px; }
    #hosts ul { list-style: square; margin-left: 48px; }
    #hosts table.net_overview td, #hosts table.net_overview th { text-align: left; padding: 0px 0px 8px 16px; margin: 0px; }
    #hosts table.net_overview { margin: 16px 0px 16px 0px; }
    #hosts .error { color: #FF0000; }
  </style>
  <!-- DataTables assets -->
  % if local_js is "0":
    <script type="text/javascript" charset="utf8" src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
  % else:
    <script type="text/javascript" charset="utf8" src="${res_url}/js/jquery-1.10.2.min.js"></script>
  % endif
  <script type="text/javascript" charset="utf8" src="${res_url}/js/jquery.dataTables.js"></script>
</head>
<body>

<header>
  <h1>Inventario de Infraestructura</h1>
</header>

<div id="col_toggles">
  <div id="col_toggle_buttons">

  </div>
</div>


<div id="hosts">
  % for hostname, host in hosts.items():
    <%
    log.debug("Rendering host details for {0}".format(hostname))
    %>
    <a name="${host['name']}"></a>
    <h1 id="${host['name']}" data-host-name="${host['name']}">${host['name']}</h1>
    <div class="collapsable ${collapsed_class}">
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
        <% host_hardware(host) %>
        <% host_os(host) %>
        <% host_network(host) %>
        <% host_storage(host) %>
      % endif
    </div>
  % endfor
</div>

<footer>
</footer>



</body>
</html>
