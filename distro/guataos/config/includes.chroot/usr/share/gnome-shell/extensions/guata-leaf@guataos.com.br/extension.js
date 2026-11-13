import St from 'gi://St';
import Gio from 'gi://Gio';
import Clutter from 'gi://Clutter';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

export default class GuataLeaf extends Extension {
    enable() {
        this._button = new PanelMenu.Button(0.0, 'GuataLeaf', true);
        const icon = new St.Icon({
            gicon: Gio.icon_new_for_string(this.path + '/folha.svg'),
            icon_size: 20,
        });
        this._button.add_child(icon);
        this._button.connect('button-press-event', () => {
            Main.overview.toggle();
            return Clutter.EVENT_STOP;
        });
        Main.panel.addToStatusArea('guata-leaf', this._button, 0, 'left');
        const act = Main.panel.statusArea.activities;
        if (act && act.container) {
            act.container.hide();
            this._hidActivities = act;
        }
    }
    disable() {
        if (this._hidActivities && this._hidActivities.container) {
            this._hidActivities.container.show();
        }
        this._hidActivities = null;
        if (this._button) { this._button.destroy(); this._button = null; }
    }
}
