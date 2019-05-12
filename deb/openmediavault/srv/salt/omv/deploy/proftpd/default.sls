# This file is part of OpenMediaVault.
#
# @license   http://www.gnu.org/licenses/gpl.html GPL Version 3
# @author    Volker Theile <volker.theile@openmediavault.org>
# @copyright Copyright (c) 2009-2019 Volker Theile
#
# OpenMediaVault is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# OpenMediaVault is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenMediaVault. If not, see <http://www.gnu.org/licenses/>.

{% set config = salt['omv_conf.get']('conf.service.ftp') %}

include:
  - .modules

{% if config.enable | to_bool %}

test_proftpd_service_config:
  cmd.run:
    - name: "proftpd --configtest"

# It somehow happens that there is a PID file with incorrect permissions
# that will let the sysvinit script fail:
# proftpd[16533]: Starting ftp server: proftpdstart-stop-daemon: matching on world-writable pidfile /run/proftpd.pid is insecure
chmod_proftpd_pidfile:
  module.run:
  - file.set_mode:
    - path: /run/proftpd.pid
    - mode: 644
  - onlyif: "test -f /run/proftpd.pid"

start_proftpd_service:
  service.running:
    - name: proftpd
    - enable: True
    - require:
      - cmd: test_proftpd_service_config

{% else %}

start_proftpd_service:
  test.nop

stop_proftpd_service:
  service.dead:
    - name: proftpd
    - enable: False

{% endif %}
