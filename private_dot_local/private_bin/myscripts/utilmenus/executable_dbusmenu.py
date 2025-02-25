#!/bin/python3

# dmenu wrapper around dbus menues
#
# Example Usage:
# python3 dbusmenu.py org.freedesktop.network-manager-applet /org/ayatana/NotificationItem/nm_applet/Menu
#
# https://github.com/tetzank/qmenu_hud/blob/master/com.canonical.dbusmenu.xml

import subprocess
import sys
import time

import dbus

DMENU_CMD = ['fuzzel', '--dmenu', '--no-sort']


def dmenu(_input):
	p = subprocess.Popen(
		DMENU_CMD,
		stdin=subprocess.PIPE,
		stdout=subprocess.PIPE,
		encoding='utf-8',
	)
	out, _ = p.communicate(_input)
	return out


def format_toggle_value(props):
	toggle_type = props.get('toggle-type', '')
	toggle_value = props.get('toggle-state', -1)

	if toggle_value == 0:
		s = ' '
	elif toggle_value == 1:
		s = 'X'
	else:
		s = '~'

	if toggle_type == 'checkmark':
		return '[%s] ' % s
	elif toggle_type == 'radio':
		return '(%s) ' % s
	else:
		return ''


def format_menu_item(item, level=1):
	id, props, children = item

	if not props.get('visible', True):
		return ''
	if props.get('type', 'standard') == 'separator':
		label = '---'
	else:
		label = format_toggle_value(props) + props.get('label', '')
		if not props.get('enabled', True):
			label = '(%s)' % label

	ret = '%i%s%s\n' % (id, '  ' * level, label)
	for child in children:
		ret += format_menu_item(child, level + 1)
	return ret


def show_menu(session_bus, bus, base_path):
    try:
        # Connect to the base object (e.g., /StatusNotifierItem)
        obj = session_bus.get_object(bus, base_path)
        props_iface = dbus.Interface(obj, 'org.freedesktop.DBus.Properties')

        # Get the 'Menu' property
        menu_path = props_iface.Get('org.kde.StatusNotifierItem', 'Menu')
        print(f"Resolved menu path: {menu_path}")

        # Validate the menu path
        if not menu_path or menu_path == '/':
            print(f"No valid menu path found for {bus} at {base_path}")
            return

        # Introspect the menu object
        menu_obj = session_bus.get_object(bus, menu_path)
        iface = dbus.Interface(menu_obj, 'com.canonical.dbusmenu')

        # Fetch and format the menu layout
        _, item = iface.GetLayout(0, -1, dbus.Array([], signature='s'))
        menu = format_menu_item(item)
        print("Formatted menu:", menu)
        menu = "0 Go Back\n" + menu

        selected = dmenu(menu)

        if selected:
            id = int(selected.split()[0])
            if id == 0:
                # If "Back" is selected, go back to showing the SNIs
                show_snis(session_bus)
            else:
                iface.Event(id, 'clicked', '', dbus.UInt32(time.time()))
    except dbus.DBusException as e:
        print(f"Failed to interact with menu at {base_path}: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")



def show_snis(session_bus):
    # Get the list of registered status notifier items
    obj = session_bus.get_object(
        'org.freedesktop.StatusNotifierWatcher',
        '/StatusNotifierWatcher',
    )
    iface = dbus.Interface(obj, 'org.freedesktop.DBus.Properties')
    items = iface.Get(
        'org.kde.StatusNotifierWatcher',
        'RegisteredStatusNotifierItems',
    )

    # Show the available items in dmenu
    selected = dmenu('\n'.join(items))
    if selected:
        # Parse the bus and path from the selected item
        bus, path = selected.strip().split('/', 1)
        bus = bus.strip()
        path = f"/{path.strip()}"

        print(f"Selected bus: {bus}, path: {path}")

        # Show menu for the selected item
        show_menu(session_bus, bus, path)


if __name__ == '__main__':
	session_bus = dbus.SessionBus()
	if len(sys.argv) == 3:
		show_menu(session_bus, sys.argv[1], sys.argv[2])
	else:
		show_snis(session_bus)
